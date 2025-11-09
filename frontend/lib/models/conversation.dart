class ConversationSummary {
  ConversationSummary({
    required this.id,
    required this.originalText,
    required this.createdAt,
    this.detectedTone,
    this.toneCategory,
    this.confidence,
    this.context,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as int,
      originalText: json['original_text'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      detectedTone: json['detected_tone'] as String?,
      toneCategory: json['tone_category'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      context: json['context'] as String?,
    );
  }

  final int id;
  final String originalText;
  final String? detectedTone;
  final String? toneCategory;
  final double? confidence;
  final String? context;
  final DateTime createdAt;
}

class ConversationDetail extends ConversationSummary {
  ConversationDetail({
    required super.id,
    required super.originalText,
    required super.createdAt,
    required this.analysis,
    super.detectedTone,
    super.toneCategory,
    super.confidence,
    super.context,
  });

  factory ConversationDetail.fromJson(Map<String, dynamic> json) {
    return ConversationDetail(
      id: json['id'] as int,
      originalText: json['original_text'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      detectedTone: json['detected_tone'] as String?,
      toneCategory: json['tone_category'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      context: json['context'] as String?,
      analysis:
          (json['analysis'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }

  final Map<String, dynamic> analysis;

  List<Map<String, dynamic>> get enhancedVersions {
    final value = analysis['enhanced_versions'];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  List<String> get suggestions {
    final value = analysis['suggestions'];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  String get explanation => analysis['explanation']?.toString() ?? '';
}
