# 🤖 Jarvis AI Assistant - Detaylı Kurulum Rehberi

> Profesyonel Flutter AI asistanı: **Gemini API** (internet varsa) + **Lokal Model** (internet yoksa) + **TG-1 Smartwatch Bluetooth** + **Türkçe Ses Desteği**

---

## ✨ Özellikler

| Özellik | Açıklama |
|---------|----------|
| 🌐 **Gemini AI** | Google Gemini 1.5 Flash - online chat |
| 🖥️ **Lokal Model Fallback** | İnternet yoksa Termux Flask backend'i kullanır |
| 📡 **Bluetooth TG-1** | iMiki TG-1 smartwatch bağlantısı |
| 🎙️ **Türkçe Ses Tanıma** | Speech-to-Text Türkçe |
| 🔊 **Türkçe TTS** | Text-to-Speech Türkçe |
| 🎨 **Animasyonlu UI** | Pulsing mic, rotating rings, smooth transitions |
| 📱 **Mobil-First** | Fully offline capable |

---

## 🚀 KURULUM (Adım Adım)

### **Adım 1: Gerekli Araçlar**

#### **Bilgisayarında Flutter Kur**

**Windows/Mac/Linux (Seç birini):**

##### **Windows:**
1. https://flutter.dev/docs/get-started/install/windows git
2. **Flutter SDK indir** (en son sürüm, `.zip` olarak)
3. `C:\flutter` klasörüne aç
4. **Cmd veya PowerShell aç**, şu yazı yaz:
```bash
cd C:\flutter\bin
flutter doctor
```

##### **Mac:**
```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor
```

##### **Linux (Ubuntu/Debian):**
```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor
```

