class TreeUpdateModel {
  final String id;
  final String treeId;
  final String? ngoId;
  final String? updateNote;
  final List<String> photoUrls;
  final String? healthStatus;
  final DateTime createdAt;

  const TreeUpdateModel({
    required this.id,
    required this.treeId,
    this.ngoId,
    this.updateNote,
    this.photoUrls = const [],
    this.healthStatus,
    required this.createdAt,
  });

  factory TreeUpdateModel.fromJson(Map<String, dynamic> json) {
    return TreeUpdateModel(
      id: json['id']?.toString() ?? '',
      treeId: json['tree_id'] ?? '',
      ngoId: json['ngo_id'],
      updateNote: json['update_note'],
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      healthStatus: json['health_status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'tree_id': treeId,
        'ngo_id': ngoId,
        'update_note': updateNote,
        'photo_urls': photoUrls,
        'health_status': healthStatus,
      };
}
