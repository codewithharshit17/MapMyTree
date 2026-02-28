class TreeModel {
  final String id;
  final String name;
  final String species;
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

  const TreeModel({
    required this.id,
    required this.name,
    required this.species,
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
  });

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
      description: 'A majestic English Oak standing tall in Central Park. Known for its iconic lobed leaves and acorns that feed local wildlife.',
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
      description: 'A beautiful Japanese Cherry Blossom that paints the garden pink every spring. A beloved landmark for photographers.',
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
      description: 'One of the oldest trees in Riverside Park. Its silver-backed leaves shimmer beautifully in the wind.',
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
      description: 'A resilient street tree that thrives in urban conditions. Its feathery leaves create a gentle dappled shade.',
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
      description: 'An iconic London Plane tree with distinctive mottled bark. One of the most common trees lining NYC\'s famous avenues.',
    ),
  ];
}
