class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // "user" or "ngo"
  final int treesSponsored;
  final double totalCo2Offset;
  final String? profilePhotoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.treesSponsored = 0,
    this.totalCo2Offset = 0.0,
    this.profilePhotoUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      treesSponsored: json['trees_sponsored'] ?? 0,
      totalCo2Offset: (json['total_co2_offset'] ?? 0.0).toDouble(),
      profilePhotoUrl: json['profile_photo_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'trees_sponsored': treesSponsored,
        'total_co2_offset': totalCo2Offset,
        'profile_photo_url': profilePhotoUrl,
        'created_at': createdAt.toIso8601String(),
      };

  bool get isNgo => role == 'ngo';
  bool get isUser => role == 'user';
}
