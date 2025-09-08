import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <Message>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _api = ApiService();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(Message(text: text, sender: Sender.user));
      _sending = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final reply = await _api.sendMessage(text);
      setState(() {
        _messages.add(Message(text: reply, sender: Sender.bot));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(text: '⚠️ Error: $e', sender: Sender.bot));
      });
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.orangeAccent,
        title: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Gym Assistant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Lottie.asset(
                        'assets/animations/dumbbell.json',
                        width: 200,
                        height: 200,
                        repeat: true,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) =>
                          MessageBubble(message: _messages[index])
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                    ),
            ),

            // Typing indicator
            if (_sending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Lottie.asset(
                  'assets/animations/typing.json',
                  width: 60,
                  height: 40,
                ),
              ),

            // Input area
            Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "Ask me about workouts, diet...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.orangeAccent,
                      child: _sending
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Icon(Icons.send,
                              color: Colors.white, size: 22),
                    ).animate().scale(duration: 300.ms),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
