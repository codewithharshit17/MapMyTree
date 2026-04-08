import 'package:flutter/material.dart';
import '../../core/dev_session.dart';
import '../../core/session_helper.dart';
import '../auth_screen.dart';
import 'user_trees_tab.dart';
import 'user_map_screen.dart';
import 'request_tree_screen.dart';
import '../ngo/qr_scanner_screen.dart';
import '../user_profile_screen.dart';

class UserShellScreen extends StatefulWidget {
  const UserShellScreen({super.key});
  @override
  State<UserShellScreen> createState() => _UserShellScreenState();
}

class _UserShellScreenState extends State<UserShellScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon')))),
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
      body: IndexedStack(index: _currentTab, children: const [
        UserTreesTab(),
        UserMapScreen(),
        RequestTreeScreen(),
        QrScannerScreen(),
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
    );
  }
}
