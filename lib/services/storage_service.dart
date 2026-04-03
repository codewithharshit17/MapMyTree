import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _bucket = 'tree-photos';

  /// Upload a photo to Supabase Storage.
  /// Falls back to copying the file locally and returning its path as URL.
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
      debugPrint('StorageService: uploaded to Supabase ✓');
      return publicUrl;
    } catch (e) {
      debugPrint('StorageService uploadTreePhoto (Supabase) failed: $e');
      debugPrint('StorageService: saving photo locally...');
      return _savePhotoLocally(imageFile, treeId);
    }
  }

  /// Copy the image to the app's local documents directory.
  Future<String?> _savePhotoLocally(File imageFile, String treeId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final treeDir =
          Directory('${dir.path}/tree_photos/$treeId');
      if (!await treeDir.exists()) {
        await treeDir.create(recursive: true);
      }
      final ext = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final localFile = await imageFile.copy('${treeDir.path}/$fileName');
      debugPrint('StorageService: saved photo locally at ${localFile.path}');
      // Return as a local:// URI so the app can display it via FileImage
      return 'local://${localFile.path}';
    } catch (e) {
      debugPrint('StorageService _savePhotoLocally error: $e');
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
      return _savePhotoLocally(imageFile, '$treeId-update');
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
      return _savePhotoLocally(imageFile, 'profile-$userId');
    }
  }
}
