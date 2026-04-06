import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../../core/session_helper.dart';
import '../../models/new_tree_model.dart';
import '../../services/new_tree_service.dart';
import '../../services/location_service.dart';
import '../../widgets/tree_detail_bottom_sheet.dart';

class NgoMapScreen extends StatefulWidget {
  const NgoMapScreen({super.key});

  @override
  State<NgoMapScreen> createState() => _NgoMapScreenState();
}

class _NgoMapScreenState extends State<NgoMapScreen> {
  final _treeService = NewTreeService();
  final _locationService = LocationService();
  final _mapController = MapController();

  final LatLng _center = const LatLng(20.5937, 78.9629); // Default: India center
  bool _isSatellite = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map with realtime tree markers
        StreamBuilder<List<NewTreeModel>>(
          stream: _treeService.streamNgoTrees(SessionHelper.userId),
          builder: (context, snapshot) {
            final trees = snapshot.data ?? [];
            final markers = trees.map((tree) => Marker(
              point: LatLng(tree.latitude, tree.longitude),
              width: 32,
              height: 32,
              child: GestureDetector(
                onTap: () => _showTreeDetails(tree),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1CB572),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
            )).toList();

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 5,
              ),
              children: [
                TileLayer(
                  urlTemplate: _isSatellite
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.mapmytree.app.flutter_map.v1',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(50),
                    maxZoom: 15,
                    markers: markers,
                    builder: (context, clusterMarkers) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1CB572),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            clusterMarkers.length.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),

        // Map controls
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              // Center on current location
              FloatingActionButton.small(
                heroTag: 'center',
                backgroundColor: const Color(0xFF1B4332),
                onPressed: _centerOnCurrentLocation,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
              const SizedBox(height: 8),
              // Zoom in
              FloatingActionButton.small(
                heroTag: 'zoomIn',
                backgroundColor: Colors.white,
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(
                      _mapController.camera.center, currentZoom + 1);
                },
                child: const Icon(Icons.add, color: Color(0xFF1B4332)),
              ),
              const SizedBox(height: 8),
              // Zoom out
              FloatingActionButton.small(
                heroTag: 'zoomOut',
                backgroundColor: Colors.white,
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(
                      _mapController.camera.center, currentZoom - 1);
                },
                child: const Icon(Icons.remove, color: Color(0xFF1B4332)),
              ),
              const SizedBox(height: 8),
              // Toggle map type
              FloatingActionButton.small(
                heroTag: 'mapType',
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() => _isSatellite = !_isSatellite);
                },
                child: Icon(
                  _isSatellite ? Icons.map : Icons.satellite,
                  color: const Color(0xFF1B4332),
                ),
              ),
            ],
          ),
        ),

        // Loading indicator
        Positioned(
          top: 16,
          left: 16,
          child: StreamBuilder<List<NewTreeModel>>(
            stream: _treeService.streamNgoTrees(SessionHelper.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8)
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Loading trees...',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }
              final count = snapshot.data?.length ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: Text('🌳 $count trees',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      _mapController.move(
          LatLng(position.latitude, position.longitude), 15);
    }
  }

  void _showTreeDetails(NewTreeModel tree) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TreeDetailBottomSheet(
        tree: tree,
        isNgo: true,
      ),
    );
  }
}
