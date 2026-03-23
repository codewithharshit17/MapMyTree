import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/sponsorship_request_model.dart';

class NgoRequestsTab extends StatefulWidget {
  const NgoRequestsTab({super.key});

  @override
  State<NgoRequestsTab> createState() => _NgoRequestsTabState();
}

class _NgoRequestsTabState extends State<NgoRequestsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateRequestStatus(
      SponsorshipRequest req, String newStatus) async {
    final supabase = Supabase.instance.client;
    final ngoId = context.read<AppAuthProvider>().userModel?.uid ?? '';

    await supabase.from('sponsorship_requests').update({
      'status': newStatus,
      'resolved_at': DateTime.now().toIso8601String(),
    }).eq('id', req.requestId);

    if (newStatus == 'approved') {
      await supabase.rpc('increment_ngo_trees', params: {'ngo_uid': ngoId});
      await supabase.rpc('increment_user_trees',
          params: {'user_uid': req.userId});
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(newStatus == 'approved'
            ? '✅ Request approved!'
            : '❌ Request rejected'),
        backgroundColor:
            newStatus == 'approved' ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      setState(() {}); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngoId = context.read<AppAuthProvider>().userModel?.uid ?? '';

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: _filters.map((f) => Tab(text: f)).toList(),
            labelColor: const Color(0xFF1B4332),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1B4332),
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _filters
                .map((filter) => _RequestList(
                    ngoId: ngoId,
                    filter: filter,
                    onUpdateStatus: _updateRequestStatus))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _RequestList extends StatelessWidget {
  final String ngoId;
  final String filter;
  final Future<void> Function(SponsorshipRequest, String) onUpdateStatus;

  const _RequestList({
    required this.ngoId,
    required this.filter,
    required this.onUpdateStatus,
  });

  Future<List<SponsorshipRequest>> _fetch() async {
    final supabase = Supabase.instance.client;
    
    final List<Map<String, dynamic>> rows;
    if (filter != 'All') {
      rows = await supabase
          .from('sponsorship_requests')
          .select()
          .eq('ngo_id', ngoId)
          .eq('status', filter.toLowerCase())
          .order('created_at', ascending: false);
    } else {
      rows = await supabase
          .from('sponsorship_requests')
          .select()
          .eq('ngo_id', ngoId)
          .order('created_at', ascending: false);
    }
    
    return rows.map((r) => SponsorshipRequest.fromJson(r)).toList();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SponsorshipRequest>>(
      future: _fetch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.grey)),
          );
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('📭', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                filter == 'All'
                    ? 'No requests yet'
                    : 'No ${filter.toLowerCase()} requests',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _RequestCard(
            request: requests[i],
            onApprove: () => onUpdateStatus(requests[i], 'approved'),
            onReject: () => onUpdateStatus(requests[i], 'rejected'),
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SponsorshipRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard(
      {required this.request, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status) {
      case 'approved': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

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
                request.userName.isNotEmpty
                    ? request.userName[0].toUpperCase() : '?',
                style: const TextStyle(color: Color(0xFF1B4332),
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.userName, style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
                Text(request.userEmail, style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(request.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('🌱 ', style: TextStyle(fontSize: 16)),
            Text('${request.treeSpecies}  •  ',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('₹${request.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Color(0xFF1B4332))),
          ]),
          if (request.message?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text('"${request.message}"',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13,
                    fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          Text(DateFormat('dd MMM yyyy, hh:mm a').format(request.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (request.isPending) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              )),
            ]),
          ],
        ]),
      ),
    );
  }
}
