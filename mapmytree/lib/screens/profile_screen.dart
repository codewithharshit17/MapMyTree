import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'plant_tree_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Function(int) onNavTap;

  const ProfileScreen({super.key, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.accentDark],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                        ),
                        child: const Center(
                          child: Text('👤', style: TextStyle(fontSize: 38)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Eco Warrior',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tree Mapper · Level 7',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Achievement chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _achievementChip('🌳', 'Tree Mapper'),
                  const SizedBox(width: 8),
                  _achievementChip('🌍', 'Eco Guardian'),
                  const SizedBox(width: 8),
                  _achievementChip('⭐', 'Pioneer'),
                ],
              ),
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _profileStat('Trees\nMapped', '47', AppTheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _profileStat('CO₂\nOffset', '1.8t', AppTheme.teal)),
                  const SizedBox(width: 12),
                  Expanded(child: _profileStat('Badges\nEarned', '12', AppTheme.orange)),
                ],
              ),
            ),
          ),

          // Settings/menu items
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _menuItem(Icons.person_rounded, 'Edit Profile', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Profile coming soon')))),
                  _menuItem(Icons.notifications_rounded, 'Notifications', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon')))),
                  _menuItem(Icons.location_on_rounded, 'Location Settings', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location Settings coming soon')))),
                  _menuItem(Icons.privacy_tip_rounded, 'Privacy', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy coming soon')))),
                  _menuItem(Icons.help_rounded, 'Help & Support', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help coming soon')))),
                  _menuItem(Icons.info_rounded, 'About MapMyTree', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('About coming soon')))),
                  const SizedBox(height: 12),
                  _menuItem(Icons.logout_rounded, 'Sign Out', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  }, color: Colors.redAccent),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlantTreeScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text(
          'Add Tree',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(currentIndex: 3, onTap: onNavTap),
    );
  }

  Widget _achievementChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: color ?? AppTheme.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color ?? AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}
