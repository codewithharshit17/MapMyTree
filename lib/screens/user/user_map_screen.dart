import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/session_helper.dart';
import '../../models/new_tree_model.dart';
import '../../services/new_tree_service.dart';
import '../../services/location_service.dart';
import '../../widgets/tree_detail_bottom_sheet.dart';

class UserMapScreen extends StatefulWidget {
  const UserMapScreen({super.key});
  @override
  State<UserMapScreen> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  final _treeService = NewTreeService();
  final _locationService = LocationService();
  final _mapController = MapController();
  bool _isSatellite = false;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      StreamBuilder<List<NewTreeModel>>(
        stream: _treeService.streamUserTrees(SessionHelper.userId),
        builder: (context, snap) {
          final trees = snap.data ?? [];
          final markers = trees.map((t) => Marker(
            point: LatLng(t.latitude, t.longitude), width: 40, height: 40,
            child: GestureDetector(
              onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                builder: (_) => TreeDetailBottomSheet(tree: t, isNgo: false)),
              child: const Text('🌳', style: TextStyle(fontSize: 28))),
          )).toList();
          return FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: LatLng(20.5937, 78.9629), initialZoom: 5),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mapmytree.app'),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      Positioned(right: 16, bottom: 16, child: Column(children: [
        FloatingActionButton.small(heroTag: 'uCenter', backgroundColor: const Color(0xFF1B4332),
          onPressed: () async {
            final pos = await _locationService.getCurrentPosition();
            if (pos != null && mounted) _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
          }, child: const Icon(Icons.my_location, color: Colors.white)),
        const SizedBox(height: 8),
        FloatingActionButton.small(heroTag: 'uZoomIn', backgroundColor: Colors.white,
          onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
          child: const Icon(Icons.add, color: Color(0xFF1B4332))),
        const SizedBox(height: 8),
        FloatingActionButton.small(heroTag: 'uZoomOut', backgroundColor: Colors.white,
          onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
          child: const Icon(Icons.remove, color: Color(0xFF1B4332))),
        const SizedBox(height: 8),
        FloatingActionButton.small(heroTag: 'uMapType', backgroundColor: Colors.white,
          onPressed: () => setState(() => _isSatellite = !_isSatellite),
          child: Icon(_isSatellite ? Icons.map : Icons.satellite, color: const Color(0xFF1B4332))),
      ])),
      Positioned(top: 16, left: 16, child: StreamBuilder<List<NewTreeModel>>(
        stream: _treeService.streamUserTrees(SessionHelper.userId),
        builder: (_, snap) {
          final count = snap.data?.length ?? 0;
          return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]),
            child: Text('🌳 $count trees', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)));
        },
      )),
    ]);
  }
}
