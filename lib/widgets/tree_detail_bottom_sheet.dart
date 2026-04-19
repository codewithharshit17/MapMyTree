import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/new_tree_model.dart';
import '../screens/ngo/edit_tree_screen.dart';
import '../screens/ngo/tree_info_screen.dart';
import '../screens/user_profile_screen.dart';

class TreeDetailBottomSheet extends StatelessWidget {
  final NewTreeModel tree;
  final bool isNgo;
  const TreeDetailBottomSheet({super.key, required this.tree, this.isNgo = false});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
                color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              // Photo
              if (tree.firstPhotoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: tree.firstPhotoUrl.startsWith('local://')
                      ? Image.file(
                          File(tree.firstPhotoUrl.replaceFirst('local://', '')),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: tree.firstPhotoUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                          placeholder: (_, __) => Container(height: 200, color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
                          errorWidget: (_, __, ___) => Container(height: 200, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey))),
                        ),
                )
              else
                Container(height: 120, width: double.infinity, decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('🌳', style: TextStyle(fontSize: 56)))),
              const SizedBox(height: 16),
              // Name + Species
              Text('🌳 ${tree.treeName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1B4332), fontFamily: 'Nunito')),
              if (tree.treeSpecies != null) Text(tree.treeSpecies!, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(height: 16),
              _row('📅', 'Planted', DateFormat('dd MMMM yyyy').format(tree.plantingDate)),
              if (tree.landownerType != null)
                _row('⛰️', 'Landowner', '${tree.landownerType} (${tree.landownerName ?? 'Unknown'})'),
              if (tree.plantedForUserName != null) 
                GestureDetector(
                  onTap: () {
                    if (tree.plantedForUserId != null && tree.plantedForUserId!.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => UserProfileScreen(userId: tree.plantedForUserId!),
                      ));
                    }
                  },
                  child: _row('👤', 'Planted For', tree.plantedForUserName!, isLink: tree.plantedForUserId != null && tree.plantedForUserId!.isNotEmpty),
                ),
              if (tree.exactLocation != null) _row('📍', 'Location', tree.exactLocation!),
              _row('🗺️', 'Coordinates', 'Lat: ${tree.latitude.toStringAsFixed(4)}, Lng: ${tree.longitude.toStringAsFixed(4)}'),
              
              // ── Map Integration ───────────────────────────────────────────────
              if (tree.latitude != 0.0 && tree.longitude != 0.0) ...[
                const SizedBox(height: 12),
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(tree.latitude, tree.longitude),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.mapmytree.app.client_v1',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(tree.latitude, tree.longitude),
                            width: 30,
                            height: 30,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              _row(tree.healthEmoji, 'Status', tree.healthLabel),
              if (tree.notes != null && tree.notes!.isNotEmpty) _row('📝', 'Notes', tree.notes!),
              
              // ── QR Code ───────────────────────────────────────────────
              Builder(
                builder: (BuildContext context) {
                  final uniqueId = tree.treeId ?? tree.id;
                  final url = tree.qrCodeUrl ?? 'https://mapmytree.app/tree/$uniqueId';
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Center(
                        child: Column(children: [
                          const Text('Tree QR Code',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1B4332))),
                          const SizedBox(height: 4),
                          Text(uniqueId,
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: QrImageView(
                              data: url,
                              version: QrVersions.auto,
                              size: 160,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              SharePlus.instance.share(ShareParams(text: 'Check out this 🌳 ${tree.treeName} planted via MapMyTree!\nView the tree: $url'));
                            },
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share Tree', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF1B4332)),
                          ),
                        ]),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              // Action buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => TreeInfoScreen(treeId: tree.treeId ?? tree.id),
                      ));
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Full Info'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B4332),
                      side: const BorderSide(color: Color(0xFF1B4332)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (isNgo) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditTreeScreen(tree: tree)));
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Tree'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                      ),
                    ),
                  ),
                ],
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _row(String emoji, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: TextStyle(
          fontSize: 13, 
          fontWeight: FontWeight.w600,
          color: isLink ? const Color(0xFF1B4332) : Colors.black87,
          decoration: isLink ? TextDecoration.underline : null,
        ))),
      ]),
    );
  }
}
