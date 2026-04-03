import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/request_model.dart';
import '../../services/request_service.dart';
import 'add_tree_screen.dart';

class NgoRequestsTab extends StatefulWidget {
  const NgoRequestsTab({super.key});
  @override
  State<NgoRequestsTab> createState() => _NgoRequestsTabState();
}

class _NgoRequestsTabState extends State<NgoRequestsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _requestService = RequestService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Completed')],
          labelColor: const Color(0xFF1B4332),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1B4332),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      Expanded(
        child: TabBarView(controller: _tabController, children: [
          _ReqList(status: 'pending', svc: _requestService, onRefresh: () => setState(() {})),
          _ReqList(status: 'completed', svc: _requestService, onRefresh: () => setState(() {})),
        ]),
      ),
    ]);
  }
}

class _ReqList extends StatelessWidget {
  final String status;
  final RequestService svc;
  final VoidCallback onRefresh;
  const _ReqList({required this.status, required this.svc, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1B4332),
      onRefresh: () async => onRefresh(),
      child: FutureBuilder<List<RequestModel>>(
        future: status == 'pending' ? svc.getPendingRequests() : svc.getCompletedRequests(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reqs = snap.data ?? [];
          if (reqs.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(status == 'pending' ? '📭' : '✅', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(status == 'pending' ? 'No pending requests' : 'No completed requests',
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ]));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ReqCard(request: reqs[i], isPending: status == 'pending'),
          );
        },
      ),
    );
  }
}

class _ReqCard extends StatelessWidget {
  final RequestModel request;
  final bool isPending;
  const _ReqCard({required this.request, required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1B4332).withValues(alpha: 0.1),
              child: Text(
                request.userName != null && request.userName!.isNotEmpty ? request.userName![0].toUpperCase() : '?',
                style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(request.userName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(DateFormat('dd MMM yyyy').format(request.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isPending ? Colors.orange : Colors.green).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(request.statusLabel,
                  style: TextStyle(color: isPending ? Colors.orange : Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('🌱 ', style: TextStyle(fontSize: 16)),
            Text(request.treeType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          if (request.preferredLocation != null && request.preferredLocation!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(request.preferredLocation!, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            ]),
          ],
          if (request.description != null && request.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('"${request.description}"', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic)),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Plant Tree'), backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white),
                    body: AddTreeScreen(prefilledRequest: request),
                  ),
                )),
                icon: const Icon(Icons.eco, size: 16),
                label: const Text('🌱 Mark as Planted'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
