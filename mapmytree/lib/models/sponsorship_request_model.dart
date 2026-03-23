class SponsorshipRequest {
  final String requestId;
  final String userId;
  final String userName;
  final String userEmail;
  final String ngoId;
  final String treeSpecies;
  final String? message;
  final double amount;
  final String status; // "pending" | "approved" | "rejected"
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SponsorshipRequest({
    required this.requestId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.ngoId,
    required this.treeSpecies,
    this.message,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SponsorshipRequest.fromJson(Map<String, dynamic> json) {
    return SponsorshipRequest(
      requestId: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      ngoId: json['ngo_id'] ?? '',
      treeSpecies: json['tree_species'] ?? '',
      message: json['message'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'ngo_id': ngoId,
        'tree_species': treeSpecies,
        'message': message,
        'amount': amount,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
