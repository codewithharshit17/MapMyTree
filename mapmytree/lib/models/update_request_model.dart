class UpdateRequest {
  final String requestId;
  final String treeId;
  final String submittedBy;
  final String ngoId;
  final String? photoUrl;
  final String notes;
  final double newHealthScore;
  final String status; // "pending" | "approved" | "rejected"
  final DateTime submittedAt;

  const UpdateRequest({
    required this.requestId,
    required this.treeId,
    required this.submittedBy,
    required this.ngoId,
    this.photoUrl,
    required this.notes,
    required this.newHealthScore,
    required this.status,
    required this.submittedAt,
  });

  factory UpdateRequest.fromJson(Map<String, dynamic> json) {
    return UpdateRequest(
      requestId: json['id']?.toString() ?? '',
      treeId: json['tree_id'] ?? '',
      submittedBy: json['submitted_by'] ?? '',
      ngoId: json['ngo_id'] ?? '',
      photoUrl: json['photo_url'],
      notes: json['notes'] ?? '',
      newHealthScore: (json['new_health_score'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tree_id': treeId,
        'submitted_by': submittedBy,
        'ngo_id': ngoId,
        'photo_url': photoUrl,
        'notes': notes,
        'new_health_score': newHealthScore,
        'status': status,
        'submitted_at': submittedAt.toIso8601String(),
      };

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
