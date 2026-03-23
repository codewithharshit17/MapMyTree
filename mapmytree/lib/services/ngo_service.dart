import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sponsorship_request_model.dart';
import '../models/ngo_model.dart';
import '../models/tree_model.dart';

class NgoService {
  final SupabaseClient _db = Supabase.instance.client;

  // --- REAL-TIME STREAMS ---

  Stream<List<SponsorshipRequest>> streamRequestsForNgo(String ngoId,
      {String? statusFilter}) {
    var query = _db
        .from('sponsorship_requests')
        .stream(primaryKey: ['id'])
        .eq('ngo_id', ngoId)
        .order('created_at', ascending: false);

    return query.map((rows) {
      var requests =
          rows.map((r) => SponsorshipRequest.fromJson(r)).toList();
      if (statusFilter != null && statusFilter != 'All') {
        requests = requests
            .where((r) => r.status == statusFilter.toLowerCase())
            .toList();
      }
      return requests;
    });
  }

  Stream<NgoModel?> streamNgoProfile(String ngoId) {
    return _db
        .from('ngos')
        .stream(primaryKey: ['uid'])
        .eq('uid', ngoId)
        .map((rows) => rows.isNotEmpty ? NgoModel.fromJson(rows.first) : null);
  }

  Stream<List<TreeModel>> streamTreesForNgo(String ngoId,
      {String? statusFilter}) {
    var query = _db
        .from('trees')
        .stream(primaryKey: ['id'])
        .eq('ngo_id', ngoId)
        .order('planted_date', ascending: false);

    return query.map((rows) {
      var trees = rows.map((r) => TreeModel.fromJson(r)).toList();
      if (statusFilter != null && statusFilter != 'All') {
        trees = trees
            .where((t) => t.status == statusFilter.toLowerCase())
            .toList();
      }
      return trees;
    });
  }

  // Pending count as a stream
  Stream<int> streamPendingRequestCount(String ngoId) {
    return _db
        .from('sponsorship_requests')
        .stream(primaryKey: ['id'])
        .eq('ngo_id', ngoId)
        .map((rows) => rows.where((r) => r['status'] == 'pending').length);
  }

  // --- ONE-TIME READS (analytics) ---

  Future<Map<String, int>> getMonthlyTreesStats(String ngoId) async {
    final sixMonthsAgo =
        DateTime.now().subtract(const Duration(days: 180)).toIso8601String();
    final rows = await _db
        .from('trees')
        .select('planted_date')
        .eq('ngo_id', ngoId)
        .gte('planted_date', sixMonthsAgo);

    final Map<String, int> monthlyCount = {};
    for (final row in rows) {
      if (row['planted_date'] == null) continue;
      final date = DateTime.parse(row['planted_date']);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyCount[key] = (monthlyCount[key] ?? 0) + 1;
    }
    return monthlyCount;
  }

  Future<Map<String, int>> getSpeciesBreakdown(String ngoId) async {
    final rows = await _db
        .from('trees')
        .select('species')
        .eq('ngo_id', ngoId);

    final Map<String, int> speciesCount = {};
    for (final row in rows) {
      final species = row['species'] as String? ?? 'Unknown';
      speciesCount[species] = (speciesCount[species] ?? 0) + 1;
    }
    return speciesCount;
  }

  Future<Map<String, int>> getRequestStatusBreakdown(String ngoId) async {
    final rows = await _db
        .from('sponsorship_requests')
        .select('status')
        .eq('ngo_id', ngoId);

    final Map<String, int> statusCount = {
      'pending': 0,
      'approved': 0,
      'rejected': 0
    };
    for (final row in rows) {
      final s = row['status'] as String? ?? 'pending';
      statusCount[s] = (statusCount[s] ?? 0) + 1;
    }
    return statusCount;
  }

  Future<int> getTotalSponsors(String ngoId) async {
    final rows = await _db
        .from('sponsorship_requests')
        .select('user_id')
        .eq('ngo_id', ngoId)
        .eq('status', 'approved');
    return rows.map((r) => r['user_id']).toSet().length;
  }

  Future<List<SponsorshipRequest>> getRecentRequests(String ngoId,
      {int limit = 5}) async {
    final rows = await _db
        .from('sponsorship_requests')
        .select()
        .eq('ngo_id', ngoId)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map((r) => SponsorshipRequest.fromJson(r)).toList();
  }

  // --- MUTATIONS ---

  Future<void> approveRequest(
      String requestId, String userId, String ngoId) async {
    // Update request status
    await _db
        .from('sponsorship_requests')
        .update({'status': 'approved', 'resolved_at': DateTime.now().toIso8601String()})
        .eq('id', requestId);
    // Increment NGO tree count
    await _db.rpc('increment_ngo_trees', params: {'ngo_uid': ngoId});
    // Increment user trees sponsored
    await _db.rpc('increment_user_trees', params: {'user_uid': userId});
  }

  Future<void> rejectRequest(String requestId) async {
    await _db
        .from('sponsorship_requests')
        .update({'status': 'rejected', 'resolved_at': DateTime.now().toIso8601String()})
        .eq('id', requestId);
  }

  Future<void> addTree(TreeModel tree) async {
    await _db.from('trees').insert(tree.toJson());
  }
}
