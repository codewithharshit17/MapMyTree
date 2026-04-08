import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';
import '../core/dev_session.dart';
import 'local_tree_storage.dart';

class RequestService {
  final SupabaseClient _db = Supabase.instance.client;

  // NOTE: The Supabase table is 'requests', matching the new schema.
  static const _table = 'requests';

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

  /// Stream requests for a specific user (realtime + local fallback).
  Stream<List<RequestModel>> streamUserRequests(String userId) {
    if (DevSession().isActive) {
      // In dev mode, use local streaming
      return LocalTreeStorage.getAllRequestsRawStream().map((raw) {
        return raw
            .where((r) => r['user_id'] == userId)
            .map((r) => RequestModel.fromJson(r))
            .toList();
      });
    }
    try {
      return _db
          .from(_table)
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .asyncMap((rows) async {
            debugPrint('RequestService: Stream update for user $userId. Rows: ${rows.length}');
            List<RequestModel> remote = [];
            try {
              remote = rows.map((r) => RequestModel.fromJson(r)).toList();
            } catch (e) {
              debugPrint('RequestService: Error mapping remote requests: $e');
            }
            
            final allLocal = await LocalTreeStorage.getAllRequestsRaw();
            final local = allLocal
                .where((r) => r['user_id'] == userId)
                .map((r) => RequestModel.fromJson(r))
                .toList();
            final remoteIds = remote.map((r) => r.id).toSet();
            final localOnly = local.where((r) => !remoteIds.contains(r.id)).toList();
            debugPrint('RequestService: Merged Result: ${remote.length} remote, ${localOnly.length} local-only');
            return [...remote, ...localOnly];
          });
    } catch (e) {
      debugPrint('streamUserRequests error: $e');
      return LocalTreeStorage.getAllRequestsRawStream().map((raw) {
        return raw
            .where((r) => r['user_id'] == userId)
            .map((r) => RequestModel.fromJson(r))
            .toList();
      });
    }
  }

  /// Stream all pending requests (for NGO — realtime + local fallback).
  Stream<List<RequestModel>> streamPendingRequests() {
    try {
      return _db
          .from(_table)
          .stream(primaryKey: ['id'])
          .asyncMap((rows) async {
            // Fetch User profiles to attach names safely
            Map<String, String> profileNames = {};
            try {
              final List<dynamic> allProfiles = await _db.from('profiles').select('id, full_name, email');
              for (var p in allProfiles) {
                profileNames[p['id'].toString()] = p['full_name']?.toString() ?? p['email']?.toString() ?? 'User';
              }
            } catch (e) {
              debugPrint('Failed to load profiles for stream: $e');
            }

            final remote = rows
                .where((r) => r['status'] == 'pending')
                .map((r) {
                   final String uid = r['user_id']?.toString() ?? '';
                   if (profileNames.containsKey(uid)) {
                     r['user_name'] = profileNames[uid];
                   }
                   return RequestModel.fromJson(r);
                })
                .toList();

            final local = await LocalTreeStorage.getPendingRequests();
            final remoteIds = remote.map((r) => r.id).toSet();
            final localOnly = local.where((r) => !remoteIds.contains(r.id)).toList();
            return [...remote, ...localOnly];
          });
    } catch (e) {
      debugPrint('streamPendingRequests error: $e');
      return Stream.fromFuture(LocalTreeStorage.getPendingRequests());
    }
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
