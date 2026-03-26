import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/new_tree_model.dart';
import '../models/tree_update_model.dart';

class NewTreeService {
  final SupabaseClient _db = Supabase.instance.client;

  /// Insert a new tree.
  Future<String?> insertTree(Map<String, dynamic> data) async {
    try {
      final result =
          await _db.from('trees').insert(data).select('id').single();
      return result['id'] as String?;
    } catch (e) {
      debugPrint('NewTreeService insertTree error: $e');
      rethrow;
    }
  }

  /// Update a tree.
  Future<void> updateTree(String treeId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _db.from('trees').update(data).eq('id', treeId);
    } catch (e) {
      debugPrint('NewTreeService updateTree error: $e');
      rethrow;
    }
  }

  /// Get all trees for an NGO.
  Future<List<NewTreeModel>> getTreesForNgo(String ngoId) async {
    try {
      final rows = await _db
          .from('trees')
          .select()
          .eq('ngo_id', ngoId)
          .order('created_at', ascending: false);
      return rows.map((r) => NewTreeModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('NewTreeService getTreesForNgo error: $e');
      return [];
    }
  }

  /// Get all trees planted for a specific user.
  Future<List<NewTreeModel>> getTreesForUser(String userId) async {
    try {
      final rows = await _db
          .from('trees')
          .select()
          .eq('planted_for_user_id', userId)
          .order('created_at', ascending: false);
      return rows.map((r) => NewTreeModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('NewTreeService getTreesForUser error: $e');
      return [];
    }
  }

  /// Stream trees for NGO (realtime).
  Stream<List<NewTreeModel>> streamNgoTrees(String ngoId) {
    return _db
        .from('trees')
        .stream(primaryKey: ['id'])
        .eq('ngo_id', ngoId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => NewTreeModel.fromJson(r)).toList());
  }

  /// Stream trees for a user (realtime).
  Stream<List<NewTreeModel>> streamUserTrees(String userId) {
    return _db
        .from('trees')
        .stream(primaryKey: ['id'])
        .eq('planted_for_user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => NewTreeModel.fromJson(r)).toList());
  }

  /// Get recent trees for NGO.
  Future<List<NewTreeModel>> getRecentTrees(String ngoId,
      {int limit = 5}) async {
    try {
      final rows = await _db
          .from('trees')
          .select()
          .eq('ngo_id', ngoId)
          .order('created_at', ascending: false)
          .limit(limit);
      return rows.map((r) => NewTreeModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('NewTreeService getRecentTrees error: $e');
      return [];
    }
  }

  /// Get total tree count for NGO.
  Future<int> getTreeCount(String ngoId) async {
    try {
      final rows =
          await _db.from('trees').select('id').eq('ngo_id', ngoId);
      return rows.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get trees planted this month for NGO.
  Future<int> getTreesThisMonth(String ngoId) async {
    try {
      final now = DateTime.now();
      final firstOfMonth = DateTime(now.year, now.month, 1);
      final rows = await _db
          .from('trees')
          .select('id')
          .eq('ngo_id', ngoId)
          .gte('created_at', firstOfMonth.toIso8601String());
      return rows.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get monthly tree stats for last 6 months.
  Future<Map<String, int>> getMonthlyStats(String ngoId) async {
    try {
      final sixMonthsAgo =
          DateTime.now().subtract(const Duration(days: 180));
      final rows = await _db
          .from('trees')
          .select('created_at')
          .eq('ngo_id', ngoId)
          .gte('created_at', sixMonthsAgo.toIso8601String());

      final Map<String, int> monthlyCount = {};
      for (final row in rows) {
        if (row['created_at'] == null) continue;
        final date = DateTime.parse(row['created_at']);
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthlyCount[key] = (monthlyCount[key] ?? 0) + 1;
      }
      return monthlyCount;
    } catch (e) {
      debugPrint('NewTreeService getMonthlyStats error: $e');
      return {};
    }
  }

  /// Get a single tree by ID.
  Future<NewTreeModel?> getTree(String treeId) async {
    try {
      final data = await _db
          .from('trees')
          .select()
          .eq('id', treeId)
          .maybeSingle();
      if (data != null) return NewTreeModel.fromJson(data);
      return null;
    } catch (e) {
      debugPrint('NewTreeService getTree error: $e');
      return null;
    }
  }

  /// Insert a tree update.
  Future<void> insertTreeUpdate(Map<String, dynamic> data) async {
    try {
      await _db.from('tree_updates').insert(data);
    } catch (e) {
      debugPrint('NewTreeService insertTreeUpdate error: $e');
      rethrow;
    }
  }

  /// Get updates for a tree.
  Future<List<TreeUpdateModel>> getTreeUpdates(String treeId) async {
    try {
      final rows = await _db
          .from('tree_updates')
          .select()
          .eq('tree_id', treeId)
          .order('created_at', ascending: false);
      return rows.map((r) => TreeUpdateModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('NewTreeService getTreeUpdates error: $e');
      return [];
    }
  }
}
