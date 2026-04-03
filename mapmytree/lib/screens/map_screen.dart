import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../services/tree_service.dart';

class MapScreen extends StatefulWidget {
  final bool isEmbedded;
  final Function(int)? onNavTap;

  const MapScreen({super.key, this.isEmbedded = false, this.onNavTap});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _navIndex = 1;
  Map<String, dynamic>? _selectedTree;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FutureBuilder(
        future: TreeService.fetchTrees(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trees = snapshot.data as List;

          return Stack(
            children: [
              /// 🌍 MAP LAYER
              FlutterMap(
                options: MapOptions(
                  center: LatLng(19.200, 73.130),
                  zoom: 17,
                  interactiveFlags: InteractiveFlag.all,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.mapmytree',
                  ),
                  MarkerLayer(
                    markers: trees.map<Marker>((tree) {
                      return Marker(
                        point: LatLng(tree['lat'], tree['lng']),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTree = tree;
                            });
                          },
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              /// 🌟 TOP SEARCH BAR
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Material(
                      color: Colors.transparent,
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
                            ),
                            child: const Icon(Icons.filter_list_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// 🌳 TREE INFO POPUP
              if (_selectedTree != null)
                Positioned(
                  bottom: 150,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.park, size: 30, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTree!['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Age: ${_selectedTree!['age']}"),
                                Text("Health: ${_selectedTree!['health']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              /// ➕ ADD TREE BUTTON (FAB)
              Positioned(
                bottom: 90,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: AppTheme.primary,
                  onPressed: () {},
                  child: const Icon(Icons.add_location_alt),
                ),
              ),
            ],
          );
        },
      ),

      /// 🔻 BOTTOM NAVIGATION
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
}