import 'package:flutter/material.dart';
import '../../core/dev_session.dart';
import '../../core/session_helper.dart';
import '../auth_screen.dart';
import 'user_trees_tab.dart';
import 'user_map_screen.dart';
import 'request_tree_screen.dart';
import '../ngo/qr_scanner_screen.dart';
import '../user_profile_screen.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import '../ngo/tree_info_screen.dart';
import 'package:intl/intl.dart';

class UserShellScreen extends StatefulWidget {
  const UserShellScreen({super.key});
  @override
  State<UserShellScreen> createState() => _UserShellScreenState();
}

class _UserShellScreenState extends State<UserShellScreen> {
  int _currentTab = 0;

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<NotificationModel>>(
                stream: NotificationService().streamUserNotifications(SessionHelper.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('No notifications yet', style: TextStyle(color: Colors.grey)));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: n.type == 'planting_completed' ? Colors.green.shade50 : const Color(0xFF1B4332).withValues(alpha: 0.1),
                          child: Icon(n.type == 'planting_completed' ? Icons.eco : Icons.notifications, color: const Color(0xFF1B4332)),
                        ),
                        title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.message, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(DateFormat('MMM dd, yyyy • hh:mm a').format(n.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        trailing: !n.isRead ? const Icon(Icons.circle, color: Colors.green, size: 12) : null,
                        isThreeLine: true,
                        onTap: () {
                          if (!n.isRead) NotificationService().markAsRead(n.id);
                          if (n.relatedTreeId != null && n.relatedTreeId!.isNotEmpty) {
                            Navigator.pop(ctx); // Close bottom sheet
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TreeInfoScreen(treeId: n.relatedTreeId!)));
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentTab != 0) {
          setState(() => _currentTab = 0);
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: _currentTab == 3
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1B4332),
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MapMyTree', style: TextStyle(fontSize: 12, color: Colors.white70)),
                Text(SessionHelper.userName.isNotEmpty ? SessionHelper.userName : 'User',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
              actions: [
                StreamBuilder<List<NotificationModel>>(
                  stream: NotificationService().streamUserNotifications(SessionHelper.userId),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    final unreadCount = items.where((n) => !n.isRead).length;
                    return IconButton(
                      icon: Badge(
                        isLabelVisible: unreadCount > 0,
                        label: Text(unreadCount.toString()),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                      onPressed: () => _showNotifications(context),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                         builder: (_) => UserProfileScreen(userId: SessionHelper.userId),
                      ));
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white24,
                      child: Text(
                        SessionHelper.userName.isNotEmpty ? SessionHelper.userName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () {
                      DevSession().clear();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
                    }),
              ],
            ),
      body: IndexedStack(index: _currentTab, children: [
        const UserTreesTab(),
        const UserMapScreen(),
        const RequestTreeScreen(),
        QrScannerScreen(isActive: _currentTab == 3),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1B4332),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.park_outlined), activeIcon: Icon(Icons.park), label: 'My Trees'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Request'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), activeIcon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        ],
      ),
    ),
    );
  }
}
