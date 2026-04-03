import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';
import 'local_tree_storage.dart';

class RequestService {
  final SupabaseClient _db = Supabase.instance.client;

  // NOTE: The Supabase table is 'update_requests', not 'requests'.
  static const _table = 'update_requests';

  /// Create a new tree request from a user.
  Future<void> createRequest({
    required String userId,
    required String treeType,
    String? preferredLocation,
    String? description,
  }) async {
    try {
      await _db.from(_table).insert({
        'user_id': userId,
        'tree_type': treeType,
        'preferred_location': preferredLocation,
        'description': description,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('RequestService createRequest error: $e');
      // Save locally as fallback
      await LocalTreeStorage.saveRequest({
        'user_id': userId,
        'tree_type': treeType,
        'preferred_location': preferredLocation,
        'description': description,
        'status': 'pending',
        'user_name': 'Unknown User',
      });
    }
  }

  /// Get all pending requests (for NGO). Merges Supabase + local.
  Future<List<RequestModel>> getPendingRequests() async {
    // Seed demo requests on first call so NGO has something to work with
    await LocalTreeStorage.seedDemoRequests();
    final local = await LocalTreeStorage.getPendingRequests();
    try {
      final rows = await _db
          .from(_table)
          .select()
          .eq('status', 'pending');
      final remote = rows.map((r) => RequestModel.fromJson(r)).toList();
      // Merge: remote first, then local-only
      final remoteIds = remote.map((r) => r.id).toSet();
      final localOnly =
          local.where((r) => !remoteIds.contains(r.id)).toList();
      return [...remote, ...localOnly];
    } catch (e) {
      debugPrint('RequestService getPendingRequests (Supabase) error: $e');
      return local;
    }
  }

  /// Get all completed requests (for NGO).
  Future<List<RequestModel>> getCompletedRequests() async {
    final allLocal = await LocalTreeStorage.getAllRequestsRaw();
    final localCompleted = allLocal
        .where((r) => r['status'] == 'completed')
        .map((r) => RequestModel.fromJson(r))
        .toList();
    try {
      final rows = await _db
          .from(_table)
          .select()
          .eq('status', 'completed');
      final remote = rows.map((r) => RequestModel.fromJson(r)).toList();
      final remoteIds = remote.map((r) => r.id).toSet();
      final localOnly =
          localCompleted.where((r) => !remoteIds.contains(r.id)).toList();
      return [...remote, ...localOnly];
    } catch (e) {
      debugPrint('RequestService getCompletedRequests error: $e');
      return localCompleted;
    }
  }

  /// Get all requests for a specific user.
  Future<List<RequestModel>> getUserRequests(String userId) async {
    try {
      final rows = await _db
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.map((r) => RequestModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('RequestService getUserRequests error: $e');
      return [];
    }
  }

  /// Stream requests for a specific user (realtime).
  Stream<List<RequestModel>> streamUserRequests(String userId) {
    return _db
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.map((r) => RequestModel.fromJson(r)).toList());
  }

  /// Stream all pending requests (for NGO — realtime).
  Stream<List<RequestModel>> streamPendingRequests() {
    return _db
        .from(_table)
        .stream(primaryKey: ['id'])
        .map((rows) => rows
            .where((r) => r['status'] == 'pending')
            .map((r) => RequestModel.fromJson(r))
            .toList());
  }

  /// Update request status.
  Future<void> updateRequestStatus(String requestId, String status) async {
    // Update locally first (always succeeds)
    await LocalTreeStorage.updateRequestStatus(requestId, status);
    try {
      await _db
          .from(_table)
          .update({'status': status}).eq('id', requestId);
    } catch (e) {
      debugPrint(
          'RequestService updateRequestStatus (Supabase) error: $e (local updated)');
    }
  }

  /// Get count of pending requests.
  Future<int> getPendingRequestCount() async {
    final local = await LocalTreeStorage.getPendingRequests();
    try {
      final rows = await _db
          .from(_table)
          .select('id')
          .eq('status', 'pending');
      return rows.length + local.length;
    } catch (e) {
      return local.length;
    }
  }

  /// Get count of completed requests.
  Future<int> getCompletedRequestCount() async {
    final allLocal = await LocalTreeStorage.getAllRequestsRaw();
    final localCompleted =
        allLocal.where((r) => r['status'] == 'completed').length;
    try {
      final rows = await _db
          .from(_table)
          .select('id')
          .eq('status', 'completed');
      return rows.length + localCompleted;
    } catch (e) {
      return localCompleted;
    }
  }
}
