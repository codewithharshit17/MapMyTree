import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/ngo_service.dart';

class NgoAnalyticsTab extends StatefulWidget {
  const NgoAnalyticsTab({super.key});

  @override
  State<NgoAnalyticsTab> createState() => _NgoAnalyticsTabState();
}

class _NgoAnalyticsTabState extends State<NgoAnalyticsTab> {
  final NgoService _ngoService = NgoService();

  @override
  Widget build(BuildContext context) {
    final ngoId = context.read<AppAuthProvider>().userModel?.uid ?? '';
    final ngo = context.read<AppAuthProvider>().ngoModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analytics & Impact',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: Color(0xFF1B4332), fontFamily: 'Nunito')),
          const SizedBox(height: 4),
          const Text('Track your environmental impact',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),

          _buildCo2ImpactCard(ngo?.totalCo2Offset ?? 0),
          const SizedBox(height: 24),

          const Text('Monthly Trees Planted',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4332))),
          const SizedBox(height: 12),
          _buildMonthlyTreesChart(ngoId),
          const SizedBox(height: 28),

          const Text('Request Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4332))),
          const SizedBox(height: 12),
          _buildRequestPieChart(ngoId),
          const SizedBox(height: 28),

          const Text('Top Species Planted',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4332))),
          const SizedBox(height: 12),
          _buildSpeciesBreakdown(ngoId),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCo2ImpactCard(double totalCo2) {
    final carsEquivalent = (totalCo2 / 4600).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: const Color(0xFF1B4332).withValues(alpha: 0.3),
          blurRadius: 16, offset: const Offset(0, 8),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.cloud_outlined, color: Colors.white70, size: 20),
          SizedBox(width: 8),
          Text('Total CO₂ Offset',
              style: TextStyle(color: Colors.white70, fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Text('${totalCo2.toStringAsFixed(0)} kg',
            style: const TextStyle(color: Colors.white, fontSize: 36,
                fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
        const SizedBox(height: 8),
        Text('Equivalent to removing $carsEquivalent cars from the road for 1 year 🚗',
            style: const TextStyle(color: Colors.white60, fontSize: 13)),
      ]),
    );
  }

  Widget _buildMonthlyTreesChart(String ngoId) {
    return Container(
      height: 220, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: FutureBuilder<Map<String, int>>(
        future: _ngoService.getMonthlyTreesStats(ngoId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data yet',
                style: TextStyle(color: Colors.grey)));
          }
          final data = snapshot.data!;
          final sortedKeys = data.keys.toList()..sort();
          final maxVal =
              data.values.reduce((a, b) => a > b ? a : b).toDouble();

          return BarChart(BarChartData(
            maxY: maxVal + 2,
            barGroups: List.generate(sortedKeys.length, (i) =>
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: data[sortedKeys[i]]!.toDouble(),
                  color: const Color(0xFF2D6A4F), width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                ),
              ])),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedKeys.length) return const Text('');
                  final parts = sortedKeys[idx].split('-');
                  final months = ['','Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
                  final m = int.tryParse(parts.last) ?? 0;
                  return Text(m > 0 && m < months.length ? months[m] : '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey));
                },
              )),
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              )),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true, drawVerticalLine: false,
              horizontalInterval: maxVal > 5 ? maxVal / 4 : 1,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.withValues(alpha: 0.15), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
          ));
        },
      ),
    );
  }

  Widget _buildRequestPieChart(String ngoId) {
    return Container(
      height: 220, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: FutureBuilder<Map<String, int>>(
        future: _ngoService.getRequestStatusBreakdown(ngoId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('No data yet',
                style: TextStyle(color: Colors.grey)));
          }
          final data = snapshot.data!;
          final total = data.values.fold<int>(0, (sum, v) => sum + v);
          if (total == 0) {
            return const Center(child: Text('No requests yet',
                style: TextStyle(color: Colors.grey)));
          }

          final colors = {
            'pending': Colors.orange,
            'approved': Colors.green,
            'rejected': Colors.red,
          };

          return Row(children: [
            Expanded(flex: 3, child: PieChart(PieChartData(
              sections: data.entries.where((e) => e.value > 0).map((e) =>
                PieChartSectionData(
                  value: e.value.toDouble(),
                  color: colors[e.key] ?? Colors.grey,
                  title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(color: Colors.white,
                      fontSize: 12, fontWeight: FontWeight.bold),
                  radius: 55,
                )).toList(),
              centerSpaceRadius: 30, sectionsSpace: 2,
            ))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.map((e) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Container(width: 12, height: 12,
                        decoration: BoxDecoration(
                            color: colors[e.key] ?? Colors.grey,
                            borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 8),
                    Text(
                      '${e.key[0].toUpperCase()}${e.key.substring(1)}: ${e.value}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                )).toList(),
            )),
          ]);
        },
      ),
    );
  }

  Widget _buildSpeciesBreakdown(String ngoId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: FutureBuilder<Map<String, int>>(
        future: _ngoService.getSpeciesBreakdown(ngoId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No species data yet',
                  style: TextStyle(color: Colors.grey))));
          }
          final data = snapshot.data!;
          final sorted = data.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final top5 = sorted.take(5).toList();
          final maxVal = top5.first.value.toDouble();
          final colors = [
            const Color(0xFF1B4332), const Color(0xFF2D6A4F),
            const Color(0xFF40916C), const Color(0xFF52B788),
            const Color(0xFF74C69D),
          ];

          return Column(
            children: List.generate(top5.length, (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                SizedBox(width: 90, child: Text(top5[i].key,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w500))),
                const SizedBox(width: 8),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: top5[i].value / maxVal, minHeight: 14,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(colors[i]),
                  ),
                )),
                const SizedBox(width: 8),
                Text('${top5[i].value}',
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700, color: Colors.grey)),
              ]),
            )),
          );
        },
      ),
    );
  }
}
