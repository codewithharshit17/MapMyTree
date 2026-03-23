import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth_screen.dart';
import 'ngo_overview_tab.dart';
import 'ngo_requests_tab.dart';
import 'ngo_trees_tab.dart';
import 'ngo_analytics_tab.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  int _currentTab = 0;

  static const List<_TabConfig> _tabs = [
    _TabConfig(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Overview'),
    _TabConfig(
        icon: Icons.inbox_outlined,
        activeIcon: Icons.inbox,
        label: 'Requests'),
    _TabConfig(
        icon: Icons.park_outlined,
        activeIcon: Icons.park,
        label: 'Trees'),
    _TabConfig(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final ngo = authProvider.ngoModel;

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
              ngo?.ngoName ?? 'Dashboard',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          // Verification badge
          if (ngo != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ngo.isVerified
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ngo.isVerified ? '✓ Verified' : '⏳ Pending',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Notifications coming soon')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await authProvider.signOut();
              navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()));
            },

          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: const [
          NgoOverviewTab(),
          NgoRequestsTab(),
          NgoTreesTab(),
          NgoAnalyticsTab(),
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
