class ProfileModel {
  final String id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final bool isVerified;
  final String role; // 'user' or 'ngo'
  final String? avatarUrl;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.isVerified = true,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      isVerified: json['is_verified'] ?? true, // defaults to true for backwards compatibility
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
        'phone_number': phoneNumber,
        'is_verified': isVerified,
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
