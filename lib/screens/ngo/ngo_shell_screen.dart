import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../core/dev_session.dart';
import '../../core/session_helper.dart';
import '../auth_screen.dart';
import 'ngo_dashboard_tab.dart';
import 'add_tree_screen.dart';
import 'ngo_map_screen.dart';
import 'ngo_requests_tab.dart';
import 'qr_scanner_screen.dart';
import '../../services/new_tree_service.dart';
import '../user_profile_screen.dart';
import 'ngo_admin_dashboard_tab.dart';

class NgoShellScreen extends StatefulWidget {
  const NgoShellScreen({super.key});

  @override
  State<NgoShellScreen> createState() => _NgoShellScreenState();
}

class _NgoShellScreenState extends State<NgoShellScreen> {
  int _currentTab = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        _syncOfflineDataSilently();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _syncOfflineDataSilently() async {
    try {
      final count = await NewTreeService().syncOfflineTrees();
      if (count > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔄 Background Sync: Successfully synced $count offline trees!'),
            backgroundColor: const Color(0xFF1B4332),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }

  List<_TabConfig> _buildTabsList() {
    return [
      const _TabConfig(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Dashboard'),
      const _TabConfig(
          icon: Icons.add_circle_outline,
          activeIcon: Icons.add_circle,
          label: 'Add Tree'),
      const _TabConfig(
          icon: Icons.map_outlined,
          activeIcon: Icons.map,
          label: 'Map'),
      const _TabConfig(
          icon: Icons.inbox_outlined,
          activeIcon: Icons.inbox,
          label: 'Requests'),
      const _TabConfig(
          icon: Icons.qr_code_scanner_outlined,
          activeIcon: Icons.qr_code_scanner,
          label: 'Scan QR'),
      if (SessionHelper.isNgoAdmin)
        const _TabConfig(
            icon: Icons.admin_panel_settings_outlined,
            activeIcon: Icons.admin_panel_settings,
            label: 'Admin'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabsList();
    // Safety check if tab is out of range after role switches
    if (_currentTab >= tabs.length) {
      _currentTab = 0;
    }

    return PopScope(
      canPop: _currentTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentTab != 0) {
          setState(() => _currentTab = 0);
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: _currentTab == 4
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1B4332),
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SessionHelper.isNgoAdmin ? 'MapMyTree NGO Admin' : 'MapMyTree NGO Volunteer',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
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
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Export Trees to CSV',
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generating CSV...')),
                      );
                      await NewTreeService().exportTreesToCsv(SessionHelper.userId);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cloud_sync_rounded),
                  tooltip: 'Sync Offline Data',
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Syncing offline data...')),
                      );
                      final count = await NewTreeService().syncOfflineTrees();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(count > 0 ? 'Successfully synced $count items!' : 'Everything is up to date.'), backgroundColor: const Color(0xFF1B4332)),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
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
          QrScannerScreen(isActive: _currentTab == 4),
          if (SessionHelper.isNgoAdmin) const NgoAdminDashboardTab(),
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
        items: tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
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
