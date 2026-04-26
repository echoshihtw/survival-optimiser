import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';

class CashChart extends StatelessWidget {
  final List<MonthlyState> months;
  final double safetyCash;

  const CashChart({super.key, required this.months, required this.safetyCash});

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'NO DATA',
            style: TextStyle(
              color: AppColors.dimGreen,
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final spots = months
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.balance))
        .toList();

    final maxY = months.map((m) => m.balance).reduce((a, b) => a > b ? a : b);
    final minY = months.map((m) => m.balance).reduce((a, b) => a < b ? a : b);

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          backgroundColor: AppColors.background,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.panelBorder, strokeWidth: 1),
            getDrawingVerticalLine: (_) =>
                FlLine(color: AppColors.panelBorder, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          minY: minY < 0 ? minY * 1.1 : 0,
          maxY: maxY * 1.1,
          lineBarsData: [
            // Balance line
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: AppColors.primaryGreen,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            // Zero line
            LineChartBarData(
              spots: [FlSpot(0, 0), FlSpot(months.length - 1.0, 0)],
              isCurved: false,
              color: AppColors.danger,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
            // Safety threshold line
            LineChartBarData(
              spots: [
                FlSpot(0, safetyCash),
                FlSpot(months.length - 1.0, safetyCash),
              ],
              isCurved: false,
              color: AppColors.gold,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
          ],
        ),
      ),
    );
  }
}
