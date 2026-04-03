import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _bucket = 'tree-photos';

  /// Upload a photo to Supabase Storage and return the public URL.
  Future<String?> uploadTreePhoto(File imageFile, String treeId) async {
    try {
      final ext = imageFile.path.split('.').last;
      final fileName =
          '$treeId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from(_bucket).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final publicUrl =
          _supabase.storage.from(_bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('StorageService uploadTreePhoto error: $e');
      return null;
    }
  }

  /// Upload a tree update photo.
  Future<String?> uploadUpdatePhoto(File imageFile, String treeId) async {
    try {
      final ext = imageFile.path.split('.').last;
      final uuid = const Uuid().v4();
      final fileName = '$treeId/updates/$uuid.$ext';

      await _supabase.storage.from(_bucket).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final publicUrl =
          _supabase.storage.from(_bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('StorageService uploadUpdatePhoto error: $e');
      return null;
    }
  }

  /// Upload a profile photo.
  Future<String?> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      final ext = imageFile.path.split('.').last;
      final fileName =
          'profiles/${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from(_bucket).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      return _supabase.storage.from(_bucket).getPublicUrl(fileName);
    } catch (e) {
      debugPrint('StorageService uploadProfilePhoto error: $e');
      return null;
    }
  }
}
