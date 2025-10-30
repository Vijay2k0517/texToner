# Text Toner - Testing Checklist

Use this checklist to verify that everything is working correctly after setup.

---

## 🔧 Pre-Setup Checklist

### Prerequisites

- [ ] Python 3.8+ installed (`python --version`)
- [ ] Flutter 3.7.0+ installed (`flutter --version`)
- [ ] Git installed (optional but recommended)
- [ ] Google Gemini API key obtained from https://makersuite.google.com/app/apikey
- [ ] Code editor installed (VS Code, Android Studio, etc.)

---

## 🎯 Backend Setup Checklist

### Environment Setup

- [ ] Navigated to `backend` directory
- [ ] Created virtual environment (`python -m venv venv`)
- [ ] Activated virtual environment
  - Windows: `venv\Scripts\activate`
  - Mac/Linux: `source venv/bin/activate`
- [ ] Installed dependencies (`pip install -r requirements.txt`)
- [ ] Created `.env` file in backend directory
- [ ] Added `GEMINI_API_KEY=your_key_here` to `.env` file

### Backend Startup

- [ ] Started backend server (`python main.py`)
- [ ] Server shows "Starting Smart Text Toning Analyzer..."
- [ ] Server shows "✅ Gemini Text Toning Analyzer initialized successfully"
- [ ] No error messages in console
- [ ] Server running on http://localhost:8000

### Backend API Tests

#### Health Check

- [ ] Visit http://localhost:8000/health in browser
- [ ] Response shows `"status": "healthy"`
- [ ] Response shows `"gemini_available": true`
- [ ] Response shows `"has_gemini_library": true`

#### Root Endpoint

- [ ] Visit http://localhost:8000 in browser
- [ ] Response shows service information
- [ ] Response shows `"gemini_initialized": true`

#### API Documentation

- [ ] Visit http://localhost:8000/docs
- [ ] Swagger UI loads successfully
- [ ] All endpoints are visible:
  - POST /analyze-tone
  - POST /quick-analyze
  - GET /supported-tones
  - GET /health
  - GET /

#### Test Analyze Tone Endpoint

Using browser, Postman, or cURL:

```bash
curl -X POST "http://localhost:8000/analyze-tone" \
  -H "Content-Type: application/json" \
  -d '{"text": "I am really excited about this project!"}'
```

- [ ] Request returns 200 OK status
- [ ] Response contains `original_text`
- [ ] Response contains `detected_tone`
- [ ] Response contains `confidence` (0.0 to 1.0)
- [ ] Response contains `tone_category`
- [ ] Response contains `enhanced_versions` (array)
- [ ] Response contains `suggestions` (array)
- [ ] Response contains `explanation`
- [ ] Enhanced versions has at least 3 items
- [ ] Each enhanced version has `tone` and `text` fields

#### Test Quick Analyze Endpoint

```bash
curl -X POST "http://localhost:8000/quick-analyze?text=Hello%20world"
```

- [ ] Request returns 200 OK status
- [ ] Response contains `detected_tone`
- [ ] Response contains `confidence`
- [ ] Response contains `method`

#### Test Supported Tones Endpoint

```bash
curl "http://localhost:8000/supported-tones"
```

- [ ] Request returns 200 OK status
- [ ] Response contains `supported_tones` array
- [ ] Array includes tones like: formal, casual, professional, etc.

---

## 📱 Frontend Setup Checklist

### Environment Setup

- [ ] Navigated to `frontend` directory
- [ ] Ran `flutter pub get` successfully
- [ ] No errors in dependency resolution
- [ ] Verified API URL in `lib/config/app_config.dart`
  - Desktop/Web: `http://localhost:8000`
  - Android Emulator: `http://10.0.2.2:8000`
  - Real Device: Your computer's IP

### Available Devices

- [ ] Ran `flutter devices`
- [ ] At least one device is available
- [ ] Selected target device (chrome, windows, android, etc.)

### Frontend Startup

- [ ] Started frontend (`flutter run -d windows` or your device)
- [ ] App compiles without errors
- [ ] App launches successfully
- [ ] No critical errors in console

---

## 🎨 Frontend UI Tests

### Initial Load

- [ ] App displays welcome screen
- [ ] Welcome message appears: "Welcome to Text Toner! 🎨"
- [ ] Tagline appears: "Tone your text, instantly"
- [ ] Three quick action chips are visible:
  - Make it formal
  - Add clarity
  - Improve tone
- [ ] Input field is visible at bottom
- [ ] Send button is visible

### Backend Health Check (on startup)

- [ ] If backend is running: No warning appears
- [ ] If backend is NOT running: Orange warning appears
  - "⚠️ Backend server may not be running..."

### User Input

- [ ] Can click in input field
- [ ] Can type text
- [ ] Tune icon (⚙️) is visible
- [ ] Send icon is visible
- [ ] Microphone icon is visible (if enabled)

