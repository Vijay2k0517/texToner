# Text Toner - Setup Instructions

## Overview

Text Toner is a smart text tone analyzer powered by Google Gemini AI. It analyzes text tone, provides confidence scores, and generates enhanced versions of your text in different tones.

**Architecture:**

- **Backend**: FastAPI (Python) with Google Gemini AI integration
- **Frontend**: Flutter (cross-platform mobile/desktop app)

---

## Prerequisites

### Backend Requirements

- Python 3.8 or higher
- pip (Python package manager)
- Google Gemini API key

### Frontend Requirements

- Flutter SDK 3.7.0 or higher
- Dart SDK
- Android Studio (for Android) or Xcode (for iOS)
- VS Code or Android Studio with Flutter plugins

---

## Backend Setup

### 1. Navigate to Backend Directory

```bash
cd backend
```

### 2. Create Virtual Environment (Recommended)

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Mac/Linux
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Set Up Environment Variables

Create a `.env` file in the `backend` directory:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

**To get a Gemini API key:**

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key and paste it in your `.env` file

### 5. Start the Backend Server

```bash
# Default: runs on http://localhost:8000
python main.py

# Or using uvicorn directly:
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 6. Verify Backend is Running

Open your browser and visit:

- **Root endpoint**: http://localhost:8000
- **Health check**: http://localhost:8000/health
- **API documentation**: http://localhost:8000/docs

You should see a response indicating the server is running and Gemini is initialized.

---

## Frontend Setup

### 1. Navigate to Frontend Directory

```bash
cd frontend
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure API Base URL

The frontend is pre-configured to connect to `http://localhost:8000`.

**If you need to change it:**

Edit `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000', // Change this to your backend URL
);
```

**For Android Emulator:**
Use `http://10.0.2.2:8000` instead of `http://localhost:8000`

**For Real Device:**
Use your computer's IP address, e.g., `http://192.168.1.100:8000`

### 4. Run the Frontend

**Option A: Using VS Code**

1. Open the `frontend` folder in VS Code
2. Press `F5` or click "Run > Start Debugging"
3. Select your target device (Chrome, Android, iOS, etc.)

**Option B: Using Command Line**

```bash
# For web
flutter run -d chrome

# For Windows desktop
flutter run -d windows

# For Android
flutter run -d android

# For iOS (Mac only)
flutter run -d ios

# List available devices
flutter devices
```

### 5. Test the Connection

Once the app starts:

1. You'll see a welcome message
2. Try typing a message like: "I am very happy about this project"
3. The backend will analyze the tone and provide enhanced versions

If you see an orange warning about the backend not responding, ensure:

- The backend server is running on port 8000
- The API base URL is correctly configured
- There are no firewall issues blocking the connection

---

## API Endpoints (Backend)

The backend exposes the following endpoints:

### 1. **POST /analyze-tone**

Main endpoint for tone analysis.

**Request:**

```json
{
  "text": "Your text here",
  "context": "optional context like email, social media, etc."
}
```

**Response:**

```json
{
  "original_text": "Your text here",
  "detected_tone": "friendly",
  "confidence": 0.85,
  "tone_category": "friendly",
  "enhanced_versions": [
    { "tone": "Formal", "text": "Enhanced formal version..." },
    { "tone": "Casual", "text": "Enhanced casual version..." },
    { "tone": "Professional", "text": "Enhanced professional version..." }
  ],
  "suggestions": [
    "Consider using more specific language",
    "Add context for better clarity"
  ],
  "explanation": "The text exhibits a friendly tone with positive sentiment..."
}
```

### 2. **POST /quick-analyze**

Quick tone detection without enhancements.

**Request:**

```bash
curl -X POST "http://localhost:8000/quick-analyze?text=Hello%20world"
```

**Response:**

```json
{
  "text": "Hello world",
  "detected_tone": "casual",
  "confidence": 0.6,
  "method": "keyword-analysis"
}
```

