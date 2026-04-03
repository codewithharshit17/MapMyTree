import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/new_tree_model.dart';
import '../screens/ngo/edit_tree_screen.dart';

class TreeDetailBottomSheet extends StatelessWidget {
  final NewTreeModel tree;
  final bool isNgo;
  const TreeDetailBottomSheet({super.key, required this.tree, this.isNgo = false});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
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
              if (tree.plantedForUserName != null) _row('👤', 'Planted For', tree.plantedForUserName!),
              if (tree.exactLocation != null) _row('📍', 'Location', tree.exactLocation!),
              _row('🗺️', 'Coordinates', 'Lat: ${tree.latitude.toStringAsFixed(4)}, Lng: ${tree.longitude.toStringAsFixed(4)}'),
              _row(tree.healthEmoji, 'Status', tree.healthLabel),
              if (tree.notes != null && tree.notes!.isNotEmpty) _row('📝', 'Notes', tree.notes!),
              const SizedBox(height: 20),
              if (isNgo)
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => EditTreeScreen(tree: tree))); },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Tree'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                )),
            ]),
          ),
        );
      },
    );
  }

  Widget _row(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