### Send Message

- [ ] Type "I'm really excited about this project!"
- [ ] Click send button
- [ ] User message appears on right side (blue bubble)
- [ ] Message has user avatar icon
- [ ] Typing indicator appears (bot message with animated dots)
- [ ] Typing indicator disappears when response arrives
- [ ] Bot message appears on left side (white bubble)
- [ ] Bot message has bot avatar icon

### Bot Response Content

- [ ] Response shows "🎯 Tone Analysis Complete!"
- [ ] Response shows detected tone with emoji
- [ ] Response shows confidence percentage
- [ ] Response shows tone category
- [ ] Response shows explanation section
- [ ] Response shows "✨ Enhanced Versions:"
- [ ] Response shows 3+ enhanced versions
- [ ] Each version has tone name and enhanced text
- [ ] Response shows "💡 Suggestions:"
- [ ] Suggestions appear as bullet points (•)

### Message Formatting

- [ ] Bold headers are displayed correctly (**text**)
- [ ] Italic notes are displayed correctly (_text_)
- [ ] Emojis are visible (😊, 🎩, 💼, etc.)
- [ ] Colored tone indicators appear
- [ ] Timestamps show on messages

### Quick Actions

Test each quick action chip:

#### "Make it formal"

- [ ] Click "Make it formal"
- [ ] Message sent to backend
- [ ] Response received
- [ ] Enhanced versions include formal tone

#### "Add clarity"

- [ ] Click "Add clarity"
- [ ] Message sent to backend
- [ ] Response received
- [ ] Professional tone detected/suggested

#### "Improve tone"

- [ ] Click "Improve tone"
- [ ] Message sent to backend
- [ ] Response received
- [ ] Tone improvements provided

### Tone Selector

- [ ] Click tune icon (⚙️) in input area
- [ ] Tone selector expands
- [ ] Shows "Target tone:" label
- [ ] Shows multiple tone chips (formal, casual, etc.)
- [ ] Click a tone chip - it highlights
- [ ] Click "None" - deselects tone
- [ ] Click X - tone selector closes
- [ ] Send message with tone selected
- [ ] Context is passed to backend

### History Panel

- [ ] Click menu icon (☰) in header
- [ ] Side panel slides in from left
- [ ] Panel shows "History" title
- [ ] Panel shows list of past user messages
- [ ] Messages are in reverse chronological order
- [ ] Click outside panel - panel closes
- [ ] Click on history item - panel closes

### Scrolling

- [ ] Send multiple messages
- [ ] Chat list scrolls automatically to latest message
- [ ] Can manually scroll up
- [ ] Can manually scroll down

---

## 🧪 Integration Tests

### Test Case 1: Positive Tone

```
Input: "I'm so happy and excited about this amazing opportunity!"
```

- [ ] Sends successfully
- [ ] Detects positive/enthusiastic tone
- [ ] Confidence > 0.7
- [ ] Enhanced versions provided
- [ ] Suggestions provided

### Test Case 2: Formal Tone

```
Input: "Please be advised that the meeting is scheduled for tomorrow morning."
```

- [ ] Sends successfully
- [ ] Detects formal/professional tone
- [ ] Confidence > 0.7
- [ ] Enhanced versions include casual/friendly alternatives
- [ ] Suggestions provided

### Test Case 3: Casual Tone

```
Input: "Hey! What's up? Wanna grab coffee later?"
```

- [ ] Sends successfully
- [ ] Detects casual/friendly tone
- [ ] Confidence > 0.6
- [ ] Enhanced versions include formal alternatives
- [ ] Suggestions provided

### Test Case 4: Negative Tone

```
Input: "This is terrible and I'm really disappointed."
```

- [ ] Sends successfully
- [ ] Detects negative tone
- [ ] Enhanced versions show more constructive phrasing
- [ ] Suggestions for improvement provided

### Test Case 5: Short Text

```
Input: "Thanks!"
```

- [ ] Sends successfully
- [ ] Detects tone (likely casual/friendly)
- [ ] Response received
- [ ] No errors

### Test Case 6: Long Text

```
Input: "I wanted to take a moment to express my sincere gratitude for all the hard work and dedication that you and your team have put into this project. The results have exceeded our expectations, and we are very pleased with the outcome. Your professionalism and attention to detail have been outstanding throughout this entire process."
```

- [ ] Sends successfully (if < 1000 chars)
- [ ] Detects formal/professional tone
- [ ] Enhanced versions provided
- [ ] Suggestions provided

### Test Case 7: Empty Text

```
Input: "" (empty string)
```

- [ ] Send button disabled OR
- [ ] Error message shown
- [ ] No crash

### Test Case 8: Special Characters

```
Input: "Wow! This is AMAZING!!! 🎉🎊"
```

