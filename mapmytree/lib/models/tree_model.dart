class TreeModel {
  final String id;
  final String name;
  final String species;
  final String? commonName;
  final String location;
  final double lat;
  final double lng;
  final double height;
  final double co2;
  final String age;
  final String category;
  final String iconEmoji;
  final bool isFavorite;
  final double healthScore;
  final String plantedBy;
  final String description;
  // Supabase fields
  final String? ngoId;
  final String? sponsoredBy;
  final DateTime? plantedDate;
  final DateTime? lastUpdated;
  final String status; // "alive" | "dead" | "unknown"
  final List<String> photos;
  final String? qrCodeUrl;

  const TreeModel({
    required this.id,
    required this.name,
    required this.species,
    this.commonName,
    required this.location,
    required this.lat,
    required this.lng,
    required this.height,
    required this.co2,
    required this.age,
    required this.category,
    required this.iconEmoji,
    this.isFavorite = false,
    required this.healthScore,
    required this.plantedBy,
    required this.description,
    this.ngoId,
    this.sponsoredBy,
    this.plantedDate,
    this.lastUpdated,
    this.status = 'alive',
    this.photos = const [],
    this.qrCodeUrl,
  });

  factory TreeModel.fromJson(Map<String, dynamic> json) {
    return TreeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['common_name'] ?? '',
      species: json['species'] ?? '',
      commonName: json['common_name'],
      location: json['location'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      co2: (json['co2'] ?? 0.0).toDouble(),
      age: json['age'] ?? '',
      category: json['category'] ?? '',
      iconEmoji: json['icon_emoji'] ?? '🌳',
      isFavorite: json['is_favorite'] ?? false,
      healthScore: (json['health_score'] ?? 0.0).toDouble(),
      plantedBy: json['planted_by'] ?? '',
      description: json['description'] ?? '',
      ngoId: json['ngo_id'],
      sponsoredBy: json['sponsored_by'],
      plantedDate: json['planted_date'] != null
          ? DateTime.parse(json['planted_date'])
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
      status: json['status'] ?? 'alive',
      photos: List<String>.from(json['photos'] ?? []),
      qrCodeUrl: json['qr_code_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'species': species,
        'common_name': commonName ?? name,
        'location': location,
        'lat': lat,
        'lng': lng,
        'height': height,
        'co2': co2,
        'age': age,
        'category': category,
        'icon_emoji': iconEmoji,
        'is_favorite': isFavorite,
        'health_score': healthScore,
        'planted_by': plantedBy,
        'description': description,
        'ngo_id': ngoId,
        'sponsored_by': sponsoredBy,
        'planted_date':
            plantedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'status': status,
        'photos': photos,
        'qr_code_url': qrCodeUrl,
      };

  static List<TreeModel> sampleTrees = const [
    TreeModel(
      id: '1',
      name: 'Heritage Oak',
      species: 'Quercus robur',
      location: 'Central Park, NY',
      lat: 40.7829,
      lng: -73.9654,
      height: 18.5,
      co2: 120.3,
      age: '45 years',
      category: 'Oak',
      iconEmoji: '🌳',
      isFavorite: true,
      healthScore: 92,
      plantedBy: 'City Council',
      description:
          'A majestic English Oak standing tall in Central Park. Known for its iconic lobed leaves and acorns that feed local wildlife.',
    ),
    TreeModel(
      id: '2',
      name: 'Cherry Blossom',
      species: 'Prunus serrulata',
      location: 'Brooklyn Garden, NY',
      lat: 40.6892,
      lng: -73.9442,
      height: 8.2,
      co2: 34.7,
      age: '12 years',
      category: 'Flowering',
      iconEmoji: '🌸',
      isFavorite: false,
      healthScore: 88,
      plantedBy: 'Garden Society',
      description:
          'A beautiful Japanese Cherry Blossom that paints the garden pink every spring.',
    ),
    TreeModel(
      id: '3',
      name: 'Silver Maple',
      species: 'Acer saccharinum',
      location: 'Riverside Park, NY',
      lat: 40.7951,
      lng: -73.9711,
      height: 22.0,
      co2: 198.5,
      age: '60 years',
      category: 'Maple',
      iconEmoji: '🍁',
      isFavorite: true,
      healthScore: 78,
      plantedBy: 'Parks Department',
      description:
          'One of the oldest trees in Riverside Park. Its silver-backed leaves shimmer beautifully in the wind.',
    ),
    TreeModel(
      id: '4',
      name: 'Honey Locust',
      species: 'Gleditsia triacanthos',
      location: 'Madison Ave, NY',
      lat: 40.7614,
      lng: -73.9776,
      height: 14.3,
      co2: 89.2,
      age: '28 years',
      category: 'Locust',
      iconEmoji: '🌿',
      isFavorite: false,
      healthScore: 95,
      plantedBy: 'Street Team',
      description:
          'A resilient street tree that thrives in urban conditions.',
    ),
    TreeModel(
      id: '5',
      name: 'London Plane',
      species: 'Platanus × acerifolia',
      location: '5th Avenue, NY',
      lat: 40.7545,
      lng: -73.9814,
      height: 26.7,
      co2: 267.4,
      age: '80 years',
      category: 'Plane',
      iconEmoji: '🌲',
      isFavorite: false,
      healthScore: 85,
      plantedBy: 'Historical Society',
      description:
          'An iconic London Plane tree with distinctive mottled bark.',
    ),
  ];
}
