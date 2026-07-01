import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/dev_session.dart';

class TreeSpecies {
  final String id;
  final String name;
  final String commonName;
  final String category;
  final double cost;
  final String emoji;

  TreeSpecies({
    required this.id,
    required this.name,
    required this.commonName,
    required this.category,
    required this.cost,
    required this.emoji,
  });

  factory TreeSpecies.fromJson(Map<String, dynamic> json) {
    return TreeSpecies(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      commonName: json['common_name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      cost: double.tryParse(json['cost']?.toString() ?? '0.0') ?? 0.0,
      emoji: json['emoji']?.toString() ?? '🌳',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'common_name': commonName,
    'category': category,
    'cost': cost,
    'emoji': emoji,
  };
}

class PlantationLocation {
  final String id;
  final String name;
  final String city;
  final bool isActive;

  PlantationLocation({
    required this.id,
    required this.name,
    required this.city,
    this.isActive = true,
  });

  factory PlantationLocation.fromJson(Map<String, dynamic> json) {
    return PlantationLocation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'is_active': isActive,
  };
}

class TreeCategory {
  final String id;
  final String name;
  final String description;

  TreeCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory TreeCategory.fromJson(Map<String, dynamic> json) {
    return TreeCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
}

class MasterDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Local storage keys
  static const String _speciesKey = 'master_species';
  static const String _locationsKey = 'master_locations';
  static const String _categoriesKey = 'master_categories';

  // Seed default data
  static const List<Map<String, dynamic>> _defaultSpecies = [
    {'id': 'sp-1', 'name': 'Azadirachta indica', 'common_name': 'Neem', 'category': 'Medicinal', 'cost': 35.0, 'emoji': '🌿'},
    {'id': 'sp-2', 'name': 'Ficus benghalensis', 'common_name': 'Banyan', 'category': 'Shade', 'cost': 90.0, 'emoji': '🌳'},
    {'id': 'sp-3', 'name': 'Ficus religiosa', 'common_name': 'Peepal', 'category': 'Shade', 'cost': 65.0, 'emoji': '🍃'},
    {'id': 'sp-4', 'name': 'Mangifera indica', 'common_name': 'Mango', 'category': 'Fruit', 'cost': 55.0, 'emoji': '🥭'},
    {'id': 'sp-5', 'name': 'Artocarpus heterophyllus', 'common_name': 'Jackfruit', 'category': 'Fruit', 'cost': 60.0, 'emoji': '🍈'},
  ];

  static const List<Map<String, dynamic>> _defaultLocations = [
    {'id': 'loc-1', 'name': 'Sanjay Gandhi National Park', 'city': 'Mumbai', 'is_active': true},
    {'id': 'loc-2', 'name': 'City Park, Zone A', 'city': 'Pune', 'is_active': true},
    {'id': 'loc-3', 'name': 'Vivekanand Campus Garden', 'city': 'Thane', 'is_active': true},
  ];

  static const List<Map<String, dynamic>> _defaultCategories = [
    {'id': 'cat-1', 'name': 'Medicinal', 'description': 'Trees used for medicine and health'},
    {'id': 'cat-2', 'name': 'Shade', 'description': 'Broad canopy trees that provide shade'},
    {'id': 'cat-3', 'name': 'Fruit', 'description': 'Edible fruit bearing trees'},
  ];

  Future<void> _initializeLocalSeeds() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_speciesKey) == null) {
      await prefs.setString(_speciesKey, jsonEncode(_defaultSpecies));
    }
    if (prefs.getString(_locationsKey) == null) {
      await prefs.setString(_locationsKey, jsonEncode(_defaultLocations));
    }
    if (prefs.getString(_categoriesKey) == null) {
      await prefs.setString(_categoriesKey, jsonEncode(_defaultCategories));
    }
  }

  // --- TREE SPECIES CRUD ---

  Future<List<TreeSpecies>> getTreeSpecies() async {
    await _initializeLocalSeeds();
    if (!DevSession().isActive) {
      try {
        final data = await _supabase.from('tree_species').select().order('name');
        return (data as List).map((x) => TreeSpecies.fromJson(x)).toList();
      } catch (e) {
        debugPrint('Supabase getTreeSpecies failed: $e. Using local cache.');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_speciesKey);
    if (jsonStr != null) {
      final List list = jsonDecode(jsonStr);
      return list.map((x) => TreeSpecies.fromJson(x)).toList();
    }
    return [];
  }

  Future<void> saveTreeSpecies(TreeSpecies species) async {
    if (!DevSession().isActive) {
      try {
        final payload = species.toJson();
        if (species.id.startsWith('sp-')) {
          payload.remove('id'); // let Supabase generate UUID
        }
        await _supabase.from('tree_species').upsert(payload);
        debugPrint('Supabase saveTreeSpecies success');
      } catch (e) {
        debugPrint('Supabase saveTreeSpecies failed: $e. Saving locally.');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final speciesList = await getTreeSpecies();
    final index = speciesList.indexWhere((x) => x.id == species.id);
    final payload = species.toJson();
    if (index >= 0) {
      speciesList[index] = species;
    } else {
      if (species.id.startsWith('sp-')) {
        // Generate new local ID
        payload['id'] = 'sp-${DateTime.now().millisecondsSinceEpoch}';
      }
      speciesList.add(TreeSpecies.fromJson(payload));
    }
    await prefs.setString(_speciesKey, jsonEncode(speciesList.map((x) => x.toJson()).toList()));
  }

  Future<void> deleteTreeSpecies(String id) async {
    if (!DevSession().isActive) {
      try {
        await _supabase.from('tree_species').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteTreeSpecies failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final speciesList = await getTreeSpecies();
    speciesList.removeWhere((x) => x.id == id);
    await prefs.setString(_speciesKey, jsonEncode(speciesList.map((x) => x.toJson()).toList()));
  }

  // --- PLANTATION LOCATIONS CRUD ---

  Future<List<PlantationLocation>> getPlantationLocations() async {
    await _initializeLocalSeeds();
    if (!DevSession().isActive) {
      try {
        final data = await _supabase.from('plantation_locations').select().order('name');
        return (data as List).map((x) => PlantationLocation.fromJson(x)).toList();
      } catch (e) {
        debugPrint('Supabase getPlantationLocations failed: $e. Using local cache.');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_locationsKey);
    if (jsonStr != null) {
      final List list = jsonDecode(jsonStr);
      return list.map((x) => PlantationLocation.fromJson(x)).toList();
    }
    return [];
  }

  Future<void> savePlantationLocation(PlantationLocation loc) async {
    if (!DevSession().isActive) {
      try {
        final payload = loc.toJson();
        if (loc.id.startsWith('loc-')) {
          payload.remove('id');
        }
        await _supabase.from('plantation_locations').upsert(payload);
      } catch (e) {
        debugPrint('Supabase savePlantationLocation failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final locs = await getPlantationLocations();
    final index = locs.indexWhere((x) => x.id == loc.id);
    final payload = loc.toJson();
    if (index >= 0) {
      locs[index] = loc;
    } else {
      if (loc.id.startsWith('loc-')) {
        payload['id'] = 'loc-${DateTime.now().millisecondsSinceEpoch}';
      }
      locs.add(PlantationLocation.fromJson(payload));
    }
    await prefs.setString(_locationsKey, jsonEncode(locs.map((x) => x.toJson()).toList()));
  }

  Future<void> deletePlantationLocation(String id) async {
    if (!DevSession().isActive) {
      try {
        await _supabase.from('plantation_locations').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deletePlantationLocation failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final locs = await getPlantationLocations();
    locs.removeWhere((x) => x.id == id);
    await prefs.setString(_locationsKey, jsonEncode(locs.map((x) => x.toJson()).toList()));
  }

  // --- CATEGORIES CRUD ---

  Future<List<TreeCategory>> getCategories() async {
    await _initializeLocalSeeds();
    if (!DevSession().isActive) {
      try {
        final data = await _supabase.from('categories').select().order('name');
        return (data as List).map((x) => TreeCategory.fromJson(x)).toList();
      } catch (e) {
        debugPrint('Supabase getCategories failed: $e. Using local cache.');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_categoriesKey);
    if (jsonStr != null) {
      final List list = jsonDecode(jsonStr);
      return list.map((x) => TreeCategory.fromJson(x)).toList();
    }
    return [];
  }

  Future<void> saveCategory(TreeCategory cat) async {
    if (!DevSession().isActive) {
      try {
        final payload = cat.toJson();
        if (cat.id.startsWith('cat-')) {
          payload.remove('id');
        }
        await _supabase.from('categories').upsert(payload);
      } catch (e) {
        debugPrint('Supabase saveCategory failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final cats = await getCategories();
    final index = cats.indexWhere((x) => x.id == cat.id);
    final payload = cat.toJson();
    if (index >= 0) {
      cats[index] = cat;
    } else {
      if (cat.id.startsWith('cat-')) {
        payload['id'] = 'cat-${DateTime.now().millisecondsSinceEpoch}';
      }
      cats.add(TreeCategory.fromJson(payload));
    }
    await prefs.setString(_categoriesKey, jsonEncode(cats.map((x) => x.toJson()).toList()));
  }

  Future<void> deleteCategory(String id) async {
    if (!DevSession().isActive) {
      try {
        await _supabase.from('categories').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteCategory failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final cats = await getCategories();
    cats.removeWhere((x) => x.id == id);
    await prefs.setString(_categoriesKey, jsonEncode(cats.map((x) => x.toJson()).toList()));
  }
}
