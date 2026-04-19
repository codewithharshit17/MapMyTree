import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/new_tree_model.dart';
import '../../services/new_tree_service.dart';
import '../../core/session_helper.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'edit_tree_screen.dart';

class TreeInfoScreen extends StatefulWidget {
  final String treeId;

  const TreeInfoScreen({super.key, required this.treeId});

  @override
  State<TreeInfoScreen> createState() => _TreeInfoScreenState();
}

class _TreeInfoScreenState extends State<TreeInfoScreen> {
  final _treeService = NewTreeService();
  NewTreeModel? _tree;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    final tree = await _treeService.getTreeByUniqueId(widget.treeId);
    if (mounted) {
      setState(() {
        _tree = tree;
        _isLoading = false;
      });
    }
  }

  void _shareTree(NewTreeModel t) {
    if (t.qrCodeUrl != null) {
      SharePlus.instance.share(ShareParams(text: 'Check out this 🌳 ${t.treeName} planted via MapMyTree!\nView the tree: ${t.qrCodeUrl}'));
    } else {
      SharePlus.instance.share(ShareParams(text: 'Check out this 🌳 ${t.treeName} planted via MapMyTree! Tree ID: ${t.treeId ?? t.id}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B4332))),
      );
    }

    if (_tree == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tree Not Found')),
        body: const Center(
          child: Text('Invalid Tree ID or Tree not found.', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    final t = _tree!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Tree Information'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
        actions: [
          if ((SessionHelper.isNgo || context.read<AppAuthProvider>().isNgo) && _tree != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF1B4332)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EditTreeScreen(tree: _tree!)));
              },
              tooltip: 'Edit Tree',
            ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF1B4332)),
            onPressed: () => _shareTree(t),
            tooltip: 'Share Tree',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photo Header
            if (t.firstPhotoUrl.isNotEmpty) 
               t.firstPhotoUrl.startsWith('local://')
                   ? Image.file(
                       File(t.firstPhotoUrl.replaceFirst('local://', '')),
                       width: double.infinity,
                       height: 250,
                       fit: BoxFit.cover,
                     )
                   : CachedNetworkImage(
                       imageUrl: t.firstPhotoUrl,
                       width: double.infinity,
                       height: 250,
                       fit: BoxFit.cover,
                       errorWidget: (context, url, err) => Container(
                         height: 250,
                         color: Colors.grey.shade300,
                         child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                       ),
                     )
             else 
               Container(
                 width: double.infinity,
                 height: 250,
                 color: Colors.green.shade100,
                 child: const Icon(Icons.park, size: 80, color: Colors.green),
               ),
               
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(t.treeName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontFamily: 'Nunito')),
                   if (t.scientificName != null && t.scientificName!.isNotEmpty)
                     Text(t.scientificName!, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey))
                   else if (t.treeSpecies != null && t.treeSpecies!.isNotEmpty)
                     Text(t.treeSpecies!, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),
                     
                   const SizedBox(height: 24),
                   
                   _buildInfoRow(Icons.person, 'Planted By', t.plantedBy ?? t.ngoName ?? 'Unknown / NGO'),
                   if (t.landownerType != null)
                     _buildInfoRow(Icons.landscape, 'Landowner', '${t.landownerType} (${t.landownerName ?? 'Unknown'})'),
                   _buildInfoRow(Icons.calendar_today, 'Date Planted', DateFormat('dd MMMM yyyy').format(t.plantingDate)),
                   _buildInfoRow(Icons.update, 'Last Updated', DateFormat('dd MMMM yyyy hh:mm a').format(t.updatedAt)),
                   
                   const SizedBox(height: 24),
                   const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                   const SizedBox(height: 8),
                   if (t.exactLocation != null && t.exactLocation!.isNotEmpty)
                     Text(t.exactLocation!, style: const TextStyle(fontSize: 14)),
                   const SizedBox(height: 12),
                   
                   // Map
                   Container(
                     height: 200,
                     decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300)
                     ),
                     clipBehavior: Clip.hardEdge,
                     child: FlutterMap(
                       options: MapOptions(
                         initialCenter: LatLng(t.latitude, t.longitude),
                         initialZoom: 14.0,
                       ),
                       children: [
                         TileLayer(
                           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                           userAgentPackageName: 'com.mapmytree.app.client_v1',
                         ),
                         MarkerLayer(
                           markers: [
                             Marker(
                               point: LatLng(t.latitude, t.longitude),
                               width: 40,
                               height: 40,
                               child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 32),
                   
                   // QR Code Section
                   Builder(
                     builder: (context) {
                       final uniqueId = t.treeId ?? t.id;
                       final url = t.qrCodeUrl ?? 'https://mapmytree.app/tree/$uniqueId';
                       return Center(
                         child: Column(
                           children: [
                             const Text('Scan to view this page again', style: TextStyle(color: Colors.grey, fontSize: 13)),
                             const SizedBox(height: 12),
                             Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.circular(20),
                                 boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                               ),
                               child: QrImageView(
                                 data: url,
                                 version: QrVersions.auto,
                                 size: 160.0,
                                 backgroundColor: Colors.white,
                               ),
                             ),
                             const SizedBox(height: 12),
                             Text(uniqueId, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontSize: 16)),
                           ],
                         ),
                       );
                     }
                   ),
                   const SizedBox(height: 40),
                ],
              )
            )
          ],
        )
      )
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2D6A4F))
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87)),
              ],
            ),
          )
        ],
      )
    );
  }
}
