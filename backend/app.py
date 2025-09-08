import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

# --- Optional MongoDB (will run even if not configured) ---
db = None
try:
    from pymongo import MongoClient
    uri = os.getenv("MONGODB_URI")
    db_name = os.getenv("DB_NAME", "gymassistant")
    if uri:
        client = MongoClient(uri)
        db = client[db_name]
        print(f"[MongoDB] Connected to '{db_name}'")
    else:
        print("[MongoDB] MONGODB_URI not set. Running without DB.")
except Exception as e:
    print(f"[MongoDB] Connection skipped/failed: {e}")

@app.get("/health")
def health():
    return jsonify({"status": "ok"}), 200

@app.post("/chat")
def chat():
    data = request.get_json(silent=True) or {}
    user_msg = (data.get("message") or "").strip()
    if not user_msg:
        return jsonify({"error": "message required"}), 400

    # ---- VERY SIMPLE DUMMY LOGIC (replace with ML later) ----
    lower = user_msg.lower()
    if "chest" in lower:
        reply = "Try this 30-min chest workout: 4x8 bench press, 3x10 incline dumbbell press, 3x12 cable fly, 2x15 push-ups. Rest 60–90s."
    elif "diet" in lower or "meal" in lower or "nutrition" in lower:
        reply = "Basic meal plan: 1g protein per lb bodyweight, complex carbs (rice/oats), healthy fats (olive oil/nuts), 3L water/day."
    elif "hi" in lower or "hello" in lower:
        reply = "Hello! I’m your Gym Assistant. Ask me for workouts, plans, or tips 👍"
    else:
        reply = f"You said: '{user_msg}'. For workouts, ask like: 'chest workout for beginners' or 'fat loss meal plan'."

    # Save chat to DB if available
    if db:
        try:
            db.chatlogs.insert_one({"message": user_msg, "reply": reply})
        except Exception as e:
            print(f"[MongoDB] insert chat failed: {e}")

    return jsonify({"reply": reply}), 200

if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)
