import 'package:flutter/material.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final List<Message> _messages = [];
  bool _isTyping = false;
  final ApiClient _apiClient;
  List<String> _supportedTones = [];
  bool _initialized = false;
  bool _isAuthenticated = false;
  bool _loadingHistory = false;
  bool _hasFetchedHistory = false;
  final List<ConversationSummary> _conversationHistory = [];
  final Map<int, ConversationDetail> _conversationCache = {};

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  List<String> get supportedTones => _supportedTones;
  bool get isAuthenticated => _isAuthenticated;
  bool get isHistoryLoading => _loadingHistory;
  List<ConversationSummary> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  /// Initialize provider and fetch supported tones
  Future<void> initialize() async {
    if (_initialized || !_isAuthenticated) {
      return;
    }

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
      notifyListeners();
    } finally {
      _initialized = true;
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

  void syncAuth(AuthProvider auth) {
    final wasAuthenticated = _isAuthenticated;
    final isNowAuthenticated = auth.isAuthenticated;

    if (!isNowAuthenticated) {
      _isAuthenticated = false;
      _initialized = false;
      _hasFetchedHistory = false;
      _loadingHistory = false;
      _conversationHistory.clear();
      _conversationCache.clear();
      clearMessages();
      return;
    }

    _isAuthenticated = true;
    if (!wasAuthenticated) {
      _initialized = false;
      _hasFetchedHistory = false;
      _conversationHistory.clear();
      _conversationCache.clear();
      notifyListeners();
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

  Future<void> refreshConversationHistory({bool force = false}) async {
    if (!_isAuthenticated) {
      return;
    }
    if (_loadingHistory) {
      return;
    }
    if (_hasFetchedHistory && !force) {
      return;
    }

    _loadingHistory = true;
    notifyListeners();

    try {
      final history = await _apiClient.getConversationHistory();
      _conversationHistory
        ..clear()
        ..addAll(history);
      _hasFetchedHistory = true;
    } catch (e) {
      debugPrint('Failed to load conversation history: $e');
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  Future<ConversationDetail?> loadConversationDetail(int id) async {
    if (_conversationCache.containsKey(id)) {
      return _conversationCache[id];
    }
    if (!_isAuthenticated) {
      return null;
    }

    try {
      final detail = await _apiClient.getConversationDetail(id);
      _conversationCache[id] = detail;
      notifyListeners();
      return detail;
    } catch (e) {
      debugPrint('Failed to load conversation detail: $e');
      return null;
    }
  }

  /// Sends the user message to the backend and appends the tone analysis response.
  /// Returns null on success, or an error message string on failure.
  Future<String?> sendMessageToBackend(
    String userMessage, {
    String? context,
  }) async {
    if (!_isAuthenticated) {
      return 'Please log in to analyze your text.';
    }

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
      if (analysis.conversationId != null) {
        await refreshConversationHistory(force: true);
      }
      return null;
    } catch (e) {
      final message = _mapErrorMessage(e);
      addBotMessage(message);
      return message;
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

  String _mapErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401) {
        return 'Your session expired. Please log in again.';
      }
      return error.message;
    }
    final message = error.toString();
    if (message.contains('SocketException')) {
      return 'Backend server is not responding. Please ensure the backend is running.';
    }
    return 'Sorry, I could not process your request. Please try again.';
  }
}
