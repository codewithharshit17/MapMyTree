class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? type; // e.g., 'planting_completed', 'anniversary'
  final String? imageUrl;
  final String? relatedTreeId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.imageUrl,
    this.relatedTreeId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    message: json['message']?.toString() ?? '',
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    isRead: json['is_read'] == true || json['is_read'] == 'true',
    type: json['type']?.toString(),
    imageUrl: json['image_url']?.toString(),
    relatedTreeId: json['related_tree_id']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'message': message,
    'is_read': isRead,
    'type': type,
    'image_url': imageUrl,
    'related_tree_id': relatedTreeId,
  };
}
