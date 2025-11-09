import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TextTonerApp());
}

class TextTonerApp extends StatelessWidget {
  const TextTonerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        ChangeNotifierProvider<AuthProvider>(
          create:
              (context) => AuthProvider(
                apiClient: Provider.of<ApiClient>(context, listen: false),
              ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create:
              (context) => ChatProvider(
                apiClient: Provider.of<ApiClient>(context, listen: false),
              ),
          update: (context, auth, chat) {
            final provider =
                chat ??
                ChatProvider(
                  apiClient: Provider.of<ApiClient>(context, listen: false),
                );
            provider.syncAuth(auth);
            return provider;
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Text Toner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home:
                auth.isLoading
                    ? const _SplashScreen()
                    : auth.isAuthenticated
                    ? const ChatScreen()
                    : const AuthScreen(),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
