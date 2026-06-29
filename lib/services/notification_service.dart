import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _db = Supabase.instance.client;
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  
  bool _isInitialLoad = true;
  final Set<String> _knownIds = {};

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    String? imageUrl,
    String? relatedTreeId,
  }) async {
    try {
      await _db.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'image_url': imageUrl,
        'related_tree_id': relatedTreeId,
        'is_read': false,
      });
    } catch (e) {
      debugPrint('NotificationService insert error: $e');
    }
  }

  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    try {
      return _db
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map((rows) {
            final items = rows.map((r) => NotificationModel.fromJson(r)).toList();
            if (_isInitialLoad) {
              for (var item in items) { _knownIds.add(item.id); }
              _isInitialLoad = false;
            } else {
              for (var item in items) {
                if (!item.isRead && !_knownIds.contains(item.id)) {
                  _knownIds.add(item.id);
                  _showLocalPopup(item);
                }
              }
            }
            return items;
          })
          .handleError((error) {
             debugPrint('NotificationService stream error: $error');
          });
    } catch (e) {
      debugPrint('NotificationService setup error: $e');
      return Stream.value([]);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.from('notifications').update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      debugPrint('NotificationService markAsRead error: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(
      settings: initSettings,
    );
    _initialized = true;
  }

  void _showLocalPopup(NotificationModel n) async {
    if (!_initialized) await _initLocalNotifications();
    const androidDetails = AndroidNotificationDetails(
      'map_my_tree_channel', 'MapMyTree Alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const platformDetails = NotificationDetails(android: androidDetails);
    
    // Hash id safely to integer
    final pushId = n.id.hashCode.abs() % 100000;
    
    try {
      await _plugin.show(
        id: pushId,
        title: n.title,
        body: n.message,
        notificationDetails: platformDetails,
      );
    } catch (e) {
      debugPrint('Local notification show error: $e');
    }
  }
}
