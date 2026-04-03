class ProfileModel {
  final String id;
  final String? fullName;
  final String? email;
  final String role; // 'user' or 'ngo'
  final String? avatarUrl;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    this.fullName,
    this.email,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'] ?? 'user',
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };

  String get displayName => fullName ?? email ?? 'Unknown';
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return '?';
  }
}
