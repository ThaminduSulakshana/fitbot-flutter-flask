import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<String> sendMessage(String text) async {
    final uri = Uri.parse('$apiBaseUrl/chat');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': text}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['reply'] ?? 'No reply').toString();
    } else {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }
  }
}
