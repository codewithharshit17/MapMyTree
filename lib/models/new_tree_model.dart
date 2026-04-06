import 'package:flutter/foundation.dart';

class NewTreeModel {
  final String id;
  final String? treeId; // Format: MMT-<timestamp>-<random>
  final String? qrCodeUrl; // URL for QR code
  final String? plantedBy; // Name or ID of the planter
  final String? scientificName; // Scientific name of the tree
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
    this.treeId,
    this.qrCodeUrl,
    this.plantedBy,
    this.scientificName,
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
    try {
      return NewTreeModel(
        id: json['id']?.toString() ?? '',
        treeId: json['tree_id']?.toString() ?? '',
        qrCodeUrl: json['qr_code_url']?.toString() ?? '',
        plantedBy: json['planted_by']?.toString() ?? 'NGO',
        scientificName: json['scientific_name']?.toString() ?? '',
        ngoId: json['ngo_id']?.toString() ?? '',
        requestId: json['request_id']?.toString() ?? '',
        plantedForUserId: json['planted_for_user_id']?.toString() ?? '',
        treeName: json['tree_name']?.toString() ?? 'New Tree',
        treeSpecies: json['tree_species']?.toString() ?? '',
        plantingDate: json['planted_date'] != null
            ? DateTime.tryParse(json['planted_date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
        longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
        exactLocation: json['exact_location']?.toString() ?? '',
        photoUrls: json['photo_urls'] != null ? List<String>.from(json['photo_urls'] as Iterable) : [],
        healthStatus: json['health_status']?.toString() ?? 'healthy',
        notes: json['notes']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        ngoName: json['ngo_profile']?['full_name']?.toString() ?? json['ngo_name']?.toString() ?? 'MapMyTree NGO',
        plantedForUserName: json['user_profile']?['full_name']?.toString() ?? json['planted_for_user_name']?.toString() ?? 'User',
      );
    } catch (e) {
      debugPrint('Error parsing NewTreeModel: $e | JSON: $json');
      return NewTreeModel(
        id: json['id']?.toString() ?? 'err',
        treeName: 'Parse Error',
        plantingDate: DateTime.now(),
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toInsertJson() => {
        'tree_id': treeId,
        'qr_code_url': qrCodeUrl,
        'planted_by': plantedBy,
        'scientific_name': scientificName,
        'ngo_id': ngoId,
        'request_id': requestId,
        'planted_for_user_id': plantedForUserId,
        'tree_name': treeName,
        'tree_species': treeSpecies,
        'planted_date': plantingDate.toIso8601String().split('T')[0],
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
