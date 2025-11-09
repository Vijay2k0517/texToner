import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_result.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// ApiClient centralizes HTTP calls to the FastAPI backend.
/// Connects to the existing backend endpoints without modifying them.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  String? _authToken;

  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Uri _buildUri(String path) {
    final normalizedBase =
        AppConfig.apiBaseUrl.endsWith('/')
            ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
            : AppConfig.apiBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Map<String, String> _jsonHeaders({bool withAuth = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Map<String, String> _formHeaders({bool withAuth = false}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (withAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  ApiException _buildException(http.Response response) {
    String message = 'Server error (${response.statusCode})';
    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final detail = decoded['detail'] ?? decoded['message'];
          if (detail != null) {
            message = detail.toString();
          }
        } else {
          message = decoded.toString();
        }
      }
    } catch (_) {
      // ignore parsing errors and keep default message
    }
    return ApiException(response.statusCode, message);
  }

  /// Sends the user's text to FastAPI `/analyze-tone` and returns the tone analysis.
  ///
  /// Request: { "text": "user text", "context": "optional context" }
  /// Response: {
  ///   "original_text": "...",
  ///   "detected_tone": "...",
  ///   "confidence": 0.XX,
  ///   "tone_category": "...",
  ///   "enhanced_versions": [{tone: "...", text: "..."}],
  ///   "suggestions": ["...", "..."],
  ///   "explanation": "..."
  /// }
  Future<ToneAnalysisResponse> analyzeTone(
    String text, {
    String? context,
  }) async {
    final uri = _buildUri(AppConfig.analyzeEndpointPath);

    final response = await _http
        .post(
          uri,
          headers: _jsonHeaders(withAuth: true),
          body: jsonEncode({
            'text': text,
            if (context != null) 'context': context,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ToneAnalysisResponse.fromJson(decoded);
      } catch (e) {
        throw ApiException(
          response.statusCode,
          'Failed to parse server response: $e',
        );
      }
    }

    throw _buildException(response);
  }

  /// Quick tone analysis without enhancements
  /// POST /quick-analyze
  Future<QuickAnalysisResponse> quickAnalyze(String text) async {
    final uri = _buildUri(AppConfig.quickAnalyzeEndpointPath);

    final response = await _http
        .post(
          uri,
          headers: _jsonHeaders(withAuth: isAuthenticated),
          body: jsonEncode({'text': text}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return QuickAnalysisResponse.fromJson(decoded);
      } catch (e) {
        throw ApiException(
          response.statusCode,
          'Failed to parse server response: $e',
        );
      }
    }

    throw _buildException(response);
  }

  /// Get list of supported tones
  /// GET /supported-tones
  Future<List<String>> getSupportedTones() async {
    final uri = _buildUri(AppConfig.supportedTonesEndpointPath);

    final response = await _http
        .get(uri, headers: _jsonHeaders(withAuth: isAuthenticated))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final tones = decoded['supported_tones'] as List;
        return tones.map((e) => e.toString()).toList();
      } catch (e) {
        throw ApiException(
          response.statusCode,
          'Failed to parse server response: $e',
        );
      }
    }

    throw _buildException(response);
  }

  /// Health check
  /// GET /health
  Future<HealthResponse> healthCheck() async {
    final uri = _buildUri(AppConfig.healthEndpointPath);

    final response = await _http
        .get(uri, headers: _jsonHeaders())
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return HealthResponse.fromJson(decoded);
      } catch (e) {
        throw ApiException(
          response.statusCode,
          'Failed to parse server response: $e',
        );
      }
    }

    throw _buildException(response);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final uri = _buildUri(AppConfig.loginEndpointPath);

    final response = await _http
        .post(
          uri,
          headers: _formHeaders(),
          body: {'username': email, 'password': password},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          response.statusCode,
          'Invalid authentication response',
        );
      }

      final token = decoded['access_token']?.toString() ?? '';
      final userJson = decoded['user'];

      if (token.isEmpty || userJson is! Map<String, dynamic>) {
        throw ApiException(
          response.statusCode,
          'Invalid authentication response',
        );
      }

      final user = UserProfile.fromJson(userJson);
      setAuthToken(token);
      return AuthResult(token: token, user: user);
    }

    throw _buildException(response);
  }

  Future<UserProfile> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final uri = _buildUri(AppConfig.registerEndpointPath);

    final response = await _http
        .post(
          uri,
          headers: _jsonHeaders(),
          body: jsonEncode({
            'email': email,
            'password': password,
            if (fullName != null && fullName.trim().isNotEmpty)
              'full_name': fullName.trim(),
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          response.statusCode,
          'Invalid registration response',
        );
      }
      return UserProfile.fromJson(decoded);
    }

    throw _buildException(response);
  }

  Future<UserProfile> getProfile() async {
    final uri = _buildUri(AppConfig.profileEndpointPath);

    final response = await _http
        .get(uri, headers: _jsonHeaders(withAuth: true))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(response.statusCode, 'Invalid profile response');
      }
      return UserProfile.fromJson(decoded);
    }

    throw _buildException(response);
  }

  Future<List<ConversationSummary>> getConversationHistory() async {
    final uri = _buildUri(AppConfig.conversationsEndpointPath);

    final response = await _http
        .get(uri, headers: _jsonHeaders(withAuth: true))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ConversationSummary.fromJson)
            .toList();
      }
      throw const FormatException('Unexpected conversation list format');
    }

    throw _buildException(response);
  }

  Future<ConversationDetail> getConversationDetail(int id) async {
    final uri = _buildUri('${AppConfig.conversationsEndpointPath}/$id');

    final response = await _http
        .get(uri, headers: _jsonHeaders(withAuth: true))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          response.statusCode,
          'Unexpected conversation response',
        );
      }
      return ConversationDetail.fromJson(decoded);
    }

    throw _buildException(response);
  }
}

