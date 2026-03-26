class NewTreeModel {
  final String id;
  final String? ngoId;
  final String? requestId;
  final String? plantedForUserId;
  final String treeName;
  final String? treeSpecies;
  final DateTime plantingDate;
  final double latitude;
  final double longitude;
  final String? exactLocation;
  final List<String> photoUrls;
  final String healthStatus; // 'healthy', 'needs_attention', 'dead'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields (not stored in trees table)
  final String? ngoName;
  final String? plantedForUserName;

  const NewTreeModel({
    required this.id,
    this.ngoId,
    this.requestId,
    this.plantedForUserId,
    required this.treeName,
    this.treeSpecies,
    required this.plantingDate,
    required this.latitude,
    required this.longitude,
    this.exactLocation,
    this.photoUrls = const [],
    this.healthStatus = 'healthy',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.ngoName,
    this.plantedForUserName,
  });

  factory NewTreeModel.fromJson(Map<String, dynamic> json) {
    return NewTreeModel(
      id: json['id']?.toString() ?? '',
      ngoId: json['ngo_id'],
      requestId: json['request_id'],
      plantedForUserId: json['planted_for_user_id'],
      treeName: json['tree_name'] ?? '',
      treeSpecies: json['tree_species'],
      plantingDate: json['planting_date'] != null
          ? DateTime.parse(json['planting_date'])
          : DateTime.now(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      exactLocation: json['exact_location'],
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      healthStatus: json['health_status'] ?? 'healthy',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      // Joined fields from profiles table
      ngoName: json['ngo_profile']?['full_name'] ??
          json['ngo_name'],
      plantedForUserName: json['user_profile']?['full_name'] ??
          json['planted_for_user_name'],
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'ngo_id': ngoId,
        'request_id': requestId,
        'planted_for_user_id': plantedForUserId,
        'tree_name': treeName,
        'tree_species': treeSpecies,
        'planting_date': plantingDate.toIso8601String().split('T')[0],
        'latitude': latitude,
        'longitude': longitude,
        'exact_location': exactLocation,
        'photo_urls': photoUrls,
        'health_status': healthStatus,
        'notes': notes,
      };

  String get healthEmoji {
    switch (healthStatus) {
      case 'healthy':
        return '💚';
      case 'needs_attention':
        return '🟡';
      case 'dead':
        return '🔴';
      default:
        return '💚';
    }
  }

  String get healthLabel {
    switch (healthStatus) {
      case 'healthy':
        return 'Healthy';
      case 'needs_attention':
        return 'Needs Attention';
      case 'dead':
        return 'Dead';
      default:
        return 'Unknown';
    }
  }

  String get firstPhotoUrl =>
      photoUrls.isNotEmpty ? photoUrls.first : '';
}