- [ ] Sends successfully
- [ ] Handles emojis correctly
- [ ] Detects enthusiastic tone
- [ ] Response received

---

## 🔥 Error Handling Tests

### Backend Offline

- [ ] Stop backend server
- [ ] Try sending message from frontend
- [ ] Error message appears in UI
- [ ] App doesn't crash
- [ ] Message: "Backend server is not responding..."

### Network Timeout

- [ ] Simulate slow connection (optional)
- [ ] Request times out gracefully
- [ ] User sees error message
- [ ] Can retry

### Invalid API Key

- [ ] Set invalid GEMINI_API_KEY in backend
- [ ] Restart backend
- [ ] Backend shows warning about fallback mode
- [ ] Frontend still works (with fallback analysis)

---

## 📊 Performance Tests

### Response Time

- [ ] Send a message
- [ ] Typing indicator appears immediately
- [ ] Response arrives within 5 seconds (typical)
- [ ] Response arrives within 10 seconds (max)

### Multiple Requests

- [ ] Send 3 messages in quick succession
- [ ] All messages are processed
- [ ] No crashes
- [ ] Responses arrive for all

### UI Responsiveness

- [ ] App remains responsive during API calls
- [ ] Can scroll while waiting for response
- [ ] Can open/close history panel
- [ ] No UI freezing

---

## 🎯 Cross-Platform Tests (if applicable)

### Windows Desktop

- [ ] App runs
- [ ] All features work
- [ ] UI renders correctly

### Web (Chrome)

- [ ] App runs
- [ ] All features work
- [ ] No CORS errors
- [ ] UI renders correctly

### Android Emulator

- [ ] App runs
- [ ] Uses http://10.0.2.2:8000
- [ ] All features work
- [ ] UI renders correctly

### Android Device (if available)

- [ ] App runs
- [ ] Uses computer's IP address
- [ ] All features work
- [ ] UI renders correctly

---

## 📝 Edge Cases

### Very Long Text

- [ ] Try text with 950+ characters
- [ ] Accepts or shows appropriate error
- [ ] If > 1000 chars, shows error message

### Special Context Values

- [ ] Try with context: "email"
- [ ] Try with context: "social media"
- [ ] Try with context: "business"
- [ ] All work correctly

### Rapid Clicking

- [ ] Click send button rapidly
- [ ] Only one request sent
- [ ] No duplicate messages

### Clear History

- [ ] Open history panel
- [ ] Verify messages are shown
- [ ] Close and reopen
- [ ] Messages still there (in current session)

---

## 🎉 Final Checklist

### Documentation

- [ ] Read README.md
- [ ] Read SETUP_INSTRUCTIONS.md
- [ ] Read CHANGES_SUMMARY.md
- [ ] Understand ARCHITECTURE.md
- [ ] Reviewed QUICK_REFERENCE.md

### Configuration

- [ ] Backend .env file created and configured
- [ ] Frontend API URL set correctly for your platform
- [ ] All dependencies installed

### Functionality

- [ ] Backend starts without errors
- [ ] Frontend connects to backend
- [ ] Can send messages
- [ ] Receive tone analysis
- [ ] Enhanced versions display
- [ ] Suggestions display
- [ ] Error handling works

### User Experience

- [ ] UI is responsive
- [ ] Animations are smooth
- [ ] Messages are readable
- [ ] Error messages are clear
- [ ] No crashes or freezes

---

## 📞 If Tests Fail

### Backend Issues

1. Check backend console for errors
2. Verify GEMINI_API_KEY is set correctly
3. Test endpoints with cURL
4. Check http://localhost:8000/docs

### Frontend Issues

1. Check Flutter console for errors
2. Verify API URL in app_config.dart
3. Run `flutter clean && flutter pub get`
4. Run `flutter doctor` to check setup

### Integration Issues

1. Verify backend is running
2. Test backend endpoints directly
3. Check for CORS errors (web only)
4. Verify request/response formats match

---

## ✅ Success Criteria

All tests pass when:

- ✅ Backend starts and initializes Gemini successfully
- ✅ All API endpoints respond correctly
- ✅ Frontend connects to backend on startup
- ✅ Can send messages and receive tone analysis
- ✅ Enhanced versions are displayed correctly
- ✅ Suggestions are shown as bullet points
- ✅ Error handling works gracefully
- ✅ UI is responsive and animations work
- ✅ No crashes or critical errors

---

**Once all checkboxes are ticked, your Text Toner app is production-ready! 🎊**

---

## 📸 Screenshot Checklist

For documentation or presentation, capture:

- [ ] Welcome screen
- [ ] Sample conversation with analysis
- [ ] Enhanced versions display
- [ ] Suggestions section
- [ ] History panel
- [ ] Tone selector expanded
- [ ] Error message (if applicable)

---

**Happy Testing! 🚀**
