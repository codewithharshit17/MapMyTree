import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/session_helper.dart';
import '../../models/new_tree_model.dart';
import '../../services/new_tree_service.dart';
import '../../services/request_service.dart';

class UserTreesTab extends StatefulWidget {
  const UserTreesTab({super.key});
  @override
  State<UserTreesTab> createState() => _UserTreesTabState();
}

class _UserTreesTabState extends State<UserTreesTab> {
  final _treeService = NewTreeService();
  final _requestService = RequestService();

  Future<Map<String, dynamic>> _loadData() async {
    final userId = SessionHelper.userId;
    final results = await Future.wait([
      _treeService.getTreesForUser(userId),
      _requestService.getUserRequests(userId),
    ]);
    final trees = results[0] as List<NewTreeModel>;
    final requests = results[1] as List;
    return {
      'trees': trees,
      'totalRequested': requests.length,
      'treesPlanted': trees.length,
      'pendingRequests': requests.where((r) => r.status == 'pending').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1B4332),
      onRefresh: () async => setState(() {}),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          final trees = data['trees'] as List<NewTreeModel>;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, ${SessionHelper.userName} 👋',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B4332), fontFamily: 'Nunito')),
              const SizedBox(height: 4),
              const Text('Your tree journey', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              // Stats
              Row(children: [
                _stat('Requested', '${data['totalRequested']}', Icons.send, Colors.blue),
                const SizedBox(width: 10),
                _stat('Planted', '${data['treesPlanted']}', Icons.park, const Color(0xFF2D6A4F)),
                const SizedBox(width: 10),
                _stat('Pending', '${data['pendingRequests']}', Icons.pending, Colors.orange),
              ]),
              const SizedBox(height: 28),
              const Text('My Trees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B4332))),
              const SizedBox(height: 12),
              if (trees.isEmpty)
                Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Column(children: [
                    Text('🌱', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 8),
                    Text('No trees planted for you yet', style: TextStyle(color: Colors.grey)),
                    Text('Request a tree to get started!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ])))
              else ...trees.map((t) => _TreeCard(tree: t)),
            ]),
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color, fontFamily: 'Nunito')),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
      ]),
    ));
  }
}

class _TreeCard extends StatelessWidget {
  final NewTreeModel tree;
  const _TreeCard({required this.tree});

  @override
  Widget build(BuildContext context) {
    Color healthColor;
    switch (tree.healthStatus) {
      case 'healthy': healthColor = Colors.green; break;
      case 'needs_attention': healthColor = Colors.orange; break;
      case 'dead': healthColor = Colors.red; break;
      default: healthColor = Colors.green;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: tree.firstPhotoUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: tree.firstPhotoUrl, width: 64, height: 64, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _placeholder())
              : _placeholder(),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tree.treeName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 2),
          Text(tree.treeSpecies ?? 'Unknown species', style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text('Planted ${DateFormat('dd MMM yyyy').format(tree.plantingDate)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: healthColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Text(tree.healthLabel, style: TextStyle(color: healthColor, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ])),
    );
  }

  Widget _placeholder() => Container(
    width: 64, height: 64,
    decoration: BoxDecoration(color: const Color(0xFF2D6A4F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: const Center(child: Text('🌳', style: TextStyle(fontSize: 28))),
  );
}
