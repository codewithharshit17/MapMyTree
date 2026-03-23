import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tree_model.dart';

class TreeService {
  final SupabaseClient _db = Supabase.instance.client;

  // --- STREAMS ---

  Stream<List<TreeModel>> streamAllTrees() {
    return _db
        .from('trees')
        .stream(primaryKey: ['id'])
        .order('planted_date', ascending: false)
        .map((rows) => rows.map((r) => TreeModel.fromJson(r)).toList());
  }

  // --- ONE-TIME READS ---

  Future<TreeModel?> getTree(String treeId) async {
    final data = await _db
        .from('trees')
        .select()
        .eq('id', treeId)
        .maybeSingle();
    if (data != null) return TreeModel.fromJson(data);
    return null;
  }

  Future<void> createTree(TreeModel tree) async {
    await _db.from('trees').insert(tree.toJson());
  }

  Future<void> updateTree(String treeId, Map<String, dynamic> data) async {
    data['last_updated'] = DateTime.now().toIso8601String();
    await _db.from('trees').update(data).eq('id', treeId);
  }

  Future<void> deleteTree(String treeId) async {
    await _db.from('trees').delete().eq('id', treeId);
  }

  // --- SPONSORSHIP REQUESTS ---

  Future<void> createSponsorshipRequest(Map<String, dynamic> data) async {
    await _db.from('sponsorship_requests').insert(data);
  }

  Future<List<Map<String, dynamic>>> getUserSponsorships(
      String userId) async {
    return await _db
        .from('sponsorship_requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
