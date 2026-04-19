import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/new_tree_model.dart';
import '../models/tree_update_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/dev_session.dart';
import 'local_tree_storage.dart';
import 'storage_service.dart';

class NewTreeService {
  final SupabaseClient _db = Supabase.instance.client;

  /// Insert a new tree. Tries Supabase first, falls back to local storage.
  Future<String?> insertTree(Map<String, dynamic> data) async {
    final result =
        await _db.from('trees').insert(data).select('id').single();
    debugPrint('NewTreeService: saved to Supabase ✓');
    return result['id'] as String?;
  }

  /// Update a tree.
  Future<void> updateTree(String treeId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _db.from('trees').update(data).eq('id', treeId);
    } catch (e) {
      debugPrint('NewTreeService updateTree error: $e');
      // No local update implemented for now
    }
  }

  /// Sync offline trees to Supabase
  Future<int> syncOfflineTrees() async {
    final storageService = StorageService();
    final localTrees = await LocalTreeStorage.getAllTreesRaw();
    final unsynced = localTrees.where((t) => t['id'] != null && t['id'].toString().startsWith('local-tree-')).toList();
    int syncedCount = 0;

    for (var treeData in unsynced) {
      try {
        final originalLocalId = treeData['id'];
        final treeIdString = treeData['tree_id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        
        // Remove locally assigned structural fields that shouldn't be overridden in the DB schema
        final dbData = Map<String, dynamic>.from(treeData);
        dbData.remove('id'); 
        dbData.remove('created_at');
        dbData.remove('updated_at');

        // Handle photo uploads for local:// URIs
        List<String> newPhotoUrls = [];
        final rawPhotos = dbData['photo_urls'];
        if (rawPhotos != null && rawPhotos is List) {
          for (String url in rawPhotos) {
            if (url.startsWith('local://')) {
              final localPath = url.replaceFirst('local://', '');
              final file = File(localPath);
              if (await file.exists()) {
                final publicUrl = await storageService.uploadTreePhoto(file, treeIdString);
                if (publicUrl != null && !publicUrl.startsWith('local://')) {
                  newPhotoUrls.add(publicUrl);
                }
              }
            } else {
              newPhotoUrls.add(url);
            }
          }
        }
        dbData['photo_urls'] = newPhotoUrls;

        // Insert into Supabase
        await insertTree(dbData);
        
        // Remove from local cache
        await LocalTreeStorage.removeTree(originalLocalId);
        syncedCount++;
      } catch (e) {
        debugPrint('Failed to sync tree \${treeData['tree_id']}: $e');
      }
    }
    return syncedCount;
  }

  /// Get all trees for an NGO (merged from Supabase + local storage).
  Future<List<NewTreeModel>> getTreesForNgo(String ngoId) async {
    final local = await LocalTreeStorage.getTreesForNgo(ngoId);
    try {
      final rows = await _db
          .from('trees')
          .select()
          .order('planted_date', ascending: false);
      final remote = rows.map((r) => NewTreeModel.fromJson(r)).toList();
      // Merge: remote + local (avoid duplicates by ID)
      final remoteIds = remote.map((t) => t.id).toSet();
      final localOnly = local.where((t) => !remoteIds.contains(t.id)).toList();
      return [...remote, ...localOnly];
    } catch (e) {
      debugPrint('NewTreeService getTreesForNgo (Supabase) error: $e');
      debugPrint('NewTreeService getTreesForNgo (Supabase) error: $e');
      return local;
    }
  }

  /// Export trees for an NGO to a CSV file and share it.
  Future<void> exportTreesToCsv(String ngoId) async {
    try {
      final trees = await getTreesForNgo(ngoId);

      // Create CSV header
      final StringBuffer csvBuffer = StringBuffer();
      csvBuffer.writeln('Tree ID,Unique ID,Name,Species,Planted Date,Health Status,Latitude,Longitude,Exact Location,Notes,Planted By');

      // Add tree rows
      for (final tree in trees) {
        final lat = tree.latitude.toString();
        final lng = tree.longitude.toString();
        final date = tree.plantingDate.toIso8601String().split('T')[0];
        
        // Escape quotes and commas in fields
        String escapeField(String? field) {
          if (field == null) return '';
          final text = field.replaceAll('"', '""');
          if (text.contains(',') || text.contains('"') || text.contains('\n')) {
            return '"$text"';
          }
          return text;
        }

        csvBuffer.writeln(
          '${escapeField(tree.id)},${escapeField(tree.treeId)},${escapeField(tree.treeName)},'
          '${escapeField(tree.treeSpecies)},${escapeField(date)},${escapeField(tree.healthStatus)},'
          '${escapeField(lat)},${escapeField(lng)},${escapeField(tree.exactLocation)},'
          '${escapeField(tree.notes)},${escapeField(tree.plantedBy)}'
        );
      }

      // Write to temp directory
      final directory = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final File file = File('${directory.path}/mapmytree_export_$timestamp.csv');
      await file.writeAsString(csvBuffer.toString());

      // Share the file
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: 'MapMyTree Export Data',
        text: 'Attached is the exported tree data.',
      ));
    } catch (e) {
      debugPrint('Error exporting trees: $e');
      rethrow;
    }
  }

  /// Get all trees planted for a specific user.
  Future<List<NewTreeModel>> getTreesForUser(String userId) async {
    try {
      final rows = await _db
          .from('trees')
          .select()
          .eq('planted_for_user_id', userId)
          .order('planted_date', ascending: false);
      return rows.map((r) => NewTreeModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('NewTreeService getTreesForUser error: $e');
      return [];
    }
  }

  /// Stream trees for NGO (realtime + local fallback).
  Stream<List<NewTreeModel>> streamNgoTrees(String ngoId) {
    try {
      return _db
          .from('trees')
          .stream(primaryKey: ['id'])
          .asyncMap((rows) async {
            final remote = rows.map((r) => NewTreeModel.fromJson(r)).toList();
            final local = await LocalTreeStorage.getTreesForNgo(ngoId);
            final remoteIds = remote.map((t) => t.id).toSet();
            final localOnly = local.where((t) => !remoteIds.contains(t.id)).toList();
            return [...remote, ...localOnly];
          });
    } catch (e) {
      debugPrint('streamNgoTrees error: $e');
      return Stream.fromFuture(LocalTreeStorage.getTreesForNgo(ngoId));
    }
  }

  /// Stream trees for a user (realtime + local fallback).
  Stream<List<NewTreeModel>> streamUserTrees(String userId) {
    if (DevSession().isActive) {
      // In dev mode, use local streaming
      return LocalTreeStorage.getAllTreesRawStream().map((raw) {
        return raw
            .where((r) => r['planted_for_user_id'] == userId)
            .map((r) => NewTreeModel.fromJson(r))
            .toList();
      });
    }
    try {
      return _db
          .from('trees')
          .stream(primaryKey: ['id'])
          .eq('planted_for_user_id', userId)
          .asyncMap((rows) async {
            debugPrint('NewTreeService: Stream update for user $userId. Rows: ${rows.length}');
            List<NewTreeModel> remote = [];
            try {
              remote = rows.map((r) => NewTreeModel.fromJson(r)).toList();
            } catch (e) {
              debugPrint('NewTreeService: Error mapping remote trees: $e');
            }
            
            // Local fallback read
            final allLocal = await LocalTreeStorage.getAllTreesRaw();
            final local = allLocal
                .where((r) => r['planted_for_user_id'] == userId)
                .map((r) => NewTreeModel.fromJson(r))
                .toList();
            final remoteIds = remote.map((t) => t.id).toSet();
            final localOnly = local.where((t) => !remoteIds.contains(t.id)).toList();
            debugPrint('NewTreeService: Merged Result: ${remote.length} remote, ${localOnly.length} local-only');
            return [...remote, ...localOnly];
          }).handleError((error) {
            debugPrint('streamUserTrees realtime error caught: $error');
          });
    } catch (e) {
      debugPrint('streamUserTrees error: $e');
      return LocalTreeStorage.getAllTreesRawStream().map((raw) {
        return raw
            .where((r) => r['planted_for_user_id'] == userId)
            .map((r) => NewTreeModel.fromJson(r))
            .toList();
      });
    }
  }

  /// Stream ALL public trees for the maps (matches remote + local cached trees)
  Stream<List<NewTreeModel>> streamAllPublicTrees() {
    try {
      return _db
          .from('trees')
          .stream(primaryKey: ['id'])
          .asyncMap((rows) async {
            final remote = rows.map((r) => NewTreeModel.fromJson(r)).toList();
            
            // Bring back local trees so they aren't lost
            final allLocalRaw = await LocalTreeStorage.getAllTreesRaw();
            final local = allLocalRaw.map((r) => NewTreeModel.fromJson(r)).toList();
            
            final remoteIds = remote.map((t) => t.id).toSet();
            final localOnly = local.where((t) => !remoteIds.contains(t.id)).toList();
            
            return [...remote, ...localOnly];
          }).handleError((error) {
            debugPrint('streamAllPublicTrees realtime error caught: $error');
          });
    } catch (e) {
      debugPrint('streamAllPublicTrees error: $e');
      return Stream.value([]);
    }
  }

  /// Get recent trees for NGO (merged from Supabase + local).
  Future<List<NewTreeModel>> getRecentTrees(String ngoId,
      {int limit = 5}) async {
    final local = await LocalTreeStorage.getRecentTrees(ngoId, limit: limit);
    try {
      final rows = await _db
          .from('trees')
          .select()
          .order('planted_date', ascending: false)
          .limit(limit);
      final remote = rows.map((r) => NewTreeModel.fromJson(r)).toList();
      final remoteIds = remote.map((t) => t.id).toSet();
      final localOnly = local.where((t) => !remoteIds.contains(t.id)).toList();
      final merged = [...remote, ...localOnly];
      return merged.take(limit).toList();
    } catch (e) {
      debugPrint('NewTreeService getRecentTrees (Supabase) error: $e');
      return local;
    }
  }

  /// Get total tree count for NGO (merged).
  Future<int> getTreeCount(String ngoId) async {
    final localCount = await LocalTreeStorage.getTreeCount(ngoId);
    try {
      final rows =
          await _db.from('trees').select('id');
      return rows.length + localCount;
    } catch (e) {
      return localCount;
    }
  }

  /// Get trees planted this month for NGO (merged).
  Future<int> getTreesThisMonth(String ngoId) async {
    try {
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);

      final count = await _db
          .from('trees')
          .select('id')
          .gte('planted_date', currentMonthStart.toIso8601String())
          .count(CountOption.exact);

      return count.count ?? 0;
    } catch (e) {
      debugPrint('getTreesThisMonth error: $e');
      return 0; // Fallback to 0
    }
  }

  /// Calculates Survival Rate percentage
  Future<double> getSurvivalRate(String ngoId) async {
    try {
      final trees = await _db
          .from('trees')
          .select('health_status');

      if (trees.isEmpty) return 0.0;
      
      int survivalCount = trees.where((t) => t['health_status'] == 'healthy' || t['health_status'] == 'needs_attention').length;
      return (survivalCount / trees.length) * 100;
    } catch (e) {
      debugPrint('getSurvivalRate error: $e');
      return 0.0;
    }
  }

  /// Get monthly tree stats for last 6 months (merged).
  Future<Map<String, int>> getMonthlyStats(String ngoId) async {
    final localStats = await LocalTreeStorage.getMonthlyStats(ngoId);
    try {
      final sixMonthsAgo =
          DateTime.now().subtract(const Duration(days: 180));
      final rows = await _db
          .from('trees')
          .select('planted_date')
          .gte('planted_date', sixMonthsAgo.toIso8601String().split('T')[0]);

      final Map<String, int> remoteStats = {};
      for (final row in rows) {
        if (row['planted_date'] == null) continue;
        final date = DateTime.parse(row['planted_date']);
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        remoteStats[key] = (remoteStats[key] ?? 0) + 1;
      }

      // Merge local + remote
      final merged = Map<String, int>.from(remoteStats);
      for (final entry in localStats.entries) {
        merged[entry.key] = (merged[entry.key] ?? 0) + entry.value;
      }
      return merged;
    } catch (e) {
      debugPrint('NewTreeService getMonthlyStats (Supabase) error: $e');
      return localStats;
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
      return await _fallbackLocalById(treeId);
    } catch (e) {
      debugPrint('NewTreeService getTree error: $e');
      return await _fallbackLocalById(treeId);
    }
  }

  Future<NewTreeModel?> _fallbackLocalById(String treeId) async {
    try {
      final localTrees = await LocalTreeStorage.getAllTreesRaw();
      final localMatch = localTrees.where((t) => t['id'] == treeId).firstOrNull;
      if (localMatch != null) return NewTreeModel.fromJson(localMatch);
    } catch (e) {
      debugPrint('Local search error: $e');
    }
    return null;
  }

  /// Get a single tree by its unique `tree_id` (e.g. MMT-XXX).
  Future<NewTreeModel?> getTreeByUniqueId(String uniqueTreeId) async {
    try {
      final data = await _db
          .from('trees')
          .select()
          .eq('tree_id', uniqueTreeId)
          .maybeSingle();
      if (data != null) return NewTreeModel.fromJson(data);
      
      // If we reach here, Supabase succeeded but returned null
      return await _fallbackLocalByUniqueId(uniqueTreeId);
    } catch (e) {
      debugPrint('NewTreeService getTreeByUniqueId error: $e');
      // If Supabase throws (e.g. table doesn't exist), fallback to local
      return await _fallbackLocalByUniqueId(uniqueTreeId);
    }
  }

  Future<NewTreeModel?> _fallbackLocalByUniqueId(String uniqueTreeId) async {
    try {
      final localTrees = await LocalTreeStorage.getAllTreesRaw();
      final localMatch = localTrees.where((t) => t['tree_id'] == uniqueTreeId).firstOrNull;
      if (localMatch != null) return NewTreeModel.fromJson(localMatch);
      // Fallback: try matching by pure ID in case it's an old tree
      final oldMatch = localTrees.where((t) => t['id'] == uniqueTreeId).firstOrNull;
      if (oldMatch != null) return NewTreeModel.fromJson(oldMatch);
    } catch (e) {
      debugPrint('Local search error: $e');
    }
    return null;
  }

  /// Get a single tree by its associated `request_id`.
  Future<NewTreeModel?> getTreeByRequestId(String requestId) async {
    try {
      final data = await _db
          .from('trees')
          .select()
          .eq('request_id', requestId)
          .maybeSingle();
      if (data != null) return NewTreeModel.fromJson(data);
      
      // Fallback local search
      final localTrees = await LocalTreeStorage.getAllTreesRaw();
      final localMatch = localTrees.where((t) => t['request_id'] == requestId).firstOrNull;
      if (localMatch != null) return NewTreeModel.fromJson(localMatch);

      return null;
    } catch (e) {
      debugPrint('NewTreeService getTreeByRequestId error: $e');
      final localTrees = await LocalTreeStorage.getAllTreesRaw();
      final localMatch = localTrees.where((t) => t['request_id'] == requestId).firstOrNull;
      if (localMatch != null) return NewTreeModel.fromJson(localMatch);
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
