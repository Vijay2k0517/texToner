# Text Toner Flutter Frontend

A modern, engaging Flutter chatbot UI for the Text Toner application. This app provides a beautiful interface for text improvement and tone adjustment through conversational AI.

## Features

✨ **Modern Chat Interface**
- Scrollable chat with bubble-style messages
- Different colors for user (blue) and bot (white) messages
- Smooth animations and micro-interactions
- Typing indicator with bouncing dots animation

🎨 **Beautiful Design**
- Soft, appetizing color scheme (pastel blue, purple accents)
- Neumorphic shadows and rounded corners
- Gradient app bar with branding
- Modern Poppins font family

📱 **Responsive Design**
- Optimized for mobile screens
- Tablet-friendly layout
- Adaptive UI components

⚡ **Interactive Elements**
- Animated send and mic buttons
- Quick action chips in app bar
- Smooth message animations
- Tap feedback and hover states

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── message.dart          # Message data model
├── providers/
│   └── chat_provider.dart    # State management with Provider
├── screens/
│   └── chat_screen.dart      # Main chat interface
├── theme/
│   └── app_theme.dart        # App theme and colors
└── widgets/
    ├── message_bubble.dart   # Chat message bubble widget
    └── input_field.dart      # Text input with send/mic buttons
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone or download the project files**

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following key dependencies:

- `provider: ^6.1.1` - State management
- `google_fonts: ^6.1.0` - Modern typography
- `flutter_staggered_animations: ^1.1.1` - Smooth animations

## Usage

### Chat Interface

1. **Start chatting**: Type your message in the input field at the bottom
2. **Send messages**: Tap the send button or press Enter
3. **Voice input**: Tap the microphone button (placeholder for future implementation)
4. **Quick actions**: Use the quick action chips in the app bar for common requests

### Features in Action

- **Welcome message**: The bot greets you when you first open the app
- **Typing indicator**: Shows animated dots while the bot is "thinking"
- **Message timestamps**: Displays relative time (now, 5m, 2h, etc.)
- **Auto-scroll**: Automatically scrolls to new messages
- **Responsive bubbles**: Message bubbles adapt to content length

### Quick Actions

The app bar includes quick action chips for common text improvement requests:
- "Make it formal" - Request formal tone adjustment
- "Add clarity" - Improve text clarity
- "Improve tone" - General tone enhancement

## Customization

### Colors

Edit `lib/theme/app_theme.dart` to customize the color scheme:

```dart
static const Color primaryBlue = Color(0xFF6B73FF);
static const Color lightBlue = Color(0xFF9BB5FF);
static const Color softPurple = Color(0xFFB19CD9);
```

### Typography

The app uses Google Fonts (Poppins). You can change the font family in the theme file or add custom fonts to the assets.

### Animations

Animation durations and effects can be adjusted in:
- `MessageBubble` - Message appearance animations
- `ChatInputField` - Button tap animations
- `ChatScreen` - Scroll animations

## Future Enhancements

- [ ] Voice input functionality
- [ ] Dark mode support
- [ ] Message history persistence
- [ ] File attachment support
- [ ] Custom themes
- [ ] Push notifications
- [ ] Offline mode

## Architecture

### State Management

The app uses Provider for state management:

- `ChatProvider` manages the message list and typing state
- Messages are stored in memory (can be extended to persist to local storage)
- Bot responses are simulated (ready for API integration)

### Widget Structure

- **ChatScreen**: Main container with app bar and message list
- **MessageBubble**: Individual message display with animations
- **ChatInputField**: Input area with send/mic buttons
- **AppTheme**: Centralized styling and colors

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the Text Toner application. Please refer to the main project for licensing information.

---

Built with ❤️ using Flutter
