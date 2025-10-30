import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/message.dart';

/// ApiClient centralizes HTTP calls to the FastAPI backend.
/// Connects to the existing backend endpoints without modifying them.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Uri _buildUri(String path) {
    final normalizedBase =
        AppConfig.apiBaseUrl.endsWith('/')
            ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
            : AppConfig.apiBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
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
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
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
        throw Exception('Failed to parse server response: $e');
      }
    }

    // Attempt to extract error message from backend
    try {
      final decoded = jsonDecode(response.body);
      final errorMsg =
          decoded is Map<String, dynamic>
              ? (decoded['detail']?.toString() ??
                  decoded['message']?.toString())
              : decoded.toString();
      throw Exception('Server error (${response.statusCode}): $errorMsg');
    } catch (_) {
      throw Exception('Server error (${response.statusCode})');
    }
  }

  /// Quick tone analysis without enhancements
  /// POST /quick-analyze
  Future<QuickAnalysisResponse> quickAnalyze(String text) async {
    final uri = _buildUri(AppConfig.quickAnalyzeEndpointPath);

    final response = await _http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'text': text}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return QuickAnalysisResponse.fromJson(decoded);
      } catch (e) {
        throw Exception('Failed to parse server response: $e');
      }
    }

    throw Exception('Server error (${response.statusCode})');
  }

  /// Get list of supported tones
  /// GET /supported-tones
  Future<List<String>> getSupportedTones() async {
    final uri = _buildUri(AppConfig.supportedTonesEndpointPath);

    final response = await _http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final tones = decoded['supported_tones'] as List;
        return tones.map((e) => e.toString()).toList();
      } catch (e) {
        throw Exception('Failed to parse server response: $e');
      }
    }

    throw Exception('Server error (${response.statusCode})');
  }

  /// Health check
  /// GET /health
  Future<HealthResponse> healthCheck() async {
    final uri = _buildUri(AppConfig.healthEndpointPath);

    final response = await _http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return HealthResponse.fromJson(decoded);
      } catch (e) {
        throw Exception('Failed to parse server response: $e');
      }
    }

    throw Exception('Server error (${response.statusCode})');
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
  });

  factory ToneAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return ToneAnalysisResponse(
      originalText: json['original_text'] ?? '',
      detectedTone: json['detected_tone'] ?? 'neutral',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      toneCategory: json['tone_category'] ?? 'neutral',
      enhancedVersions:
          json['enhanced_versions'] != null
              ? List<EnhancedVersion>.from(
                (json['enhanced_versions'] as List).map(
                  (x) => EnhancedVersion.fromJson(x),
                ),
              )
              : [],
      suggestions:
          json['suggestions'] != null
              ? List<String>.from(json['suggestions'])
              : [],
      explanation: json['explanation'] ?? '',
    );
  }

  final String originalText;
  final String detectedTone;
  final double confidence;
  final String toneCategory;
  final List<EnhancedVersion> enhancedVersions;
  final List<String> suggestions;
  final String explanation;
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
