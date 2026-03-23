import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/tree_model.dart';

class NgoTreesTab extends StatefulWidget {
  const NgoTreesTab({super.key});

  @override
  State<NgoTreesTab> createState() => _NgoTreesTabState();
}

class _NgoTreesTabState extends State<NgoTreesTab> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  final List<String> _filters = ['All', 'Alive', 'Unknown', 'Dead'];

  Future<List<TreeModel>> _fetchTrees(String ngoId) async {
    final supabase = Supabase.instance.client;
    
    // Build query with all filters BEFORE .order()
    final List<Map<String, dynamic>> rows;
    if (_statusFilter != 'All') {
      rows = await supabase
          .from('trees')
          .select()
          .eq('ngo_id', ngoId)
          .eq('status', _statusFilter.toLowerCase())
          .order('planted_date', ascending: false);
    } else {
      rows = await supabase
          .from('trees')
          .select()
          .eq('ngo_id', ngoId)
          .order('planted_date', ascending: false);
    }

    var trees = rows.map((r) => TreeModel.fromJson(r)).toList();

    if (_searchQuery.isNotEmpty) {
      trees = trees
          .where((t) =>
              t.name.toLowerCase().contains(_searchQuery) ||
              t.species.toLowerCase().contains(_searchQuery) ||
              t.location.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return trees;
  }


  @override
  Widget build(BuildContext context) {
    final ngoId = context.read<AppAuthProvider>().userModel?.uid ?? '';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          color: Colors.white,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search by species, name, or location...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              filled: true,
              fillColor: const Color(0xFFF5F7F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        Container(
          color: Colors.white, height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filters.length,
            itemBuilder: (_, i) {
              final filter = _filters[i];
              final isSelected = filter == _statusFilter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _statusFilter = filter),
                  selectedColor: const Color(0xFF1B4332),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w600, fontSize: 13,
                  ),
                  backgroundColor: const Color(0xFFF5F7F5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<TreeModel>>(
            future: _fetchTrees(ngoId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final trees = snapshot.data ?? [];
              if (trees.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌲', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        _statusFilter == 'All'
                            ? 'No trees planted yet'
                            : 'No ${_statusFilter.toLowerCase()} trees',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: trees.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _TreeListCard(tree: trees[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TreeListCard extends StatelessWidget {
  final TreeModel tree;
  const _TreeListCard({required this.tree});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (tree.status) {
      case 'alive': statusColor = Colors.green; break;
      case 'dead': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(tree.iconEmoji.isNotEmpty ? tree.iconEmoji : '🌳',
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tree.name, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(tree.species,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 3),
                Expanded(child: Text(tree.location,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: tree.healthScore / 100, minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tree.healthScore >= 70 ? Colors.green
                          : tree.healthScore >= 40 ? Colors.orange : Colors.red,
                    ),
                  ),
                )),
                const SizedBox(width: 8),
                Text('${tree.healthScore.toInt()}%',
                    style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600, color: Colors.grey)),
              ]),
            ],
          )),
          const SizedBox(width: 8),
          Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(tree.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            if (tree.plantedDate != null)
              Text(DateFormat('MMM yyyy').format(tree.plantedDate!),
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}
