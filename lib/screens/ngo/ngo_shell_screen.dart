import 'package:flutter/material.dart';
import '../../core/dev_session.dart';
import '../../core/session_helper.dart';
import '../auth_screen.dart';
import 'ngo_dashboard_tab.dart';
import 'add_tree_screen.dart';
import 'ngo_map_screen.dart';
import 'ngo_requests_tab.dart';

class NgoShellScreen extends StatefulWidget {
  const NgoShellScreen({super.key});

  @override
  State<NgoShellScreen> createState() => _NgoShellScreenState();
}

class _NgoShellScreenState extends State<NgoShellScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    // Activate dev session if auth is bypassed
    if (!DevSession().isActive) {
      DevSession().loginAsNGO();
    }
  }

  static const List<_TabConfig> _tabs = [
    _TabConfig(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard'),
    _TabConfig(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'Add Tree'),
    _TabConfig(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        label: 'Map'),
    _TabConfig(
        icon: Icons.inbox_outlined,
        activeIcon: Icons.inbox,
        label: 'Requests'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MapMyTree NGO',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
            Text(
              SessionHelper.userName.isNotEmpty
                  ? SessionHelper.userName
                  : 'Dashboard',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Notifications coming soon')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              DevSession().clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: const [
          NgoDashboardTab(),
          AddTreeScreen(),
          NgoMapScreen(),
          NgoRequestsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1B4332),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        items: _tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}

class _TabConfig {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabConfig(
      {required this.icon, required this.activeIcon, required this.label});
}
