class Message {
  Message({
    required this.id,
    required this.text,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
    this.detectedTone,
    this.confidence,
    this.toneCategory,
    this.enhancedVersions,
    this.suggestions,
    this.explanation,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.bot,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isTyping: json['isTyping'] ?? false,
      detectedTone: json['detectedTone'],
      confidence: json['confidence'],
      toneCategory: json['toneCategory'],
      enhancedVersions:
          json['enhancedVersions'] != null
              ? List<EnhancedVersion>.from(
                (json['enhancedVersions'] as List).map(
                  (x) => EnhancedVersion.fromJson(x),
                ),
              )
              : null,
      suggestions:
          json['suggestions'] != null
              ? List<String>.from(json['suggestions'])
              : null,
      explanation: json['explanation'],
    );
  }
  final String id;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final bool isTyping;
  final String? detectedTone;
  final double? confidence;
  final String? toneCategory;
  final List<EnhancedVersion>? enhancedVersions;
  final List<String>? suggestions;
  final String? explanation;

  Message copyWith({
    String? id,
    String? text,
    MessageType? type,
    DateTime? timestamp,
    bool? isTyping,
    String? detectedTone,
    double? confidence,
    String? toneCategory,
    List<EnhancedVersion>? enhancedVersions,
    List<String>? suggestions,
    String? explanation,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      detectedTone: detectedTone ?? this.detectedTone,
      confidence: confidence ?? this.confidence,
      toneCategory: toneCategory ?? this.toneCategory,
      enhancedVersions: enhancedVersions ?? this.enhancedVersions,
      suggestions: suggestions ?? this.suggestions,
      explanation: explanation ?? this.explanation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isTyping': isTyping,
      'detectedTone': detectedTone,
      'confidence': confidence,
      'toneCategory': toneCategory,
      'enhancedVersions': enhancedVersions?.map((x) => x.toJson()).toList(),
      'suggestions': suggestions,
      'explanation': explanation,
    };
  }
}

class EnhancedVersion {
  EnhancedVersion({required this.tone, required this.text});

  factory EnhancedVersion.fromJson(Map<String, dynamic> json) {
    return EnhancedVersion(tone: json['tone'] ?? '', text: json['text'] ?? '');
  }

  final String tone;
  final String text;

  Map<String, dynamic> toJson() {
    return {'tone': tone, 'text': text};
  }
}

enum MessageType { user, bot, typing }
