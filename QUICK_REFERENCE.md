# Text Toner - Quick Reference Card

## 🚀 Start Commands

### Windows Quick Start

```bash
START_APP.bat
```

### Backend Only

```bash
cd backend
python main.py
```

Runs at: `http://localhost:8000`

### Frontend Only

```bash
cd frontend
flutter run -d windows
```

---

## 🌐 API Quick Reference

### Base URL

```
http://localhost:8000
```

### Endpoints

#### 1. Analyze Tone (Main)

```bash
POST /analyze-tone
Content-Type: application/json

{
  "text": "Your text here",
  "context": "email"  // optional
}
```

#### 2. Quick Analyze

```bash
POST /quick-analyze?text=Your+text
```

#### 3. Supported Tones

```bash
GET /supported-tones
```

#### 4. Health Check

```bash
GET /health
```

#### 5. Service Info

```bash
GET /
```

---

## 📝 Sample Requests

### Using cURL

**Analyze Tone:**

```bash
curl -X POST "http://localhost:8000/analyze-tone" \
  -H "Content-Type: application/json" \
  -d '{"text": "I am really excited about this project!"}'
```

**Quick Analyze:**

```bash
curl -X POST "http://localhost:8000/quick-analyze?text=Hello%20world"
```

**Health Check:**

```bash
curl "http://localhost:8000/health"
```

### Using PowerShell

```powershell
Invoke-WebRequest -Uri "http://localhost:8000/analyze-tone" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"text": "This is amazing!"}'
```

---

## 🎨 Supported Tones

1. **Formal** 🎩 - Professional, structured, official
2. **Casual** 😊 - Relaxed, friendly, conversational
3. **Professional** 💼 - Business-appropriate, competent
4. **Friendly** 🤝 - Warm, approachable, kind
5. **Persuasive** 🎯 - Convincing, compelling, influential
6. **Inspirational** ✨ - Motivating, uplifting, encouraging
7. **Empathetic** ❤️ - Understanding, compassionate, supportive
8. **Authoritative** 👔 - Commanding, confident, expert
9. **Enthusiastic** 🎉 - Excited, energetic, passionate
10. **Neutral** 😐 - Balanced, objective, impartial

---

## 🔧 Configuration

### Backend (.env)

```env
GEMINI_API_KEY=your_api_key_here
```

### Frontend (app_config.dart)

```dart
// For Desktop/Web
defaultValue: 'http://localhost:8000'

// For Android Emulator
defaultValue: 'http://10.0.2.2:8000'

// For Real Device (use your IP)
defaultValue: 'http://192.168.1.100:8000'
```

---

## 🐛 Common Issues

### Backend

| Issue                  | Solution                                                     |
| ---------------------- | ------------------------------------------------------------ |
| Port 8000 in use       | `netstat -ano \| findstr :8000` then `taskkill /PID <id> /F` |
| Gemini API key missing | Create `backend/.env` with `GEMINI_API_KEY=...`              |
| Import errors          | `pip install -r requirements.txt`                            |

### Frontend

| Issue                  | Solution                                       |
| ---------------------- | ---------------------------------------------- |
| Backend not responding | Check backend is running, verify URL in config |
| Flutter errors         | `flutter clean && flutter pub get`             |
| Device not found       | `flutter devices` to see available devices     |

---

## 📊 Response Structure

```json
{
  "original_text": "Your input text",
  "detected_tone": "enthusiastic",
  "confidence": 0.85,
  "tone_category": "enthusiastic",
  "enhanced_versions": [
    {
      "tone": "Formal",
      "text": "Enhanced formal version..."
    },
    {
      "tone": "Casual",
      "text": "Enhanced casual version..."
    },
    {
      "tone": "Professional",
      "text": "Enhanced professional version..."
    }
  ],
  "suggestions": ["Consider your audience", "Add more context"],
  "explanation": "Detailed analysis..."
}
```

---

## 🔑 Keyboard Shortcuts (Frontend)

| Action       | Shortcut        |
| ------------ | --------------- |
| Send message | `Enter`         |
| New line     | `Shift + Enter` |
| Focus input  | `F6`            |
| Open menu    | `Ctrl + M`      |

---

## 📱 Platform-Specific Run Commands

```bash
# Web (Chrome)
flutter run -d chrome

# Windows Desktop
flutter run -d windows

# Android Emulator
flutter run -d emulator-5554

# iOS Simulator (Mac only)
flutter run -d iPhone

# List devices
flutter devices
```

---

## 🧪 Test Examples

### Positive Tone

```
Input: "I'm so happy about this amazing opportunity!"
Expected: enthusiastic/positive
```

### Formal Tone

```
Input: "Please be advised that the meeting is scheduled for tomorrow."
Expected: formal
```

### Casual Tone

```
Input: "Hey! What's up? Let's grab coffee later!"
Expected: casual/friendly
```

### Professional Tone

```
Input: "The quarterly results show significant improvement in key metrics."
Expected: professional
```

---

## 📁 Important Files

```
backend/
├── main.py              # API server
├── .env                 # API keys (create this!)
└── requirements.txt     # Dependencies

frontend/
├── lib/
│   ├── main.dart
│   ├── config/app_config.dart      # API URL config
│   ├── services/api_client.dart    # API calls
│   └── providers/chat_provider.dart # Business logic
└── pubspec.yaml

ROOT/
├── START_APP.bat        # Quick start script
├── README.md           # Main documentation
├── SETUP_INSTRUCTIONS.md # Detailed setup
└── CHANGES_SUMMARY.md   # What changed
```

---

## 🎯 Quick Tips

1. **First Time Setup:**

   - Get Gemini API key from https://makersuite.google.com/app/apikey
   - Create `backend/.env` file
   - Add `GEMINI_API_KEY=your_key`
   - Run `START_APP.bat`

2. **Testing Backend:**

   - Visit http://localhost:8000/docs for interactive API docs
   - Use http://localhost:8000/health to check status

3. **Debugging Frontend:**

   - Check console output for errors
   - Verify API URL in `lib/config/app_config.dart`
   - Use `flutter doctor` to check setup

4. **Rate Limits:**
   - Gemini free tier has rate limits
   - Backend auto-manages delays
   - Wait 2-3 seconds between requests

---

## 📞 Getting Help

1. **Setup Issues** → Read SETUP_INSTRUCTIONS.md
2. **API Questions** → Visit http://localhost:8000/docs
3. **Frontend Errors** → Check CHANGES_SUMMARY.md
4. **General Info** → Read README.md

---

## ✅ Health Check Commands

```bash
# Test backend is running
curl http://localhost:8000/health

# Test Gemini is working
curl -X POST http://localhost:8000/analyze-tone \
  -H "Content-Type: application/json" \
  -d '{"text": "test"}'

# Check frontend can connect
# (in app, check for orange warning banner)
```

---

## 🔄 Update Commands

```bash
# Update backend dependencies
cd backend
pip install --upgrade -r requirements.txt

# Update frontend dependencies
cd frontend
flutter pub upgrade
```

---

**Keep this card handy for quick reference! 📋**
