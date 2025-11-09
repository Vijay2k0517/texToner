import 'user.dart';

class AuthResult {
  AuthResult({required this.token, required this.user});

  final String token;
  final UserProfile user;
}
