import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';

class RequestService {
  final SupabaseClient _db = Supabase.instance.client;

  /// Create a new tree request from a user.
  Future<void> createRequest({
    required String userId,
    required String treeType,
    String? preferredLocation,
    String? description,
  }) async {
    try {
      await _db.from('requests').insert({
        'user_id': userId,
        'tree_type': treeType,
        'preferred_location': preferredLocation,
        'description': description,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('RequestService createRequest error: $e');
      rethrow;
    }
  }

  /// Get all pending requests (for NGO).
  Future<List<RequestModel>> getPendingRequests() async {
    try {
      final rows = await _db
          .from('requests')
          .select('*, profiles!requests_user_id_fkey(full_name)')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return rows.map((r) => RequestModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('RequestService getPendingRequests error: $e');
      return [];
    }
  }

  /// Get all completed requests (for NGO).
  Future<List<RequestModel>> getCompletedRequests() async {
    try {
      final rows = await _db
          .from('requests')
          .select('*, profiles!requests_user_id_fkey(full_name)')
          .eq('status', 'completed')
          .order('created_at', ascending: false);
      return rows.map((r) => RequestModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('RequestService getCompletedRequests error: $e');
      return [];
    }
  }

  /// Get all requests for a specific user.
  Future<List<RequestModel>> getUserRequests(String userId) async {
    try {
      final rows = await _db
          .from('requests')
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
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => RequestModel.fromJson(r)).toList());
  }

  /// Stream all pending requests (for NGO — realtime).
  Stream<List<RequestModel>> streamPendingRequests() {
    return _db
        .from('requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((r) => r['status'] == 'pending')
            .map((r) => RequestModel.fromJson(r))
            .toList());
  }

  /// Update request status.
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _db
          .from('requests')
          .update({'status': status})
          .eq('id', requestId);
    } catch (e) {
      debugPrint('RequestService updateRequestStatus error: $e');
      rethrow;
    }
  }

  /// Get count of pending requests.
  Future<int> getPendingRequestCount() async {
    try {
      final rows = await _db
          .from('requests')
          .select('id')
          .eq('status', 'pending');
      return rows.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get count of completed requests.
  Future<int> getCompletedRequestCount() async {
    try {
      final rows = await _db
          .from('requests')
          .select('id')
          .eq('status', 'completed');
      return rows.length;
    } catch (e) {
      return 0;
    }
  }
}