### 3. **GET /supported-tones**

Get list of all supported tone categories.

**Response:**

```json
{
  "supported_tones": [
    "formal",
    "casual",
    "professional",
    "friendly",
    "persuasive",
    "inspirational",
    "empathetic",
    "authoritative",
    "enthusiastic",
    "neutral"
  ],
  "description": "Available tone categories for analysis and enhancement"
}
```

### 4. **GET /health**

Health check endpoint.

**Response:**

```json
{
  "status": "healthy",
  "gemini_available": true,
  "has_gemini_library": true,
  "rate_limit_delay": 2.0
}
```

### 5. **GET /**

Root endpoint with service info.

**Response:**

```json
{
  "message": "Smart Text Toning Analyzer with Gemini",
  "status": "running",
  "gemini_initialized": true,
  "service": "text-toning-analyzer"
}
```

---

## Troubleshooting

### Backend Issues

**1. "GEMINI_API_KEY not found"**

- Ensure you created the `.env` file in the `backend` directory
- Check that your API key is valid
- Make sure you're not using quotes around the API key in `.env`

**2. "No working Gemini model found"**

- Verify your API key is active
- Check your Google Cloud billing (free tier should work)
- The backend will fall back to smart analysis if Gemini fails

**3. "Port 8000 already in use"**

```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <process_id> /F

# Mac/Linux
lsof -ti:8000 | xargs kill -9
```

### Frontend Issues

**1. "Backend server is not responding"**

- Verify backend is running: `curl http://localhost:8000/health`
- Check API base URL in `app_config.dart`
- For Android emulator, use `http://10.0.2.2:8000`

**2. "Flutter dependencies error"**

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

**3. "Device not found"**

```bash
# Check available devices
flutter devices

# For web, ensure Chrome is installed
# For Android, ensure emulator is running or device is connected
# For iOS, ensure Xcode is properly set up (Mac only)
```

**4. CORS errors (Web only)**
The backend has CORS enabled for all origins. If you still face issues:

- Clear browser cache
- Try in incognito mode
- Check browser console for specific errors

---

## Testing the Integration

### 1. Test Backend Directly

```bash
# Health check
curl http://localhost:8000/health

# Analyze tone
curl -X POST "http://localhost:8000/analyze-tone" \
  -H "Content-Type: application/json" \
  -d '{"text": "I am really excited about this amazing project!"}'

# Quick analyze
curl -X POST "http://localhost:8000/quick-analyze?text=Hello%20there"

# Supported tones
curl http://localhost:8000/supported-tones
```

### 2. Test Frontend Features

1. **Welcome Message**: Should appear on app launch
2. **Quick Actions**: Tap "Make it formal", "Add clarity", "Improve tone"
3. **Text Analysis**: Type a message and send
4. **Tone Selector**: Tap the tune icon to select a context/tone
5. **History Panel**: Tap the menu icon to see conversation history

---

## Project Structure

```
textToner/
├── backend/
│   ├── main.py                 # FastAPI application
│   ├── requirements.txt        # Python dependencies
│   ├── .env                    # Environment variables (create this)
│   └── __pycache__/
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   ├── config/
│   │   │   └── app_config.dart # Configuration (API URL, etc.)
│   │   ├── models/
│   │   │   └── message.dart    # Data models
│   │   ├── providers/
│   │   │   └── chat_provider.dart # State management
│   │   ├── screens/
│   │   │   └── chat_screen.dart # Main UI screen
│   │   ├── services/
│   │   │   └── api_client.dart # Backend API integration
│   │   ├── theme/
│   │   │   └── app_theme.dart  # UI theming
│   │   └── widgets/
│   │       ├── input_field.dart
│   │       └── message_bubble.dart
│   ├── pubspec.yaml            # Flutter dependencies
│   └── android/                # Android-specific files
│       ios/                    # iOS-specific files
│       web/                    # Web-specific files
│       windows/                # Windows-specific files
│
├── SETUP_INSTRUCTIONS.md       # This file
└── README.md                   # Project overview
```

