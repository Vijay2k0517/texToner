class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    required this.createdAt,
    this.fullName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      fullName: json['full_name'] as String?,
    );
  }

  final int id;
  final String email;
  final DateTime createdAt;
  final String? fullName;

  String get displayName =>
      (fullName?.trim().isNotEmpty ?? false) ? fullName!.trim() : email;
}
