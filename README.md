# 🤖 Jarvis AI Assistant

A professional Flutter AI assistant app powered by **Google Gemini 1.5 Flash** with a local model fallback and Bluetooth smartwatch (TG-1) support.

---

## ✨ Features

- **🌐 Gemini AI** — Online chat with Google's Gemini 1.5 Flash model
- **🖥️ Local Model Fallback** — Automatically switches to a Termux Flask backend when offline
- **📡 Bluetooth TG-1** — Connect to your iMiki TG-1 smartwatch
- **🎙️ Turkish Voice Recognition** — Speak in Turkish, get answers
- **🔊 Turkish TTS** — Jarvis speaks back in Turkish
- **🎨 Animated UI** — Pulsing mic, rotating rings, animated chat bubbles

---

## 🚀 Quick Start

### 1. Prerequisites

```bash
flutter --version   # Requires Flutter >= 3.0
```

### 2. Install dependencies

```bash
cd jarvis_app
flutter pub get
```

### 3. Get a Gemini API Key

Visit [https://aistudio.google.com](https://aistudio.google.com) → **Get API Key** → Create key

### 4. Run the app

```bash
flutter run
```

### 5. Configure

- Open **Settings** (⚙️ top right)
- Paste your Gemini API Key → **Kaydet & Test Et**
- Done! Start chatting 🎉

---

## 📁 Project Structure

```
lib/
├── main.dart                         # App entry point
├── models/
│   ├── chat_message.dart             # Message data model
│   └── ai_response.dart              # AI response model
├── services/
│   ├── gemini_service.dart           # Gemini API integration
│   ├── local_model_service.dart      # Termux backend HTTP client
│   ├── bluetooth_service.dart        # BLE device management
│   ├── speech_service.dart           # STT + TTS (Turkish)
│   └── connectivity_service.dart     # Internet detection
├── screens/
│   ├── home_screen.dart              # Main chat screen
│   └── settings_screen.dart          # Configuration screen
└── widgets/
    ├── animated_mic_button.dart      # Pulsing/spinning mic button
    ├── jarvis_background.dart        # Animated dot-grid background
    ├── chat_bubble_animated.dart     # Slide+fade chat bubbles
    └── loading_indicator.dart        # Bouncing dots indicator
```

---

## 🖥️ Termux Backend Setup (Optional)

For offline AI, run this Flask server in Termux on your Android device:

```bash
# In Termux
pip install flask ollama
```

Create `backend.py`:

```python
from flask import Flask, request, jsonify
import ollama

app = Flask(__name__)
history = []

@app.route('/health')
def health():
    return jsonify({'status': 'ok'})

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    user_msg = data.get('message', '')
    history.append({'role': 'user', 'content': user_msg})
    
    response = ollama.chat(model='phi3', messages=history)
    assistant_msg = response['message']['content']
    history.append({'role': 'assistant', 'content': assistant_msg})
    
    return jsonify({'response': assistant_msg})

@app.route('/clear', methods=['POST'])
def clear():
    history.clear()
    return jsonify({'status': 'cleared'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

```bash
python backend.py
```

Then in the app: **Settings → Lokal Model URL** → enter your device IP.

---

## 🔑 API Key Note

The app stores your API key securely using `SharedPreferences`. It is **never sent anywhere** except to Google's official Gemini API endpoint.

---

## 📱 Android Permissions Required

| Permission | Purpose |
|---|---|
| `INTERNET` | Gemini API calls |
| `RECORD_AUDIO` | Voice input |
| `BLUETOOTH_SCAN` | Find TG-1 smartwatch |
| `BLUETOOTH_CONNECT` | Connect to TG-1 |

---

## 🎨 UI Design

- **Color palette**: Deep navy `#060A1A` background, blue `#1565C0`–`#42A5F5` accents
- **Typography**: Orbitron (headers), system font (body)
- **Animations**: Pulse rings, dashed spinning arcs, bouncing dots, slide+fade bubbles
- **Glassmorphism**: Semi-transparent dark cards with blue borders