#### **Telefonunda:**
- ✅ **Termux** (F-Droid'den indir, Play Store değil)
- ✅ **Flutter** (Termux'ta kurulu)

#### **Kontrol Et:**
```bash
flutter --version
git --version
```

**Çıkmazsa → Flutter yolunu `PATH`'e ekle (Google'da ara)**

---

### **Adım 2: Projeyi Hazırla (Bilgisayarda)**

#### 2.1 GitHub Repo'nu Klonla
```bash
cd ~
git clone https://github.com/aliegny/homemade-Jarvis.git
cd homemade-Jarvis
```

#### 2.2 Proje Yapısını Oluştur
```bash
flutter create .
```

Eğer soru sorarsa → **Y** (yes) cevapla.

#### 2.3 Klasörleri Oluştur
```bash
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/screens
mkdir -p lib/widgets
```

---

### **Adım 3: Dosyaları Yerleştir (Bilgisayarda)**

**Benim verdiğim tüm `.dart` dosyalarını** aşağıdaki klasörlere kopyala:

```
lib/
├── main.dart                    ← buraya koy
├── models/
│   └── chat_message.dart        ← buraya koy
├── services/
│   ├── connectivity_service.dart
│   ├── gemini_service.dart
│   ├── local_model_service.dart
│   ├── speech_service.dart
│   └── bluetooth_service.dart
├── screens/
│   ├── home_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── animated_mic_button.dart
    ├── jarvis_background.dart
    └── chat_bubble_animated.dart
```

---

### **Adım 4: pubspec.yaml'ı Güncelle (Bilgisayarda)**

`pubspec.yaml` dosyasını aç, **tamamını** sil ve şunu yapıştır:

```yaml
name: jarvis_app
description: Jarvis AI Assistant with Gemini & Local Fallback
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  google_generative_ai: ^0.4.0
  speech_to_text: ^7.0.0
  flutter_tts: ^8.2.0
  flutter_blue_plus: ^1.30.0
  http: ^1.1.0
  connectivity_plus: ^6.0.0
  provider: ^6.0.0
  shared_preferences: ^2.2.0
  lottie: ^3.0.0
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

Kaydet.

---

### **Adım 5: GitHub'a Push Et (Bilgisayarda)**

```bash
git add .
git commit -m "Add Jarvis Flutter code with Gemini + Local fallback"
git push origin main
```

---

### **Adım 6: Telefona Klonla (Termux'ta)**

Telefondaki **Termux**'u aç ve yaz:

```bash
cd ~
git clone https://github.com/aliegny/homemade-Jarvis.git
cd homemade-Jarvis
```

---

### **Adım 7: Paketleri Yükle (Termux'ta)**

```bash
flutter pub get
```

**Bekle, biraz zaman alır.** (5-10 dakika)

---

### **Adım 8: Kontrol Et (Termux'ta)**

```bash
flutter analyze
```

Hata çıkarsa, ekran görüntüsünü gönder. Yoksa devam et.

---

### **Adım 9: Çalıştır (Termux'ta)**

```bash
flutter run
```

**Telefonunda app açılacak!** 🎉

---

## 🔑 Gemini API Key Alma ve Ayarlama

### **API Key'i Al (Bilgisayar/Telefon Browser)**

1. https://aistudio.google.com git
2. **"Get API Key"** tıkla
3. **"Create new API key in new project"** tıkla
4. **API key'i kopyala** (uzun bir string olacak)

### **App'te Yapıştır**

1. **Jarvis app'ini aç** (Termux'tan çalıştırdıktan sonra)
2. **Üst sağda ⚙️ (Ayarlar) tıkla**
3. **"Gemini API Key" kısmına yapıştır**
4. **"Kaydet" tıkla**
5. ✅ Gemini yapılandırıldı!

---

## 🖥️ Lokal Model Backend Kurulumu (İnternet Yokken)

### **Neden?**
İnternet olmadığında, telefonunuzda çalışan yerel bir AI modeli kullanacak.

### **Kurulum (Termux'ta)**

#### **Adım 1: Paketi Yükle**
```bash
pip install flask
pip install ollama
```

#### **Adım 2: Backend Dosyasını Oluştur**

Termux'ta yaz:
```bash
nano ~/backend.py
```

Şu kodu yapıştır:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Jarvis Backend - Termux'ta çalışan Flask API
Yerel Ollama modelini serve eder
"""

from flask import Flask, request, jsonify
import ollama
import json

app = Flask(__name__)

# Model seçimi (hangisini tercih ederseniz)
ACTIVE_MODEL = "phi"  # ya da "neural-chat", "mistral" vb

# Konuşma geçmişi
conversation_history = []
MAX_HISTORY = 5

SYSTEM_PROMPT = """Sen Jarvis isimli bir AI asistanısın.
- Kısa, doğrudan cevaplar ver (1-2 cümle ideal)
- Türkçe'de akıcı konuş
- Yardımcı ve misafirperver ol"""

@app.route('/health', methods=['GET'])
def health():
    """Backend sağlığını kontrol et"""
    return jsonify({"status": "ok", "model": ACTIVE_MODEL}), 200

@app.route('/chat', methods=['POST'])
def chat():
    """Kullanıcı mesajını işle"""
    try:
        data = request.json
        user_message = data.get('message', '').strip()
        
        if not user_message:
            return jsonify({"error": "Mesaj boş"}), 400
        
        # Geçmişe ekle
        conversation_history.append({
            "role": "user",
            "content": user_message
        })
        
        # Eski mesajları sil
        if len(conversation_history) > MAX_HISTORY:
            conversation_history.pop(0)
        
        # Ollama'ya gönder
        response = ollama.chat(
            model=ACTIVE_MODEL,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                *conversation_history
            ],
            stream=False,
        )
        
        assistant_message = response['message']['content'].strip()
        
        # Geçmişe asistan mesajını ekle
        conversation_history.append({
            "role": "assistant",
            "content": assistant_message
        })
        
        return jsonify({
            "response": assistant_message,
            "tokens_used": response.get('eval_count', 0)
        }), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/clear', methods=['POST'])
def clear_history():
    """Konuşma geçmişini temizle"""
    global conversation_history
    conversation_history = []
    return jsonify({"status": "cleared"}), 200

if __name__ == '__main__':
    print(f"🤖 Jarvis Backend başlatılıyor...")
    print(f"📱 Model: {ACTIVE_MODEL}")
    print(f"🌐 Adres: http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=False)
```

**Ctrl+X → Y → Enter** (kaydet)

#### **Adım 3: Backend'i Başlat**

```bash
python ~/backend.py
```

**Çıktıda şunu göreceksin:**
```
🤖 Jarvis Backend başlatılıyor...
📱 Model: phi
🌐 Adres: http://localhost:5000
 * Running on http://0.0.0.0:5000
```

**Bu pencerede açık kalmalı!** Kapatma.

---

### **Adım 4: App'te Backend'i Ayarla**

Yeni bir **Termux penceresi** aç (Alt+Shift sürükle), app'i çalıştır:

```bash
cd ~/homemade-Jarvis
flutter run
```

App açılırsa:
1. **Üst sağda ⚙️ tıkla**
2. **"Lokal Model URL"** kısmını gör (ekle gerekirse)
3. **`http://127.0.0.1:5000` yaz**
4. **Kaydet**

---

## 📡 Bluetooth TG-1 Smartwatch Kurulumu

### **Adım 1: Cihazı Eşleştir**

1. **TG-1 smartwatch'u aç** (açık değilse)
2. **Telefon ayarları → Bluetooth → Cihazları taraf**
3. **iMiki TG-1 veya TG-1** ara, **seç**
4. ✅ Bağlandı

### **Adım 2: App'te Bağlan**

1. **Jarvis app'i aç**
2. **⚙️ (Ayarlar) → "TG-1'e Bağlan" tuşu**
3. App otomatik olarak bulacak ve bağlanacak
4. ✅ "TG-1 bağlı" yazısı görünecek

### **Adım 3: Konuş!**

Artık TG-1 smartwatch'undan veya telefondan konuşabilirsin:
- 📱 Telefondaki mikrofon butonu
- ⌚ Smartwatch'taki mikrofon (varsa)

---

## 🎨 Uygulamayı Kullanmak

### **Ana Ekran (Chat)**

```
┌─────────────────────┐
│  Jarvis      ⚙️     │  ← Ayarlar
├─────────────────────┤
│                     │
│  Mesaj 1 (sağda)    │  ← Senin mesajın
│   AI Yanıt (solda)  │  ← AI'ın yanıtı
│                     │
├─────────────────────┤
│      [ 🎙️ ]         │  ← Büyük mikrofon (konuş)
│    Konuşmak için    │
│    tıkla            │
├─────────────────────┤
│ [Mesaj yaz...] [➤] │  ← Yazarak mesaj gönder
└─────────────────────┘
```

### **Ayarlar (⚙️)**

1. **Gemini API Key** → API key yapıştır, Kaydet
2. **Lokal Model URL** → `http://127.0.0.1:5000` (backend çalışıyorsa)
3. **TG-1'e Bağlan** → Smartwatch bağlantısı

---

## 📊 Nasıl Çalışır?

### **İnternet Varsa:**
```
Konuş → Ses Tanıma → Gemini API → TTS → Cevap
```

### **İnternet Yoksa:**
```
Konuş → Ses Tanıma → Termux Backend → TTS → Cevap
```

### **Smartwatch Varsa:**
```
Smartwatch Mikrofon → App → AI → App → Smartwatch Speaker
```

---

## 🔐 Güvenlik

- ✅ **API Key:** `SharedPreferences`'ta saklanır, sadece Google'a gönderilir
- ✅ **Lokal Model:** Telefonunuzda çalışır, hiçbir yere gönderilmez
- ✅ **Konuşma:** End-to-end, kimse dinlemiyor

---

## 📱 Gerekli İzinler

| İzin | Amaç |
|------|------|
| `INTERNET` | Gemini API ve web'e |
| `RECORD_AUDIO` | Mikrofon ile ses kaydı |
| `BLUETOOTH_SCAN` | TG-1 taraması |
| `BLUETOOTH_CONNECT` | TG-1 bağlantısı |

App isterse, **İzin Ver** tıkla.

---

## 🎨 UI Tasarımı

| Element | Tasarım |
|---------|---------|
| **Renk** | Deep navy (#0A0E27) + Blue accents (#2196F3) |
| **Typography** | Modern, Clean |
| **Animasyonlar** | Pulsing rings (dinleme), Rotating (işleme), Slide+Fade (chat) |
| **Stil** | Glassmorphism, Soft shadows |

---

## 🆘 Sorun Giderme

| Sorun | Çözüm |
|-------|--------|
| **Gemini API hatası** | API key doğru mu? https://aistudio.google.com'da kontrol et |
| **Ses tanısı çalışmıyor** | Mikrofon izinlerini ver (Ayarlar → App Permissions) |
| **Backend bağlanmıyor** | Backend çalışıyor mu? Termux penceresinde kontrol et |
| **TG-1 bulunamıyor** | Smartwatch açık mı? Bluetooth açık mı? |
| **App açılmıyor** | `flutter run` tekrar yaz |

---

## 📞 Destek

Sorun olursa:
1. **Termux penceresini kontrol et** (hata mesajları görebilirsin)
2. **`flutter analyze` yap** (syntax hatası var mı?)
3. **Repo'ya issue aç** → detaylar yaz

---

## 📄 Lisans

MIT License - Özgürce kullan, modifike et, dağıt.

---

## 🙏 Teşekkürler

- **Google Gemini** - AI gücü
- **Flutter** - Cross-platform
- **Ollama** - Lokal modeller
- **iMiki TG-1** - Smartwatch desteği

---

**Hazırsan başla! Sorularını buraya yaz.** 🚀
