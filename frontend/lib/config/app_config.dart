class AppConfig {
  // App information
  static const String appName = 'Text Toner';
  static const String appTagline = 'Tone your text, instantly';
  static const String appVersion = '1.0.0';

  // API configuration
  // Change this to your deployed FastAPI base URL when needed.
  // You can also override at runtime using --dart-define (see README instructions).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'http://localhost:8000', // Use http://10.0.2.2:8000 for Android emulator
  );
  static const String analyzeEndpointPath = '/analyze-tone';
  static const String quickAnalyzeEndpointPath = '/quick-analyze';
  static const String supportedTonesEndpointPath = '/supported-tones';
  static const String healthEndpointPath = '/health';

  // Animation durations
  static const Duration messageAnimationDuration = Duration(milliseconds: 600);
  static const Duration typingIndicatorDuration = Duration(milliseconds: 1500);
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);
  static const Duration buttonTapDuration = Duration(milliseconds: 150);

  // UI constants
  static const double messageBubbleMaxWidth = 0.75;
  static const double avatarSize = 32.0;
  static const double borderRadius = 25.0;
  static const double messageBorderRadius = 20.0;

  // Time formatting
  static const int timeDisplayMinutes = 2;

  // Demo messages
  static const String welcomeMessage =
      'Welcome to Text Toner! 🎨\n\n'
      "I'm here to help you improve your text by adjusting tone, "
      'enhancing clarity, and making it more engaging. '
      "Just share your text and tell me what you'd like to improve!";

  static const List<String> quickActions = [
    'Make it formal',
    'Add clarity',
    'Improve tone',
  ];

  static const Map<String, String> quickActionResponses = {
    'Make it formal':
        "I can help make your text more formal and professional. Please share the text you'd like me to improve!",
    'Add clarity':
        "I'll help enhance the clarity of your text. Share your content and I'll suggest improvements for better understanding.",
    'Improve tone':
        'I can help adjust the tone of your text to make it more engaging and appropriate. What would you like me to work on?',
  };
}
