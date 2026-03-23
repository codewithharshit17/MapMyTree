import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/sponsorship_request_model.dart';

class NgoOverviewTab extends StatelessWidget {
  const NgoOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final ngoId = authProvider.userModel?.uid ?? '';
    final ngo = authProvider.ngoModel;
    final supabase = Supabase.instance.client;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${ngo?.ngoName ?? 'Partner'} 👋',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: Color(0xFF1B4332), fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 4),
          Text(
            ngo?.isVerified == true
                ? 'Your dashboard is live and active'
                : '⏳ Your account is pending verification',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Stats grid
          Row(children: [
            Expanded(child: _SupabaseStatCard(
              title: 'Trees Planted',
              icon: Icons.park,
              color: const Color(0xFF2D6A4F),
              future: supabase.from('trees').select('id').eq('ngo_id', ngoId)
                  .then((r) => r.length.toString()),
            )),
            const SizedBox(width: 12),
            Expanded(child: _SupabaseStatCard(
              title: 'Pending',
              icon: Icons.pending_actions,
              color: Colors.orange,
              future: supabase.from('sponsorship_requests').select('id')
                  .eq('ngo_id', ngoId).eq('status', 'pending')
                  .then((r) => r.length.toString()),
              highlightIfNonZero: true,
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _SupabaseStatCard(
              title: 'Sponsors',
              icon: Icons.people,
              color: const Color(0xFF0077B6),
              future: supabase.from('sponsorship_requests').select('user_id')
                  .eq('ngo_id', ngoId).eq('status', 'approved')
                  .then((r) => r.map((e) => e['user_id']).toSet().length.toString()),
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              title: 'CO₂ Offset',
              value: '${ngo?.totalCo2Offset.toStringAsFixed(0) ?? '0'} kg',
              icon: Icons.cloud_outlined,
              color: const Color(0xFF40916C),
            )),
          ]),

          const SizedBox(height: 28),
          const Text('Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: Color(0xFF1B4332), fontFamily: 'Nunito')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _QuickActionButton(
              icon: Icons.add_circle_outline, label: 'Add Tree',
              color: const Color(0xFF2D6A4F),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Tree coming soon'))),
            )),
            const SizedBox(width: 12),
            Expanded(child: _QuickActionButton(
              icon: Icons.description_outlined, label: 'Report',
              color: const Color(0xFF0077B6),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports coming soon'))),
            )),
          ]),

          const SizedBox(height: 28),
          const Text('Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: Color(0xFF1B4332), fontFamily: 'Nunito')),
          const SizedBox(height: 12),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: supabase
                .from('sponsorship_requests')
                .select()
                .eq('ngo_id', ngoId)
                .order('created_at', ascending: false)
                .limit(5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator()));
              }
              final rows = snapshot.data ?? [];
              if (rows.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Column(children: [
                    Text('📭', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 8),
                    Text('No requests yet',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ])),
                );
              }
              final requests =
                  rows.map((r) => SponsorshipRequest.fromJson(r)).toList();
              return Column(
                children: requests
                    .map((req) => _RequestListTile(request: req))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---- Widgets ----

class _SupabaseStatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Future<String> future;
  final bool highlightIfNonZero;

  const _SupabaseStatCard({
    required this.title, required this.icon,
    required this.color, required this.future,
    this.highlightIfNonZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: future,
      builder: (_, snap) {
        final value = snap.data ?? '…';
        final isHighlighted =
            highlightIfNonZero && (int.tryParse(value) ?? 0) > 0;
        return _StatCard(
          title: title, value: value, icon: icon, color: color,
          highlight: isHighlighted,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _StatCard({required this.title, required this.value,
      required this.icon, required this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: highlight ? Border.all(color: color.withValues(alpha: 0.3)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
            color: color, fontFamily: 'Nunito')),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 12,
            color: Colors.grey, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton(
      {required this.icon, required this.label,
       required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.2))),
          child: Column(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontSize: 13,
                fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _RequestListTile extends StatelessWidget {
  final SponsorshipRequest request;
  const _RequestListTile({required this.request});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status) {
      case 'approved': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
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
                fontWeight: FontWeight.w600, fontSize: 14)),
            Text('${request.treeSpecies} • ₹${request.amount.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Text(request.status.toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Text(DateFormat('dd MMM').format(request.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
      ]),
    );
  }
}
