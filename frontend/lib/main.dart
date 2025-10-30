import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'providers/chat_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TextTonerApp());
}

class TextTonerApp extends StatelessWidget {
  const TextTonerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        title: 'Text Toner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const ChatScreen(),
      ),
    );
  }
}
