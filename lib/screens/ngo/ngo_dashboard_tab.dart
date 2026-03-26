import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/session_helper.dart';
import '../../models/new_tree_model.dart';
import '../../services/new_tree_service.dart';
import '../../services/request_service.dart';
import 'package:intl/intl.dart';

class NgoDashboardTab extends StatefulWidget {
  const NgoDashboardTab({super.key});

  @override
  State<NgoDashboardTab> createState() => _NgoDashboardTabState();
}

class _NgoDashboardTabState extends State<NgoDashboardTab> {
  final _treeService = NewTreeService();
  final _requestService = RequestService();

  Future<Map<String, dynamic>> _loadStats() async {
    final ngoId = SessionHelper.userId;
    final results = await Future.wait([
      _treeService.getTreeCount(ngoId),
      _requestService.getPendingRequestCount(),
      _requestService.getCompletedRequestCount(),
      _treeService.getTreesThisMonth(ngoId),
      _treeService.getRecentTrees(ngoId, limit: 5),
      _treeService.getMonthlyStats(ngoId),
    ]);
    return {
      'totalTrees': results[0] as int,
      'pendingRequests': results[1] as int,
      'completedRequests': results[2] as int,
      'treesThisMonth': results[3] as int,
      'recentTrees': results[4] as List<NewTreeModel>,
      'monthlyStats': results[5] as Map<String, int>,
    };
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1B4332),
      onRefresh: () async => setState(() {}),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data!;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${SessionHelper.userName} 👋',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                      fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 4),
                const Text('Your dashboard overview',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),

                // Stats cards
                Row(children: [
                  Expanded(
                      child: _StatCard(
                    title: 'Total Trees',
                    value: '${stats['totalTrees']}',
                    icon: Icons.park,
                    color: const Color(0xFF2D6A4F),
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _StatCard(
                    title: 'Pending',
                    value: '${stats['pendingRequests']}',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    highlight: (stats['pendingRequests'] as int) > 0,
                  )),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _StatCard(
                    title: 'Completed',
                    value: '${stats['completedRequests']}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _StatCard(
                    title: 'This Month',
                    value: '${stats['treesThisMonth']}',
                    icon: Icons.calendar_today,
                    color: const Color(0xFF0077B6),
                  )),
                ]),

                const SizedBox(height: 28),
                const Text('Monthly Plantations',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B4332))),
                const SizedBox(height: 12),
                _buildMonthlyChart(
                    stats['monthlyStats'] as Map<String, int>),

                const SizedBox(height: 28),
                const Text('Recent Activity',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B4332))),
                const SizedBox(height: 12),
                _buildRecentActivity(
                    stats['recentTrees'] as List<NewTreeModel>),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _skeletonCard()),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard()),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _skeletonCard()),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard()),
          ]),
          const SizedBox(height: 28),
          _skeletonCard(height: 220),
        ],
      ),
    );
  }

  Widget _skeletonCard({double height = 100}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildMonthlyChart(Map<String, int> data) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: data.isEmpty
          ? const Center(
              child: Text('No data yet',
                  style: TextStyle(color: Colors.grey)))
          : Builder(builder: (context) {
              final sortedKeys = data.keys.toList()..sort();
              final maxVal = data.values.isNotEmpty
                  ? data.values.reduce((a, b) => a > b ? a : b).toDouble()
                  : 1.0;

              return BarChart(BarChartData(
                maxY: maxVal + 2,
                barGroups: List.generate(
                    sortedKeys.length,
                    (i) => BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: data[sortedKeys[i]]!.toDouble(),
                            color: const Color(0xFF2D6A4F),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ])),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= sortedKeys.length) {
                        return const Text('');
                      }
                      final parts = sortedKeys[idx].split('-');
                      final months = [
                        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                      ];
                      final m = int.tryParse(parts.last) ?? 0;
                      return Text(
                          m > 0 && m < months.length ? months[m] : '',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey));
                    },
                  )),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                  )),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 5 ? maxVal / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.15),
                      strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              ));
            }),
    );
  }

  Widget _buildRecentActivity(List<NewTreeModel> trees) {
    if (trees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
        child: const Center(
            child: Column(children: [
          Text('🌲', style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text('No trees planted yet',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ])),
      );
    }

    return Column(
      children: trees.map((tree) => _RecentTreeTile(tree: tree)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFamily: 'Nunito')),
            const SizedBox(height: 2),
            Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ]),
    );
  }
}

class _RecentTreeTile extends StatelessWidget {
  final NewTreeModel tree;
  const _RecentTreeTile({required this.tree});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('🌳', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tree.treeName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            Text(
                '${tree.treeSpecies ?? 'Unknown species'} • ${DateFormat('dd MMM yyyy').format(tree.plantingDate)}',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )),
        Text(tree.healthEmoji, style: const TextStyle(fontSize: 18)),
      ]),
    );
  }
}
