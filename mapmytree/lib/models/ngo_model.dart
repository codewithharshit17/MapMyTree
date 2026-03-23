class NgoModel {
  final String uid;
  final String ngoName;
  final String registrationNumber;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final bool isVerified;
  final int totalTreesPlanted;
  final double totalCo2Offset;
  final List<String> activeZones;
  final DateTime createdAt;

  const NgoModel({
    required this.uid,
    required this.ngoName,
    required this.registrationNumber,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    this.isVerified = false,
    this.totalTreesPlanted = 0,
    this.totalCo2Offset = 0.0,
    this.activeZones = const [],
    required this.createdAt,
  });

  factory NgoModel.fromJson(Map<String, dynamic> json) {
    return NgoModel(
      uid: json['uid'] ?? '',
      ngoName: json['ngo_name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      address: json['address'] ?? '',
      isVerified: json['is_verified'] ?? false,
      totalTreesPlanted: json['total_trees_planted'] ?? 0,
      totalCo2Offset: (json['total_co2_offset'] ?? 0.0).toDouble(),
      activeZones: List<String>.from(json['active_zones'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'ngo_name': ngoName,
        'registration_number': registrationNumber,
        'contact_email': contactEmail,
        'contact_phone': contactPhone,
        'address': address,
        'is_verified': isVerified,
        'total_trees_planted': totalTreesPlanted,
        'total_co2_offset': totalCo2Offset,
        'active_zones': activeZones,
        'created_at': createdAt.toIso8601String(),
      };
}
