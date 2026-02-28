import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/tree_model.dart';
import '../widgets/bottom_nav.dart';
import 'tree_detail_screen.dart';
import 'plant_tree_screen.dart';

class MapScreen extends StatefulWidget {
  final bool isEmbedded;
  final Function(int)? onNavTap;

  const MapScreen({super.key, this.isEmbedded = false, this.onNavTap});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _navIndex = 1;
  TreeModel? _selectedTree;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Simulated map background
          Positioned.fill(
            child: CustomPaint(
              painter: _MapPainter(),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 14),
                            Icon(Icons.search_rounded,
                                color: AppTheme.textLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Search trees on map…',
                              style: TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.filter_list_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tree pins on the map
          ..._buildTreePins(),

          // Map controls
          Positioned(
            right: 16,
            bottom: 110,
            child: Column(
              children: [
                _mapBtn(Icons.add_rounded, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zoom in coming soon')))),
                const SizedBox(height: 8),
                _mapBtn(Icons.remove_rounded, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zoom out coming soon')))),
                const SizedBox(height: 8),
                _mapBtn(Icons.my_location_rounded, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Locate me coming soon')))),
              ],
            ),
          ),

          // Tree info popup
          if (_selectedTree != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 80,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TreeDetailScreen(tree: _selectedTree!),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _selectedTree!.iconEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedTree!.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedTree!.location,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppTheme.textLight, size: 14),
                    ],
                  ),
                ),
              ),
            ),
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (widget.onNavTap != null) {
            widget.onNavTap!(i);
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }

  List<Widget> _buildTreePins() {
    final positions = [
      const Offset(0.25, 0.35),
      const Offset(0.55, 0.28),
      const Offset(0.70, 0.50),
      const Offset(0.35, 0.60),
      const Offset(0.15, 0.55),
    ];

    return List.generate(TreeModel.sampleTrees.length, (i) {
      final tree = TreeModel.sampleTrees[i];
      final pos = positions[i];
      return Positioned(
        left: MediaQuery.of(context).size.width * pos.dx - 20,
        top: MediaQuery.of(context).size.height * pos.dy - 20,
        child: GestureDetector(
          onTap: () =>
              setState(() => _selectedTree = _selectedTree?.id == tree.id ? null : tree),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _selectedTree?.id == tree.id
                  ? AppTheme.primary
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(tree.iconEmoji,
                style: const TextStyle(fontSize: 18)),
          ),
        ),
      );
    });
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }


}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base map color
    final bgPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Streets
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFCCDDCC)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roads = [
      [Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.3)],
      [Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.6)],
      [Offset(size.width * 0.3, 0), Offset(size.width * 0.35, size.height)],
      [Offset(size.width * 0.65, 0), Offset(size.width * 0.7, size.height)],
    ];

    for (final road in roads) {
      canvas.drawLine(road[0], road[1], roadBorderPaint);
      canvas.drawLine(road[0], road[1], roadPaint);
    }

    // Parks / green areas
    final parkPaint = Paint()
      ..color = const Color(0xFFA5D6A7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.38, size.height * 0.33, size.width * 0.25, size.height * 0.22),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.62, size.width * 0.22, size.height * 0.15),
        const Radius.circular(6),
      ),
      parkPaint,
    );

    // Buildings
    final buildPaint = Paint()
      ..color = const Color(0xFFBDBDBD).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final buildings = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.05, 60, 50),
      Rect.fromLTWH(size.width * 0.15, size.height * 0.07, 40, 35),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.05, 50, 55),
      Rect.fromLTWH(size.width * 0.08, size.height * 0.65, 45, 40),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.65, 55, 45),
    ];

    for (final b in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(4)),
        buildPaint,
      );
    }

    // Water feature
    final waterPaint = Paint()..color = const Color(0xFFB3E5FC).withOpacity(0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.7, size.height * 0.33, size.width * 0.28, size.height * 0.15),
        const Radius.circular(60),
      ),
      waterPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
