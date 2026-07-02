import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/new_tree_model.dart';
import '../../services/new_tree_service.dart';
import '../../core/session_helper.dart';
import '../../widgets/tree_detail_bottom_sheet.dart';
import '../../widgets/shimmer_loading.dart';

class PlantedTreesScreen extends StatefulWidget {
  const PlantedTreesScreen({super.key});

  @override
  State<PlantedTreesScreen> createState() => _PlantedTreesScreenState();
}

class _PlantedTreesScreenState extends State<PlantedTreesScreen> {
  final _treeService = NewTreeService();
  final List<NewTreeModel> _trees = [];
  bool _isFirstLoad = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchTrees();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchTrees() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final ngoId = SessionHelper.userId;

      if (_totalCount == 0) {
        _totalCount = await _treeService.getTreeCount(ngoId);
        _totalPages = (_totalCount / _limit).ceil();
        if (_totalPages == 0) _totalPages = 1;
      }

      final offset = (_currentPage - 1) * _limit;
      final pageTrees = await _treeService.getPaginatedTreesForNgo(
        ngoId: ngoId,
        limit: _limit,
        offset: offset,
      );

      setState(() {
        _isFirstLoad = false;
        _trees.clear();
        _trees.addAll(pageTrees);
      });
    } catch (e) {
      setState(() {
        _isFirstLoad = false;
        _errorMessage = 'Failed to load trees. Please check your internet connection.';
      });
      debugPrint('PlantedTreesScreen fetch error: $e');
    }
  }

  void _onPageChanged(int pageNum) {
    if (pageNum == _currentPage || pageNum < 1 || pageNum > _totalPages) return;
    setState(() {
      _currentPage = pageNum;
      _isFirstLoad = true;
    });
    _fetchTrees();
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
      _totalCount = 0;
      _isFirstLoad = true;
      _errorMessage = null;
    });
    await _fetchTrees();
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'healthy':
        return Colors.green.shade50;
      case 'needs_attention':
        return Colors.orange.shade50;
      case 'dead':
        return Colors.red.shade50;
      default:
        return Colors.green.shade50;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'healthy':
        return Colors.green.shade800;
      case 'needs_attention':
        return Colors.orange.shade800;
      case 'dead':
        return Colors.red.shade800;
      default:
        return Colors.green.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Planted Trees',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1B4332),
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isFirstLoad) {
      return _buildShimmerList();
    }

    if (_errorMessage != null && _trees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_trees.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🌲', style: TextStyle(fontSize: 64)),
                SizedBox(height: 16),
                Text(
                  'No trees planted yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._trees.map((tree) => _buildTreeCard(tree)),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => _onPageChanged(_currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: const Color(0xFF1B4332),
            disabledColor: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          ...List.generate(_totalPages, (index) {
            final pageNum = index + 1;
            final isSelected = pageNum == _currentPage;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                onTap: () => _onPageChanged(pageNum),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1B4332) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1B4332) : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$pageNum',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => _onPageChanged(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: const Color(0xFF1B4332),
            disabledColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildTreeCard(NewTreeModel tree) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => TreeDetailBottomSheet(tree: tree, isNgo: true),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tree Image (if available) or Placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: tree.firstPhotoUrl.isNotEmpty
                    ? (tree.firstPhotoUrl.startsWith('local://')
                        ? Image.file(
                            File(tree.firstPhotoUrl.replaceFirst('local://', '')),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: tree.firstPhotoUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B4332)),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ))
                    : Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                        child: const Center(child: Text('🌳', style: TextStyle(fontSize: 32))),
                      ),
              ),
              const SizedBox(width: 14),
              // Essential details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _getCleanTreeName(tree),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4332),
                              fontFamily: 'Nunito',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(tree.healthStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tree.healthEmoji, style: const TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                tree.healthLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(tree.healthStatus),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Tree ID/QR
                    Text(
                      'ID: ${tree.treeId ?? tree.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontFamily: 'Nunito',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Species
                    if (tree.treeSpecies != null && tree.treeSpecies!.isNotEmpty) ...[
                      Text(
                        'Species: ${tree.treeSpecies}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                          fontFamily: 'Nunito',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Plantation Date
                    Text(
                      'Planted: ${DateFormat('dd MMM yyyy').format(tree.plantingDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            tree.exactLocation != null && tree.exactLocation!.isNotEmpty
                                ? tree.exactLocation!
                                : 'Lat: ${tree.latitude.toStringAsFixed(4)}, Lng: ${tree.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontFamily: 'Nunito',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCleanTreeName(NewTreeModel tree) {
    if (tree.treeSpecies != null && tree.treeSpecies!.isNotEmpty) {
      final match = RegExp(r'\(([^)]+)\)').firstMatch(tree.treeSpecies!);
      if (match != null) {
        final commonName = match.group(1)!;
        return "${commonName[0].toUpperCase()}${commonName.substring(1)} Tree";
      }
    }

    String displayName = tree.treeName;
    final cleanRegex = RegExp(
      r'^(January|February|March|April|May|June|July|August|September|October|November|December)\s+',
      caseSensitive: false,
    );
    displayName = displayName.replaceFirst(cleanRegex, '');
    displayName = displayName.replaceAll(RegExp(r'\s+\d+$'), '');
    return displayName;
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(width: 80, height: 80, borderRadius: 12),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerLoading(width: 120, height: 16, borderRadius: 4),
                        ShimmerLoading(width: 60, height: 16, borderRadius: 4),
                      ],
                    ),
                    SizedBox(height: 8),
                    ShimmerLoading(width: 80, height: 12, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerLoading(width: 100, height: 12, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerLoading(width: 140, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
