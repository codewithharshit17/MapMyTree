import 'package:flutter/foundation.dart';
class RequestModel {
  final String id;
  final String userId;
  final String treeType;
  final String? preferredLocation;
  final String? description;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime createdAt;

  // Joined fields
  final String? userName;

  const RequestModel({
    required this.id,
    required this.userId,
    required this.treeType,
    this.preferredLocation,
    this.description,
    this.status = 'pending',
    required this.createdAt,
    this.userName,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    try {
      return RequestModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        treeType: json['tree_type']?.toString() ?? 'Tree',
        preferredLocation: json['preferred_location']?.toString(),
        description: json['description']?.toString(),
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        userName: json['profiles']?['full_name']?.toString() ?? json['user_name']?.toString() ?? 'User',
      );
    } catch (e) {
      debugPrint('Error parsing RequestModel: $e | JSON: $json');
      return RequestModel(
        id: json['id']?.toString() ?? 'err',
        userId: '',
        treeType: 'Parse Error',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'tree_type': treeType,
        'preferred_location': preferredLocation,
        'description': description,
        'status': status,
      };

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';

  String get statusEmoji {
    switch (status) {
      case 'pending':
        return '🟡';
      case 'in_progress':
        return '🔵';
      case 'completed':
        return '✅';
      default:
        return '🟡';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  /// Equality is based on [id] so DropdownButtonFormField can match items.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
