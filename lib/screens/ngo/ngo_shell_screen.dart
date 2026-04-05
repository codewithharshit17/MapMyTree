import 'package:flutter/material.dart';
import '../../core/dev_session.dart';
import '../../core/session_helper.dart';
import '../auth_screen.dart';
import 'ngo_dashboard_tab.dart';
import 'add_tree_screen.dart';
import 'ngo_map_screen.dart';
import 'ngo_requests_tab.dart';
import 'qr_scanner_screen.dart';

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
    _TabConfig(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Scan QR'),
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
          // Quick scan QR button in app bar
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR Code',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );
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
        children: [
          const NgoDashboardTab(),
          const AddTreeScreen(),
          const NgoMapScreen(),
          const NgoRequestsTab(),
          // QR Scanner: full live camera, launched as a separate route
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFF2D6A4F)),
                const SizedBox(height: 20),
                const Text(
                  'Scan a Tree QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Point your camera at any MapMyTree QR\nto instantly view the tree information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Open Scanner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
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
