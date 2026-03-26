import 'package:flutter/material.dart';
import '../app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
          _navItem(1, Icons.map_rounded, Icons.map_outlined, 'Map'),
          const SizedBox(width: 40), // FAB space
          _navItem(2, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
          _navItem(3, Icons.person_rounded, Icons.person_outlined, 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    final isActive = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? active : inactive,
              color: isActive ? AppTheme.primary : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primary : AppTheme.textLight,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
