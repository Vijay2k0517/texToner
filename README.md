# Text Toner 🎨

A modern **fullstack AI-powered** text tone analyzer and enhancement tool with user authentication and conversation history. Built with FastAPI, Flutter, SQLite, and Google's Gemini AI. Analyze text tone, get enhanced versions, and track your conversation history - all secured with JWT authentication.

![Text Toner](https://img.shields.io/badge/Status-Production%20Ready-green)
![Backend](https://img.shields.io/badge/Backend-FastAPI-009688)
![Frontend](https://img.shields.io/badge/Frontend-Flutter-02569B)
![AI](https://img.shields.io/badge/AI-Gemini-4285F4)
![Database](https://img.shields.io/badge/Database-SQLite-003B57)
![Auth](https://img.shields.io/badge/Auth-JWT-000000)

---

## ✨ Features

### 🔐 User Authentication & Security

- **JWT Token-based Authentication**: Secure login and registration system
- **Password Hashing**: BCrypt encryption for user passwords
- **Session Management**: Persistent authentication with SharedPreferences
- **Protected Endpoints**: Secure API routes requiring authentication
- **Profile Management**: View and manage user profiles

### 💾 Data Persistence

- **SQLite Database**: Lightweight, reliable local database
- **Conversation History**: All tone analyses are saved and retrievable
- **User-specific Data**: Each user has their own conversation history
- **Database Management Tools**: Scripts for viewing and managing data

### 🎯 Tone Analysis

- **Accurate Detection**: Identifies tone with confidence scores
- **11 Tone Categories**: Formal, Casual, Professional, Friendly, Persuasive, Inspirational, Empathetic, Authoritative, Enthusiastic, Neutral, and more
- **Context-Aware**: Provide context (email, social media, business) for better analysis

### ✏️ Text Enhancement

- **Multiple Versions**: Get 3+ enhanced versions in different tones
- **Preserve Meaning**: Maintains core message while adjusting tone
- **Actionable Suggestions**: Receive specific improvement recommendations

### 💬 Modern Chat Interface

- **Responsive Login/Register UI**: Beautiful split-screen authentication
- **User Dashboard**: Avatar, profile menu, and logout functionality
- **Conversation History Panel**: Browse all past tone analyses
- **Detail View**: View full analysis with metadata for any conversation
- **Pull-to-Refresh**: Update conversation history on demand
- **Real-Time Feedback**: Instant analysis with typing indicators
- **Cross-Platform**: Works on Windows, macOS, Linux, Web, Android, and iOS

### 🔧 Developer-Friendly

- **RESTful API**: Well-documented FastAPI backend
- **Type-Safe**: Pydantic models and TypeScript-style Dart
- **ORM Integration**: SQLAlchemy for database operations
- **Health Monitoring**: Built-in health checks and error handling
- **CORS Enabled**: Ready for web deployment
- **Database Tools**: Python scripts for database management

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8+ (for backend)
- Flutter 3.7.0+ (for frontend)
- Google Gemini API key ([Get one free](https://makersuite.google.com/app/apikey))

### Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate  # Windows
source venv/bin/activate  # Mac/Linux

# Install dependencies
pip install -r requirements.txt

# Create .env file with your credentials
echo "GEMINI_API_KEY=your_gemini_api_key_here" > .env
echo "JWT_SECRET_KEY=your-super-secret-key-change-this" >> .env
echo "ACCESS_TOKEN_EXPIRE_MINUTES=120" >> .env

# Start the backend server
python main.py
```

Backend runs at: `http://0.0.0.0:8000`

**Database**: SQLite database (`text_toner.db`) is automatically created on first run.

### Frontend Setup

```bash
cd frontend

# Install dependencies
flutter pub get

# Run on your platform of choice
flutter run -d windows  # Windows
flutter run -d chrome   # Web
flutter run -d android  # Android
flutter run -d ios      # iOS
```

**Note**: The frontend is configured to connect to `http://localhost:8000` by default.

---

## 📖 Documentation

### Project Structure

```
textToner/
├── backend/
│   ├── main.py                 # FastAPI application
│   ├── requirements.txt        # Python dependencies
│   ├── view_db.py             # Database viewer script
│   ├── manage_users.py        # User management script
│   ├── text_toner.db          # SQLite database
│   └── .env                   # Environment variables
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── config/
│   │   │   └── app_config.dart      # API configuration
│   │   ├── models/
│   │   │   ├── message.dart         # Message model
│   │   │   ├── user.dart            # User model
│   │   │   ├── auth_result.dart     # Auth response model
│   │   │   └── conversation.dart    # Conversation models
│   │   ├── providers/
│   │   │   ├── auth_provider.dart   # Authentication state
│   │   │   └── chat_provider.dart   # Chat state
│   │   ├── screens/
│   │   │   ├── auth_screen.dart     # Login/Register UI
│   │   │   └── chat_screen.dart     # Main chat UI
│   │   ├── services/
│   │   │   ├── api_client.dart      # HTTP API client
│   │   │   └── async_tone_service.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart       # App styling
│   │   └── widgets/
│   │       ├── chat_bubble.dart
│   │       ├── message_input.dart
│   │       └── ...
│   ├── pubspec.yaml           # Flutter dependencies
│   └── analysis_options.yaml
│
└── README.md                  # This file
```

### API Documentation

When the backend is running, visit:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Key Concepts

**JWT Authentication**

- Tokens expire after 120 minutes (configurable)
- Tokens are stored in SharedPreferences on frontend
- All protected routes require `Authorization: Bearer <token>` header

**Database Models**

- **User**: Stores user credentials and profile
- **Conversation**: Links to user, stores all tone analyses

**State Management**

- **AuthProvider**: Manages user authentication state
- **ChatProvider**: Manages chat messages and conversation history
- Both providers sync automatically

### Common Tasks

**Add a new user:**

```bash
cd backend
python manage_users.py
# Choose option 2 or use /auth/register endpoint
```

**View all conversations:**

```bash
python view_db.py
```

**Clear database:**

```bash
# Delete the database file
rm text_toner.db
# Restart backend to recreate empty database
python main.py
```

**Change JWT expiration:**

```env
# In backend/.env
ACCESS_TOKEN_EXPIRE_MINUTES=240  # 4 hours
```

---

## 🌐 API Endpoints

### Authentication

#### POST /auth/register

Register a new user account.

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123",
    "full_name": "John Doe"
  }'
```

**Response:**

```json
{
  "id": 1,
  "email": "user@example.com",
  "full_name": "John Doe",
  "created_at": "2025-11-09T10:30:00.000000"
}
```

#### POST /auth/login

Login and receive JWT access token.

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user@example.com&password=securepassword123"
```

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "created_at": "2025-11-09T10:30:00.000000"
  }
}
```

#### GET /auth/me

Get current user profile (requires authentication).

```bash
curl -X GET http://localhost:8000/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Tone Analysis

#### POST /analyze-tone

Comprehensive tone analysis with enhanced versions (requires authentication).

```bash
curl -X POST http://localhost:8000/analyze-tone \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "text": "I am really excited about this!",
    "context": "email"
  }'
```

**Response:**

```json
{
  "original_text": "I am really excited about this!",
  "detected_tone": "enthusiastic",
  "confidence": 0.92,
  "tone_category": "enthusiastic",
  "conversation_id": 1,
  "context": "email",
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

### Conversation History

#### GET /conversations

Get all conversations for the authenticated user.

```bash
curl -X GET http://localhost:8000/conversations \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Response:**

```json
[
  {
    "id": 1,
    "original_text": "I am really excited about this!",
    "detected_tone": "enthusiastic",
    "tone_category": "enthusiastic",
    "confidence": 0.92,
    "context": "email",
    "created_at": "2025-11-09T10:35:00.000000"
  }
]
```

#### GET /conversations/{id}

Get detailed conversation analysis.

```bash
curl -X GET http://localhost:8000/conversations/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Response:**

```json
{
  "id": 1,
  "original_text": "I am really excited about this!",
  "detected_tone": "enthusiastic",
  "tone_category": "enthusiastic",
  "confidence": 0.92,
  "context": "email",
  "created_at": "2025-11-09T10:35:00.000000",
  "analysis": {
    "enhanced_versions": [...],
    "suggestions": [...],
    "explanation": "..."
  }
}
```

### Utility Endpoints

#### GET /supported-tones

List all available tone categories.

#### GET /health

Check backend status and Gemini availability.

#### POST /quick-analyze

Fast tone detection without enhancements (no authentication required).

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              Flutter Frontend                   │
│     (Windows/Mac/Linux/Web/Mobile)              │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   Authentication UI (Login/Register)      │ │
│  │   - Email/Password validation             │ │
│  │   - JWT token management                  │ │
│  │   - Session persistence                   │ │
│  └───────────────────┬───────────────────────┘ │
│                      │                          │
│  ┌───────────────────▼───────────────────────┐ │
│  │   Chat UI (Material Design)               │ │
│  │   - User profile menu                     │ │
│  │   - Conversation history panel            │ │
│  │   - Tone analysis display                 │ │
│  └───────────────────┬───────────────────────┘ │
│                      │                          │
│  ┌───────────────────▼───────────────────────┐ │
│  │   State Management (Provider)             │ │
│  │   - AuthProvider                          │ │
│  │   - ChatProvider                          │ │
│  └───────────────────┬───────────────────────┘ │
│                      │                          │
│  ┌───────────────────▼───────────────────────┐ │
│  │   API Client (HTTP + JWT)                 │ │
│  └───────────────────┬───────────────────────┘ │
└──────────────────────┼───────────────────────────┘
                       │
                       │ HTTP/JSON + Bearer Token
                       │
┌──────────────────────▼───────────────────────────┐
│            FastAPI Backend                       │
│              (Python)                            │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │   Authentication Layer                     │ │
│  │   - JWT token verification                 │ │
│  │   - Password hashing (bcrypt)              │ │
│  │   - OAuth2 password flow                   │ │
│  └────────────────────┬───────────────────────┘ │
│                       │                          │
│  ┌────────────────────▼───────────────────────┐ │
│  │   RESTful API Endpoints                    │ │
│  │   - /auth/* (register, login, profile)     │ │
│  │   - /analyze-tone (protected)              │ │
│  │   - /conversations/* (protected)           │ │
│  └────────────────────┬───────────────────────┘ │
│                       │                          │
│  ┌────────────────────▼───────────────────────┐ │
│  │   Business Logic Layer                     │ │
│  │   - Tone Analysis Engine                   │ │
│  │   - Conversation Management                │ │
│  └────────────────────┬───────────────────────┘ │
│                       │                          │
│  ┌────────────────────▼───────────────────────┐ │
│  │   Database Layer (SQLAlchemy ORM)          │ │
│  │   - User model                             │ │
│  │   - Conversation model                     │ │
│  └────────────────────┬───────────────────────┘ │
│                       │                          │
│  ┌────────────────────▼───────────────────────┐ │
│  │   SQLite Database                          │ │
│  │   - users table                            │ │
│  │   - conversations table                    │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │   Google Gemini AI                         │ │
│  │   - Tone detection                         │ │
│  │   - Text enhancement                       │ │
│  └────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

### Database Schema

**users**

- `id` (Integer, Primary Key)
- `email` (String, Unique, Indexed)
- `hashed_password` (String)
- `full_name` (String, Optional)
- `created_at` (DateTime)

**conversations**

- `id` (Integer, Primary Key)
- `user_id` (Integer, Foreign Key → users.id)
- `original_text` (Text)
- `context` (String, Optional)
- `detected_tone` (String)
- `tone_category` (String)
- `confidence` (Float)
- `analysis_json` (Text, stores full analysis)
- `created_at` (DateTime)
- `updated_at` (DateTime)

---

## 📱 Screenshots & Features

### 🔐 Authentication Flow

**Login & Registration**

- Beautiful split-screen responsive design
- Email and password validation
- Real-time error handling
- Smooth transitions between login/register
- "Remember me" functionality via token persistence

**User Profile**

- Avatar with user initials
- Profile menu with logout
- Session management

### 💬 Chat Interface

**Main Chat Screen**

- Modern gradient design
- Real-time tone analysis
- Typing indicators
- Message history
- Quick action buttons

**Tone Analysis Results**

- Confidence score display
- Detected tone with emoji indicators
- Enhanced text versions in multiple tones
- Actionable improvement suggestions
- Explanation of detected tone

### 📊 Conversation History

**History Panel**

- Chronological list of all analyses
- Pull-to-refresh functionality
- Preview of original text
- Tone badges with colors
- Timestamp display

**Detail View**

- Full conversation metadata
- Complete analysis breakdown
- All enhanced versions
- Comprehensive suggestions
- Copy-to-clipboard functionality

### 🎨 UI Features

- 🌈 **Gradient backgrounds** with smooth color transitions
- � **Responsive layout** adapts to any screen size
- 🎭 **Tone-specific colors** for visual feedback
- ✨ **Smooth animations** throughout the app
- � **Loading states** with progress indicators
- ⚠️ **Error handling** with user-friendly messages

---

## 🛠️ Tech Stack

### Backend

- **FastAPI** - Modern Python web framework with automatic OpenAPI docs
- **SQLAlchemy** - SQL toolkit and ORM for database operations
- **SQLite** - Lightweight, serverless database
- **Pydantic** - Data validation using Python type annotations
- **python-jose** - JWT token creation and validation
- **passlib** - Password hashing with bcrypt
- **Google Gemini AI** - Powerful language model for tone analysis
- **Uvicorn** - Lightning-fast ASGI server
- **python-dotenv** - Environment variable management

### Frontend

- **Flutter** - Google's UI toolkit for cross-platform apps
- **Provider** - State management solution
- **shared_preferences** - Persistent key-value storage for tokens
- **http** - HTTP client for API communication
- **Google Fonts** - Beautiful typography
- **Material Design** - Modern, responsive UI components

---

## 🔐 Environment Variables

### Backend (.env)

Create a `.env` file in the `backend` directory:

```env
# Required
GEMINI_API_KEY=your_gemini_api_key_here

# Authentication (Optional - defaults provided)
JWT_SECRET_KEY=your-super-secret-key-change-this-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=120

# Database (Optional - defaults to SQLite)
DATABASE_URL=sqlite:///./text_toner.db
```

**Security Note**: Always use a strong, unique `JWT_SECRET_KEY` in production. Generate one with:

```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Frontend (Optional)

To change the API base URL:

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Production
flutter run --dart-define=API_BASE_URL=https://your-backend-url.com
```

Or update `lib/config/app_config.dart`:

```dart
static const String baseUrl = 'http://localhost:8000';
```

---

## 🧪 Testing

### Backend Testing

```bash
cd backend

# Start server
python main.py

# Test health endpoint
curl http://localhost:8000/health

# Test registration
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","full_name":"Test User"}'

# Test login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=test123"

# Test tone analysis (replace YOUR_TOKEN with the token from login)
curl -X POST http://localhost:8000/analyze-tone \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"text": "This is amazing!"}'

# View database contents
python view_db.py

# Manage users
python manage_users.py
```

### Frontend Testing

```bash
cd frontend

# Run tests
flutter test

# Run app in debug mode
flutter run -d chrome

# Build for production
flutter build web
flutter build windows
flutter build apk
```

### Database Management

**View Database:**

```bash
cd backend
python view_db.py
```

**Manage Users:**

```bash
cd backend
python manage_users.py
# Interactive menu to list, delete, or manage users
```

---

## 📦 Deployment

### Backend Deployment

**Environment Variables Required:**

- `GEMINI_API_KEY` - Your Gemini API key
- `JWT_SECRET_KEY` - Strong secret key for JWT tokens
- `DATABASE_URL` - PostgreSQL URL for production (optional, defaults to SQLite)

#### Heroku

```bash
# Login and create app
heroku login
heroku create text-toner-api

# Set environment variables
heroku config:set GEMINI_API_KEY=your_key
heroku config:set JWT_SECRET_KEY=your_secret_key

# Deploy
git push heroku main

# For PostgreSQL (recommended for production)
heroku addons:create heroku-postgresql:mini
# DATABASE_URL is automatically set
```

#### Railway

1. Connect your GitHub repository
2. Add environment variables:
   - `GEMINI_API_KEY`
   - `JWT_SECRET_KEY`
3. Deploy automatically on push

#### Google Cloud Run

```bash
gcloud run deploy text-toner-api \
  --source . \
  --set-env-vars GEMINI_API_KEY=your_key,JWT_SECRET_KEY=your_secret
```

#### Docker

```dockerfile
# Dockerfile (create in backend directory)
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "main.py"]
```

Build and run:

```bash
docker build -t text-toner-backend .
docker run -p 8000:8000 -e GEMINI_API_KEY=your_key text-toner-backend
```

### Frontend Deployment

#### Web (Firebase Hosting / Netlify / Vercel)

```bash
cd frontend

# Build web app
flutter build web

# Deploy to Firebase
firebase init hosting
firebase deploy

# Or deploy to Netlify/Vercel
# Upload the build/web directory
```

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release

# Or open in Xcode
open ios/Runner.xcworkspace
```

#### Windows

```bash
flutter build windows --release
# Executable in build/windows/runner/Release/
```

#### macOS

```bash
flutter build macos --release
```

#### Linux

```bash
flutter build linux --release
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Ways to Contribute

1. **Report Bugs**: Open an issue describing the bug
2. **Suggest Features**: Share your ideas for new features
3. **Submit Pull Requests**: Fix bugs or add features
4. **Improve Documentation**: Help make the docs better
5. **Share Feedback**: Tell us about your experience

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit: `git commit -m 'Add amazing feature'`
6. Push: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Style

**Python (Backend):**

- Follow PEP 8
- Use type hints
- Add docstrings for functions

**Dart (Frontend):**

- Follow Effective Dart guidelines
- Use meaningful variable names
- Document public APIs

### Testing Guidelines

- Write tests for new features
- Ensure existing tests pass
- Test on multiple platforms when possible

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

```
MIT License

Copyright (c) 2025 Text Toner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **Google Gemini AI** for powerful language understanding
- **Flutter Team** for the amazing cross-platform framework
- **FastAPI** for the modern Python web framework

---

## 📞 Support & FAQ

### Getting Help

1. **Check Documentation**: Review this README and inline code comments
2. **API Documentation**: Visit http://localhost:8000/docs when backend is running
3. **Issues**: Search existing issues or create a new one
4. **Discussions**: Join GitHub Discussions for questions

### Frequently Asked Questions

**Q: How do I get a Gemini API key?**  
A: Visit [Google AI Studio](https://makersuite.google.com/app/apikey) and create a free API key.

**Q: The backend won't start. What should I check?**  
A: Ensure:

- Python 3.8+ is installed
- Virtual environment is activated
- All dependencies are installed: `pip install -r requirements.txt`
- `.env` file exists with valid `GEMINI_API_KEY`

**Q: I forgot my password. How do I reset it?**  
A: Currently, use the database management tool:

```bash
cd backend
python manage_users.py
# Delete user and re-register
```

**Q: Can I use PostgreSQL instead of SQLite?**  
A: Yes! Set `DATABASE_URL` in `.env`:

```env
DATABASE_URL=postgresql://user:password@localhost/dbname
```

**Q: How do I change the JWT token expiration time?**  
A: Set `ACCESS_TOKEN_EXPIRE_MINUTES` in backend `.env` file.

**Q: The frontend can't connect to the backend.**  
A: Check:

- Backend is running on http://localhost:8000
- CORS is enabled (it is by default)
- Firewall isn't blocking port 8000
- Update API URL in `frontend/lib/config/app_config.dart` if needed

**Q: How do I deploy this to production?**  
A: See the [Deployment](#-deployment) section above. Key points:

- Use a strong `JWT_SECRET_KEY`
- Consider PostgreSQL for production
- Enable HTTPS
- Set proper CORS origins

**Q: Can I self-host this?**  
A: Absolutely! The entire stack is self-contained and can run on any server with Python and a web server.

---

## 🚀 Roadmap

### Completed ✅

- [x] Tone analysis with Gemini AI
- [x] Multiple tone enhancements
- [x] User authentication (JWT)
- [x] SQLite database integration
- [x] Conversation history
- [x] Responsive login/register UI
- [x] User profile management
- [x] Cross-platform Flutter app
- [x] Database management tools

### In Progress 🚧

- [ ] Email verification
- [ ] Password reset functionality
- [ ] User preferences/settings

### Planned 📋

- [ ] Voice input support
- [ ] Multiple language support
- [ ] Batch text processing
- [ ] Tone comparison tool
- [ ] Export analysis reports (PDF/CSV)
- [ ] Dark mode theme
- [ ] Mobile app optimizations
- [ ] Real-time collaboration
- [ ] API rate limiting
- [ ] Conversation search and filtering
- [ ] Conversation tags/categories
- [ ] Share analysis results
- [ ] Browser extension
- [ ] Slack/Discord bot integration

---

**Made with ❤️ using FastAPI, Flutter, SQLite, and Google Gemini AI**

---

## 📈 Project Status

| Component      | Status              | Version           |
| -------------- | ------------------- | ----------------- |
| Backend API    | ✅ Production Ready | 1.0.0             |
| Frontend App   | ✅ Production Ready | 1.0.0             |
| Authentication | ✅ Complete         | JWT               |
| Database       | ✅ Complete         | SQLite/PostgreSQL |
| Documentation  | ✅ Complete         | -                 |
| Testing        | 🟡 Basic Coverage   | -                 |
| CI/CD          | ⚪ Not Implemented  | -                 |

**Current Version:** 1.0.0  
**Last Updated:** November 9, 2025

---

## 🌟 Star History

If you find this project useful, please consider giving it a star! ⭐

---

## 📊 Quick Stats

- **Backend**: Python 3.8+, FastAPI, SQLAlchemy
- **Frontend**: Flutter 3.7.0+, Material Design
- **Database**: SQLite (development) / PostgreSQL (production)
- **Authentication**: JWT Bearer tokens
- **AI Model**: Google Gemini 2.5 Flash
- **API Endpoints**: 10+
- **Cross-Platform**: Windows, macOS, Linux, Web, Android, iOS

---

## 🔗 Links

- **Repository**: [github.com/Vijay2k0517/textToner](https://github.com/Vijay2k0517/textToner)
- **API Docs**: http://localhost:8000/docs (when running)
- **Issues**: [github.com/Vijay2k0517/textToner/issues](https://github.com/Vijay2k0517/textToner/issues)
- **Gemini AI**: [ai.google.dev](https://ai.google.dev/)

---

**Happy Toning! 🎨✨**
