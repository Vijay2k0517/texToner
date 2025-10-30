import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_client.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final List<Message> _messages = [];
  bool _isTyping = false;
  final ApiClient _apiClient;
  List<String> _supportedTones = [];

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  List<String> get supportedTones => _supportedTones;

  /// Initialize provider and fetch supported tones
  Future<void> initialize() async {
    try {
      _supportedTones = await _apiClient.getSupportedTones();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch supported tones: $e');
      // Use fallback tones
      _supportedTones = [
        'formal',
        'casual',
        'professional',
        'friendly',
        'persuasive',
        'inspirational',
        'empathetic',
        'authoritative',
        'enthusiastic',
        'neutral',
      ];
    }
  }

  /// Check backend health
  Future<bool> checkBackendHealth() async {
    try {
      final health = await _apiClient.healthCheck();
      return health.status == 'healthy';
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      return false;
    }
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void addUserMessage(String text) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    addMessage(message);
  }

  void addBotMessage(
    String text, {
    String? detectedTone,
    double? confidence,
    String? toneCategory,
    List<EnhancedVersion>? enhancedVersions,
    List<String>? suggestions,
    String? explanation,
  }) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.bot,
      detectedTone: detectedTone,
      confidence: confidence,
      toneCategory: toneCategory,
      enhancedVersions: enhancedVersions,
      suggestions: suggestions,
      explanation: explanation,
    );
    addMessage(message);
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  /// Sends the user message to the backend and appends the tone analysis response.
  /// Returns null on success, or an error message string on failure.
  Future<String?> sendMessageToBackend(
    String userMessage, {
    String? context,
  }) async {
    // Add user message to UI immediately
    addUserMessage(userMessage);

    // Show typing indicator
    setTyping(true);

    try {
      final analysis = await _apiClient.analyzeTone(
        userMessage,
        context: context,
      );

      // Create a comprehensive response message with all analysis data
      final responseText = _formatToneAnalysisResponse(analysis);
      addBotMessage(
        responseText,
        detectedTone: analysis.detectedTone,
        confidence: analysis.confidence,
        toneCategory: analysis.toneCategory,
        enhancedVersions: analysis.enhancedVersions,
        suggestions: analysis.suggestions,
        explanation: analysis.explanation,
      );
      return null;
    } catch (e) {
      // On error, show a friendly error message as a bot message
      final errorMessage =
          e.toString().contains('Server error')
              ? 'Backend server is not responding. Please ensure the backend is running.'
              : 'Sorry, I could not process your request. Please try again.';
      addBotMessage(errorMessage);
      return e.toString();
    } finally {
      setTyping(false);
    }
  }

  String _formatToneAnalysisResponse(ToneAnalysisResponse analysis) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('🎯 **Tone Analysis Complete!**');
    buffer.writeln();

    // Detected tone with confidence
    buffer.writeln(
      '**Detected Tone:** ${_formatTone(analysis.detectedTone)} (${(analysis.confidence * 100).toStringAsFixed(0)}% confidence)',
    );
    buffer.writeln('**Category:** ${analysis.toneCategory}');
    buffer.writeln();

    // Explanation
    if (analysis.explanation.isNotEmpty) {
      buffer.writeln('**Analysis:**');
      buffer.writeln(analysis.explanation);
      buffer.writeln();
    }

    // Enhanced versions
    if (analysis.enhancedVersions.isNotEmpty) {
      buffer.writeln('**✨ Enhanced Versions:**');
      buffer.writeln();
      for (var i = 0; i < analysis.enhancedVersions.length; i++) {
        final enhanced = analysis.enhancedVersions[i];
        buffer.writeln('**${i + 1}. ${enhanced.tone}:**');
        buffer.writeln(enhanced.text);
        if (i < analysis.enhancedVersions.length - 1) {
          buffer.writeln();
        }
      }
      buffer.writeln();
    }

    // Suggestions
    if (analysis.suggestions.isNotEmpty) {
      buffer.writeln('**💡 Suggestions:**');
      for (var suggestion in analysis.suggestions) {
        buffer.writeln('• $suggestion');
      }
    }

    return buffer.toString();
  }

  String _formatTone(String tone) {
    final toneEmojis = {
      'formal': '🎩',
      'casual': '😊',
      'professional': '💼',
      'friendly': '🤝',
      'persuasive': '🎯',
      'inspirational': '✨',
      'empathetic': '❤️',
      'authoritative': '👔',
      'enthusiastic': '🎉',
      'neutral': '😐',
      'positive': '😊',
      'negative': '😔',
    };

    final emoji = toneEmojis[tone.toLowerCase()] ?? '🤔';
    final capitalizedTone = tone[0].toUpperCase() + tone.substring(1);
    return '$emoji $capitalizedTone';
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
