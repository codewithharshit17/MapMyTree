import 'package:flutter/foundation.dart';

class RequestModel {
  final String id;
  final String userId;
  final String treeType;
  final String? preferredLocation;
  final String? description;
  final String? treeName;
  final String? occasion;
  final String? occasionDate;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime createdAt;

  // Payment fields
  final String? paymentScreenshotUrl;
  final String paymentStatus; // 'unpaid', 'pending_verification', 'verified'
  final int? plantCost;

  // Joined fields
  final String? userName;

  const RequestModel({
    required this.id,
    required this.userId,
    required this.treeType,
    this.preferredLocation,
    this.description,
    this.treeName,
    this.occasion,
    this.occasionDate,
    this.status = 'pending',
    required this.createdAt,
    this.paymentScreenshotUrl,
    this.paymentStatus = 'unpaid',
    this.plantCost,
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
        treeName: json['tree_name']?.toString(),
        occasion: json['occasion']?.toString(),
        occasionDate: json['occasion_date']?.toString(),
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        paymentScreenshotUrl: json['payment_screenshot_url']?.toString(),
        paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
        plantCost: json['plant_cost'] != null
            ? int.tryParse(json['plant_cost'].toString())
            : null,
        userName: json['profiles']?['full_name']?.toString() ??
            json['user_name']?.toString() ??
            'User',
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
        'tree_name': treeName,
        'occasion': occasion,
        'occasion_date': occasionDate,
        'status': status,
        'payment_status': paymentStatus,
        'plant_cost': plantCost,
        'payment_screenshot_url': paymentScreenshotUrl,
      };

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';

  bool get isPaymentVerified => paymentStatus == 'verified';
  bool get isPaymentPendingVerification =>
      paymentStatus == 'pending_verification';

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'verified':
        return 'Payment Verified ✅';
      case 'pending_verification':
        return 'Verifying Payment ⏳';
      default:
        return 'Payment Pending 💳';
    }
  }

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RequestModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
