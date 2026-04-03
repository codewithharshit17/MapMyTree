import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/new_tree_model.dart';
import '../models/request_model.dart';

/// Offline-first local storage for trees and requests.
/// Used as a fallback when Supabase is unavailable (e.g., during dev without auth).
class LocalTreeStorage {
  static const _treesKey = 'local_trees';
  static const _requestsKey = 'local_requests';

  // ─── TREES ───────────────────────────────────────────────────────────────

  /// Save a tree to local storage. Returns the generated local ID.
  static Future<String> saveTree(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getAllTreesRaw();
      final id = 'local-tree-${DateTime.now().millisecondsSinceEpoch}';
      data['id'] = id;
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      existing.add(data);
      await prefs.setString(_treesKey, jsonEncode(existing));
      debugPrint('LocalTreeStorage: saved tree $id');
      return id;
    } catch (e) {
      debugPrint('LocalTreeStorage saveTree error: $e');
      rethrow;
    }
  }

  /// Get all raw tree maps from local storage.
  static Future<List<Map<String, dynamic>>> getAllTreesRaw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_treesKey);
      if (json == null) return [];
      final list = jsonDecode(json) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('LocalTreeStorage getAllTreesRaw error: $e');
      return [];
    }
  }

  /// Get all trees as [NewTreeModel] objects.
  static Future<List<NewTreeModel>> getAllTrees() async {
    final raw = await getAllTreesRaw();
    return raw.map((r) => NewTreeModel.fromJson(r)).toList();
  }

  /// Get trees for a specific NGO.
  static Future<List<NewTreeModel>> getTreesForNgo(String ngoId) async {
    final all = await getAllTreesRaw();
    final filtered = all.where((r) => r['ngo_id'] == ngoId).toList();
    // Sort by created_at descending
    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
      final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
      return bDate.compareTo(aDate);
    });
    return filtered.map((r) => NewTreeModel.fromJson(r)).toList();
  }

  /// Get recent trees for an NGO (limited).
  static Future<List<NewTreeModel>> getRecentTrees(String ngoId,
      {int limit = 5}) async {
    final trees = await getTreesForNgo(ngoId);
    return trees.take(limit).toList();
  }

  /// Get total tree count for an NGO.
  static Future<int> getTreeCount(String ngoId) async {
    final trees = await getTreesForNgo(ngoId);
    return trees.length;
  }

  /// Get trees planted this month for an NGO.
  static Future<int> getTreesThisMonth(String ngoId) async {
    final trees = await getTreesForNgo(ngoId);
    final now = DateTime.now();
    return trees
        .where((t) =>
            t.plantingDate.year == now.year &&
            t.plantingDate.month == now.month)
        .length;
  }

  /// Get monthly stats for last 6 months.
  static Future<Map<String, int>> getMonthlyStats(String ngoId) async {
    final trees = await getTreesForNgo(ngoId);
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final Map<String, int> stats = {};
    for (final tree in trees) {
      if (tree.plantingDate.isBefore(sixMonthsAgo)) continue;
      final key =
          '${tree.plantingDate.year}-${tree.plantingDate.month.toString().padLeft(2, '0')}';
      stats[key] = (stats[key] ?? 0) + 1;
    }
    return stats;
  }

  /// Clear all local trees (for testing).
  static Future<void> clearTrees() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_treesKey);
  }

  // ─── REQUESTS ─────────────────────────────────────────────────────────────

  /// Save a mock pending request to local storage.
  static Future<void> saveRequest(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getAllRequestsRaw();
      data['id'] ??= 'local-req-${DateTime.now().millisecondsSinceEpoch}';
      data['created_at'] ??= DateTime.now().toIso8601String();
      existing.add(data);
      await prefs.setString(_requestsKey, jsonEncode(existing));
    } catch (e) {
      debugPrint('LocalTreeStorage saveRequest error: $e');
    }
  }

  /// Get all raw request maps from local storage.
  static Future<List<Map<String, dynamic>>> getAllRequestsRaw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_requestsKey);
      if (json == null) return [];
      final list = jsonDecode(json) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Get all pending requests as [RequestModel].
  static Future<List<RequestModel>> getPendingRequests() async {
    final all = await getAllRequestsRaw();
    return all
        .where((r) => r['status'] == 'pending')
        .map((r) => RequestModel.fromJson(r))
        .toList();
  }

  /// Update request status in local storage.
  static Future<void> updateRequestStatus(String id, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getAllRequestsRaw();
      for (final req in all) {
        if (req['id'] == id) req['status'] = status;
      }
      await prefs.setString(_requestsKey, jsonEncode(all));
    } catch (e) {
      debugPrint('LocalTreeStorage updateRequestStatus error: $e');
    }
  }

  /// Seed some demo requests for testing (only if none exist).
  static Future<void> seedDemoRequests() async {
    final existing = await getAllRequestsRaw();
    if (existing.isNotEmpty) return; // already seeded

    final demos = [
      {
        'id': 'demo-req-001',
        'user_id': 'demo-user-001',
        'tree_type': 'Neem Tree',
        'preferred_location': 'Near City Park, Main Road',
        'description': 'Would love a shade tree near my house',
        'status': 'pending',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'user_name': 'Ramesh Kumar',
      },
      {
        'id': 'demo-req-002',
        'user_id': 'demo-user-002',
        'tree_type': 'Mango Tree',
        'preferred_location': 'School compound',
        'description': 'For the school garden project',
        'status': 'pending',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        'user_name': 'Priya Sharma',
      },
    ];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_requestsKey, jsonEncode(demos));
    debugPrint('LocalTreeStorage: seeded ${demos.length} demo requests');
  }
}
