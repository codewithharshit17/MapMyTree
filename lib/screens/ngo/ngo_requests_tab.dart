import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/request_model.dart';
import '../../services/request_service.dart';
import '../../services/new_tree_service.dart';
import '../../widgets/tree_detail_bottom_sheet.dart';
import 'add_tree_screen.dart';
import '../user_profile_screen.dart';

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
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: request.userId),
              ));
            },
            child: Row(children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1B4332).withValues(alpha: 0.1),
                child: Text(
                  request.userName != null && request.userName!.isNotEmpty ? request.userName![0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(request.userName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1B4332), decoration: TextDecoration.underline)),
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
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('🌱 ', style: TextStyle(fontSize: 16)),
            Expanded(child: Text(request.treeType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            if (request.plantCost != null)
              Text('₹${request.plantCost}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1B4332))),
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

          // ── Payment Status Badge ──────────────────────────────────────
          const SizedBox(height: 10),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: request.isPaymentVerified
                    ? Colors.green.withValues(alpha: 0.12)
                    : request.isPaymentPendingVerification
                        ? Colors.blue.withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: request.isPaymentVerified
                      ? Colors.green
                      : request.isPaymentPendingVerification
                          ? Colors.blue
                          : Colors.red,
                  width: 0.5,
                ),
              ),
              child: Text(
                request.paymentStatusLabel,
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: request.isPaymentVerified
                      ? Colors.green.shade700
                      : request.isPaymentPendingVerification
                          ? Colors.blue.shade700
                          : Colors.red.shade700,
                ),
              ),
            ),
          ]),

          // ── Payment Screenshot ────────────────────────────────────────
          if (request.paymentScreenshotUrl != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CachedNetworkImage(
                        imageUrl: request.paymentScreenshotUrl!,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: request.paymentScreenshotUrl!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text('Tap screenshot to view full size', style: TextStyle(color: Colors.grey, fontSize: 11)),

            // Verify Payment button (only if pending_verification)
            if (request.isPaymentPendingVerification && isPending) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await RequestService().updatePaymentStatus(request.id, 'verified');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Payment verified!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.verified_rounded, size: 16),
                  label: const Text('Verify Payment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
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
                label: const Text('🌱 Request Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332))),
                  );
                  final tree = await NewTreeService().getTreeByRequestId(request.id);
                  if (context.mounted) Navigator.pop(context); // pop loading
                  if (tree != null && context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => TreeDetailBottomSheet(tree: tree, isNgo: true),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load tree details.')));
                  }
                },
                icon: const Icon(Icons.qr_code, size: 16),
                label: const Text('View Info Card'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B4332),
                  side: const BorderSide(color: Color(0xFF1B4332)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
