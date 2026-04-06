import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/session_helper.dart';
import '../../models/new_tree_model.dart';
import '../../models/request_model.dart';
import '../../services/new_tree_service.dart';
import '../../services/request_service.dart';
import '../../widgets/tree_detail_bottom_sheet.dart';

class UserTreesTab extends StatefulWidget {
  const UserTreesTab({super.key});
  @override
  State<UserTreesTab> createState() => _UserTreesTabState();
}

class _UserTreesTabState extends State<UserTreesTab> {
  final _treeService = NewTreeService();
  final _requestService = RequestService();


  late Stream<List<NewTreeModel>> _treeStream;
  late Stream<List<dynamic>> _requestStream;
  String? _currentStreamingId;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    final userId = SessionHelper.userId;
    if (userId.isEmpty) {
      debugPrint('UserTreesTab: User not logged in, skipping stream initialization');
      _treeStream = Stream.value([]);
      _requestStream = Stream.value([]);
      _currentStreamingId = '';
      return;
    }
    _currentStreamingId = userId;
    debugPrint('UserTreesTab: Initializing streams for userId: "$userId"');
    _treeStream = _treeService.streamUserTrees(userId);
    _requestStream = _requestService.streamUserRequests(userId);
  }

  @override
  Widget build(BuildContext context) {
    // Reactively re-init streams if userId changes (e.g. via DevSession toggle)
    if (_currentStreamingId != SessionHelper.userId) {
      _initStreams();
    }
    
    return RefreshIndicator(
      color: const Color(0xFF1B4332),
      onRefresh: () async {
        setState(() {
          _initStreams(); // Reconnect streams on manual pull
        });
      },
      child: StreamBuilder<List<NewTreeModel>>(
        stream: _treeStream,
        builder: (context, treeSnap) {
          return StreamBuilder<List<dynamic>>(
            stream: _requestStream,
            builder: (context, requestSnap) {
              if (treeSnap.hasError || requestSnap.hasError) {
                debugPrint('UserTreesTab: Stream Error - Tree: ${treeSnap.error}, Req: ${requestSnap.error}');
                return Center(child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Connection Error: ${treeSnap.error ?? requestSnap.error}', textAlign: TextAlign.center),
                    TextButton(onPressed: () => setState(() => _initStreams()), child: const Text('Retry'))
                  ]),
                ));
              }

              if (treeSnap.connectionState == ConnectionState.waiting && requestSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (SessionHelper.userId.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(children: [
                    Icon(Icons.login, color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text('Please log in to view your trees', textAlign: TextAlign.center),
                  ]),
                ));
              }

              final trees = treeSnap.data ?? [];
              final requests = requestSnap.data ?? [];
              
              debugPrint('UserTreesTab: Data received - Trees: ${trees.length}, Reqs: ${requests.length}');
              
              final totalRequested = requests.length;
              final treesPlanted = trees.length;
              final pendingRequests = requests.where((r) => r.status == 'pending').length;

              // Fallback if userId was empty when streams were first created
              if (SessionHelper.userId.isNotEmpty && (trees.isEmpty && requests.isEmpty)) {
                 // Potentially the user just logged in or state updated
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Diagnostic info (collapsible or small)
                  if (!kReleaseMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('Debug ID: ${SessionHelper.userId}', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                    ),
                  
                  Text('Hello, ${SessionHelper.userName} 👋',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1B4332), fontFamily: 'Nunito')),
                  const SizedBox(height: 4),
                  const Text('Your tree journey', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 20),
                  // Dynamic Stats Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                        children: [
                          _stat('Requested', '$totalRequested', Icons.send_rounded, Colors.blue),
                          _stat('Pending', '$pendingRequests', Icons.hourglass_empty_rounded, Colors.orange),
                          _stat('Planted', '$treesPlanted', Icons.park_rounded, const Color(0xFF2D6A4F)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text('🌿 My Tree Gallery', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1B4332))),
                  const SizedBox(height: 4),
                  const Text('Trees that have been successfully planted for you', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  if (trees.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: const Column(
                        children: [
                          Text('🌱', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 12),
                          Text('Your forest is empty', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1B4332))),
                          SizedBox(height: 4),
                          Text('Submit a request to start your journey!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ...trees.map((t) => _TreeCard(tree: t)),

                  if (requests.where((r) => r.status != 'completed').isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text('⏳ Active Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1B4332))),
                    const SizedBox(height: 4),
                    const Text('Track the progress of your tree requests', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    ...requests.where((r) => r.status != 'completed').map((r) => _RequestCard(request: r)),
                  ],
                  const SizedBox(height: 40),
                ]),
              );
            }
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'Nunito',
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _placeholder() => Container(
  width: 64, height: 64,
  decoration: BoxDecoration(color: const Color(0xFF2D6A4F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
  child: const Center(child: Text('🌳', style: TextStyle(fontSize: 28))),
);

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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => TreeDetailBottomSheet(tree: tree, isNgo: false),
        );
      },
      child: Container(
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
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (request.status) {
      case 'pending': statusColor = Colors.orange; statusLabel = 'Pending'; break;
      case 'in_progress': statusColor = Colors.blue; statusLabel = 'In Progress'; break;
      case 'completed': statusColor = Colors.green; statusLabel = 'Completed'; break;
      default: statusColor = Colors.grey; statusLabel = 'Unknown';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: const Color(0xFF2D6A4F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('🌱', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(request.treeType, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 2),
          Text(request.preferredLocation ?? 'No location specified', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Requested ${DateFormat('dd MMM yyyy').format(request.createdAt)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ])),
    );
  }
}