---

## Development Tips

### Backend Development

1. **Enable debug logging:**

   ```python
   logging.basicConfig(level=logging.DEBUG)
   ```

2. **Test with Postman/Insomnia:**

   - Import the API endpoints
   - Test different text inputs and contexts

3. **Monitor rate limits:**
   - Gemini has rate limits on the free tier
   - The backend automatically manages delays

### Frontend Development

1. **Hot reload:** Press `r` in the terminal while running
2. **Hot restart:** Press `R` in the terminal
3. **View logs:** Use VS Code's Debug Console or terminal output

4. **Override API URL at runtime:**
   ```bash
   flutter run --dart-define=API_BASE_URL=http://your-server:8000
   ```

---

## Deployment

### Backend Deployment

**Option 1: Heroku**

1. Create `Procfile`:
   ```
   web: uvicorn main:app --host 0.0.0.0 --port $PORT
   ```
2. Deploy: `git push heroku main`

**Option 2: Railway**

1. Connect GitHub repo
2. Set environment variable `GEMINI_API_KEY`
3. Deploy automatically

**Option 3: Google Cloud Run**

1. Create `Dockerfile`
2. Build and deploy container

### Frontend Deployment

**Web:**

```bash
flutter build web
# Deploy the `build/web` folder to Firebase Hosting, Netlify, or Vercel
```

**Android:**

```bash
flutter build apk --release
# APK will be in build/app/outputs/flutter-apk/
```

**iOS:**

```bash
flutter build ios --release
# Build with Xcode and submit to App Store
```

**Windows:**

```bash
flutter build windows --release
```

---

## What Was Changed and Why

### Changes Made to Frontend

1. **API Client (`api_client.dart`)**

   - ✅ Changed endpoint from `/api/v1/tone/analyze-tone` to `/analyze-tone` (matches backend)
   - ✅ Updated request format to use `{text, context}` instead of `{text, target_tone}`
   - ✅ Updated response parsing to handle backend's actual structure with `enhanced_versions` array
   - ✅ Added support for all backend endpoints: `/quick-analyze`, `/supported-tones`, `/health`

2. **Models (`message.dart`)**

   - ✅ Added `EnhancedVersion` class to match backend's enhanced_versions structure
   - ✅ Added fields: `confidence`, `toneCategory`, `enhancedVersions`, `suggestions`, `explanation`
   - ✅ Removed obsolete `improvisedText` field

3. **Provider (`chat_provider.dart`)**

   - ✅ Updated to use new API response structure
   - ✅ Added `initialize()` method to fetch supported tones from backend
   - ✅ Added `checkBackendHealth()` to verify backend connectivity
   - ✅ Enhanced message formatting to display all tone analysis data
   - ✅ Added emoji indicators for different tone types

4. **Configuration (`app_config.dart`)**

   - ✅ Updated API base URL to `http://localhost:8000` (desktop default)
   - ✅ Added all backend endpoint paths
   - ✅ Added comments for different platform configurations

5. **UI Components**
   - ✅ Enhanced message bubble to display structured analysis results
   - ✅ Added health check on app startup
   - ✅ Improved error messages with backend connectivity info
   - ✅ Updated tone selector with backend's supported tones

### Why These Changes

- **No Backend Modifications**: Your backend is perfect as-is. All changes are frontend-only.
- **Exact API Matching**: Frontend now matches backend's exact request/response structure
- **Better UX**: Users see detailed tone analysis, confidence scores, and multiple enhanced versions
- **Error Handling**: Clear feedback when backend is unavailable
- **Future-Proof**: Frontend automatically adapts to backend's supported tones list

---

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Verify backend logs for errors
3. Check Flutter console for frontend errors
4. Ensure all dependencies are installed correctly

---

## License

This project is for demonstration purposes. Modify and use as needed.

---

**Enjoy using Text Toner! 🎨**
