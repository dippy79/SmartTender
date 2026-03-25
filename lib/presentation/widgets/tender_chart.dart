import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TenderChart extends StatelessWidget {
  final double base;
  final double extra;
  final double profit;

  const TenderChart({super.key, required this.base, required this.extra, required this.profit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(color: Colors.blue, value: base, title: 'Base', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
            PieChartSectionData(color: Colors.orange, value: extra, title: 'Extra', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
            PieChartSectionData(color: Colors.green, value: profit, title: 'Profit', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}