/// Response model for /analyze-tone endpoint
class ToneAnalysisResponse {
  ToneAnalysisResponse({
    required this.originalText,
    required this.detectedTone,
    required this.confidence,
    required this.toneCategory,
    required this.enhancedVersions,
    required this.suggestions,
    required this.explanation,
    this.conversationId,
    this.context,
    this.note,
    this.service,
  });

  factory ToneAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final enhanced = json['enhanced_versions'] as List?;
    final suggestions = json['suggestions'] as List?;
    return ToneAnalysisResponse(
      originalText: json['original_text']?.toString() ?? '',
      detectedTone: json['detected_tone']?.toString() ?? 'neutral',
      confidence:
          (json['confidence'] is num)
              ? (json['confidence'] as num).toDouble()
              : double.tryParse(json['confidence']?.toString() ?? '') ?? 0.0,
      toneCategory: json['tone_category']?.toString() ?? 'neutral',
      enhancedVersions:
          enhanced != null
              ? enhanced
                  .whereType<Map<String, dynamic>>()
                  .map(EnhancedVersion.fromJson)
                  .toList()
              : <EnhancedVersion>[],
      suggestions:
          suggestions != null
              ? suggestions.map((e) => e.toString()).toList()
              : <String>[],
      explanation: json['explanation']?.toString() ?? '',
      conversationId: json['conversation_id'] as int?,
      context: json['context']?.toString(),
      note: json['note']?.toString(),
      service: json['service']?.toString(),
    );
  }

  final String originalText;
  final String detectedTone;
  final double confidence;
  final String toneCategory;
  final List<EnhancedVersion> enhancedVersions;
  final List<String> suggestions;
  final String explanation;
  final int? conversationId;
  final String? context;
  final String? note;
  final String? service;
}

/// Response model for /quick-analyze endpoint
class QuickAnalysisResponse {
  QuickAnalysisResponse({
    required this.text,
    required this.detectedTone,
    required this.confidence,
    required this.method,
  });

  factory QuickAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return QuickAnalysisResponse(
      text: json['text'] ?? '',
      detectedTone: json['detected_tone'] ?? 'neutral',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      method: json['method'] ?? 'unknown',
    );
  }

  final String text;
  final String detectedTone;
  final double confidence;
  final String method;
}

/// Response model for /health endpoint
class HealthResponse {
  HealthResponse({
    required this.status,
    required this.geminiAvailable,
    required this.hasGeminiLibrary,
    required this.rateLimitDelay,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] ?? 'unknown',
      geminiAvailable: json['gemini_available'] ?? false,
      hasGeminiLibrary: json['has_gemini_library'] ?? false,
      rateLimitDelay: (json['rate_limit_delay'] ?? 0).toDouble(),
    );
  }

  final String status;
  final bool geminiAvailable;
  final bool hasGeminiLibrary;
  final double rateLimitDelay;
}
