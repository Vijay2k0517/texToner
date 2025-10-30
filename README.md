# Text Toner 🎨

A modern AI-powered text tone analyzer and enhancement tool built with FastAPI and Flutter. Analyze the tone of any text, get confidence scores, and receive intelligently enhanced versions in different tones using Google's Gemini AI.

![Text Toner](https://img.shields.io/badge/Status-Production%20Ready-green)
![Backend](https://img.shields.io/badge/Backend-FastAPI-009688)
![Frontend](https://img.shields.io/badge/Frontend-Flutter-02569B)
![AI](https://img.shields.io/badge/AI-Gemini-4285F4)

---

## ✨ Features

### 🎯 Tone Analysis

- **Accurate Detection**: Identifies tone with confidence scores
- **11 Tone Categories**: Formal, Casual, Professional, Friendly, Persuasive, Inspirational, Empathetic, Authoritative, Enthusiastic, Neutral, and more
- **Context-Aware**: Provide context (email, social media, business) for better analysis

### ✏️ Text Enhancement

- **Multiple Versions**: Get 3+ enhanced versions in different tones
- **Preserve Meaning**: Maintains core message while adjusting tone
- **Actionable Suggestions**: Receive specific improvement recommendations

### 💬 Modern Chat Interface

- **Clean UI**: Beautiful gradient design with smooth animations
- **Real-Time**: Instant feedback with typing indicators
- **History**: Track past analyses in the side panel
- **Cross-Platform**: Works on Windows, macOS, Linux, Web, Android, and iOS

### 🔧 Developer-Friendly

- **RESTful API**: Well-documented FastAPI backend
- **Type-Safe**: Pydantic models and TypeScript-style Dart
- **Health Monitoring**: Built-in health checks and error handling
- **CORS Enabled**: Ready for web deployment

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8+ (for backend)
- Flutter 3.7.0+ (for frontend)
- Google Gemini API key ([Get one free](https://makersuite.google.com/app/apikey))

### One-Command Start (Windows)

```bash
# 1. Set up your Gemini API key in backend/.env:
echo GEMINI_API_KEY=your_api_key_here > backend\.env

# 2. Run the quick start script:
START_APP.bat
```

### Manual Setup

#### Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
echo "GEMINI_API_KEY=your_key" > .env
python main.py
```

Backend runs at: `http://localhost:8000`

#### Frontend

```bash
cd frontend
flutter pub get
flutter run -d windows  # or chrome, android, ios
```

---

## 📖 Documentation

- **[Setup Instructions](SETUP_INSTRUCTIONS.md)** - Complete setup guide
- **[Changes Summary](CHANGES_SUMMARY.md)** - Frontend update details
- **[API Documentation](http://localhost:8000/docs)** - Interactive API docs (when running)

---

## 🌐 API Endpoints

### POST /analyze-tone

Comprehensive tone analysis with enhanced versions.

```bash
curl -X POST http://localhost:8000/analyze-tone \
  -H "Content-Type: application/json" \
  -d '{"text": "I am really excited about this!", "context": "email"}'
```

**Response:**

```json
{
  "original_text": "I am really excited about this!",
  "detected_tone": "enthusiastic",
  "confidence": 0.92,
  "tone_category": "enthusiastic",
  "enhanced_versions": [
    { "tone": "Formal", "text": "I am pleased to express my enthusiasm..." },
    {
      "tone": "Professional",
      "text": "I am very interested in this project..."
    },
    { "tone": "Casual", "text": "This is so cool! Can't wait!" }
  ],
  "suggestions": [
    "Consider the audience for appropriate tone",
    "Maintain enthusiasm while being professional"
  ],
  "explanation": "The text shows high enthusiasm with exclamation marks..."
}
```

### GET /supported-tones

List all available tone categories.

### GET /health

Check backend status and Gemini availability.

### POST /quick-analyze

Fast tone detection without enhancements.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│         Flutter Frontend            │
│  (Windows/Mac/Linux/Web/Mobile)     │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Chat UI (Material Design)  │  │
│  └──────────────┬───────────────┘  │
│                 │                   │
│  ┌──────────────▼───────────────┐  │
│  │  State Management (Provider) │  │
│  └──────────────┬───────────────┘  │
│                 │                   │
│  ┌──────────────▼───────────────┐  │
│  │   API Client (HTTP)          │  │
│  └──────────────┬───────────────┘  │
└─────────────────┼───────────────────┘
                  │
                  │ HTTP/JSON
                  │
┌─────────────────▼───────────────────┐
│       FastAPI Backend               │
│         (Python)                    │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   RESTful API Endpoints      │  │
│  └──────────────┬───────────────┘  │
│                 │                   │
│  ┌──────────────▼───────────────┐  │
│  │  Tone Analysis Engine        │  │
│  └──────────────┬───────────────┘  │
│                 │                   │
│  ┌──────────────▼───────────────┐  │
│  │   Google Gemini AI           │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## 📱 Screenshots

### Desktop Application

- Modern chat interface with gradient design
- Real-time tone analysis with confidence scores
- Enhanced text versions in multiple tones
- Smart suggestions for improvement

### Features in Action

- 🎯 **Quick Actions**: One-tap access to common tone adjustments
- 📊 **Confidence Scores**: See how certain the AI is about detected tones
- 🎨 **Visual Tone Indicators**: Emoji-based tone representation
- 📝 **Suggestions**: Actionable tips for text improvement
- 🕐 **History**: Access previous analyses

---

## 🛠️ Tech Stack

### Backend

- **FastAPI** - Modern Python web framework
- **Google Gemini AI** - Powerful language model
- **Pydantic** - Data validation
- **Uvicorn** - ASGI server
- **python-dotenv** - Environment management

### Frontend

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **Google Fonts** - Typography
- **HTTP** - API communication
- **Staggered Animations** - Smooth UI transitions

---

## 🔐 Environment Variables

### Backend (.env)

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Frontend (Optional)

```bash
flutter run --dart-define=API_BASE_URL=http://your-backend-url:8000
```

---

## 🧪 Testing

### Backend

```bash
cd backend
# Start server
python main.py

# Test health
curl http://localhost:8000/health

# Test analysis
curl -X POST http://localhost:8000/analyze-tone \
  -H "Content-Type: application/json" \
  -d '{"text": "This is amazing!"}'
```

### Frontend

```bash
cd frontend
flutter test
flutter run
```

---

## 📦 Deployment

### Backend

**Heroku:**

```bash
heroku create text-toner-api
heroku config:set GEMINI_API_KEY=your_key
git push heroku main
```

**Railway:**

1. Connect GitHub repository
2. Add `GEMINI_API_KEY` environment variable
3. Deploy automatically

**Google Cloud Run:**

```bash
gcloud run deploy text-toner --source .
```

### Frontend

**Web:**

```bash
flutter build web
# Deploy to Firebase Hosting, Netlify, or Vercel
```

**Android:**

```bash
flutter build apk --release
```

**Windows:**

```bash
flutter build windows --release
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

---

## 📄 License

This project is open source and available under the MIT License.

---

## 🙏 Acknowledgments

- **Google Gemini AI** for powerful language understanding
- **Flutter Team** for the amazing cross-platform framework
- **FastAPI** for the modern Python web framework

---

## 📞 Support

For issues, questions, or feature requests:

1. Check the [Setup Instructions](SETUP_INSTRUCTIONS.md)
2. Review the [Changes Summary](CHANGES_SUMMARY.md)
3. Visit the [API Documentation](http://localhost:8000/docs)

---

## 🚀 Roadmap

- [ ] Voice input support
- [ ] Multiple language support
- [ ] Batch text processing
- [ ] Tone comparison tool
- [ ] Export analysis reports
- [ ] User accounts and saved analyses
- [ ] Mobile app optimizations
- [ ] Dark mode theme

---

**Made with ❤️ using FastAPI, Flutter, and Google Gemini AI**

---

## 📈 Status

- ✅ Backend: Production Ready
- ✅ Frontend: Production Ready
- ✅ API Integration: Complete
- ✅ Documentation: Complete
- ✅ Testing: Basic tests included

**Current Version:** 1.0.0

**Last Updated:** October 30, 2025
