import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _restoreSession();
  }

  final ApiClient _apiClient;
  static const _tokenStorageKey = 'text_toner_access_token';

  UserProfile? _user;
  bool _initializing = true;
  bool _authenticating = false;
  String? _errorMessage;

  UserProfile? get user => _user;
  bool get isLoading => _initializing;
  bool get isAuthenticating => _authenticating;
  bool get isAuthenticated => _user != null && _apiClient.isAuthenticated;
  String? get errorMessage => _errorMessage;

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenStorageKey);
      if (token != null && token.isNotEmpty) {
        _apiClient.setAuthToken(token);
        try {
          final profile = await _apiClient.getProfile();
          _user = profile;
        } catch (_) {
          // Token invalid; clear persisted state.
          await prefs.remove(_tokenStorageKey);
          _apiClient.clearAuthToken();
        }
      }
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _authenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResult = await _apiClient.login(
        email: email,
        password: password,
      );
      await _persistToken(authResult.token);
      _user = authResult.user;
      _errorMessage = null;
      notifyListeners();
      return null;
    } catch (error) {
      final message = _mapError(error);
      _errorMessage = message;
      notifyListeners();
      return message;
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _authenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      final authResult = await _apiClient.login(
        email: email,
        password: password,
      );
      await _persistToken(authResult.token);
      _user = authResult.user;
      _errorMessage = null;
      notifyListeners();
      return null;
    } catch (error) {
      final message = _mapError(error);
      _errorMessage = message;
      notifyListeners();
      return message;
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    if (!isAuthenticated) {
      return;
    }
    try {
      _user = await _apiClient.getProfile();
      notifyListeners();
    } catch (_) {
      // Ignore; profile fetch errors should not break the session.
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenStorageKey);
    _apiClient.clearAuthToken();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> _persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenStorageKey, token);
    _apiClient.setAuthToken(token);
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}
