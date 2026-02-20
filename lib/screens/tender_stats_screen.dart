import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class TenderStatsScreen extends StatefulWidget {
  const TenderStatsScreen({super.key});

  @override
  State<TenderStatsScreen> createState() => _TenderStatsScreenState();
}

class _TenderStatsScreenState extends State<TenderStatsScreen> {
  final ApiService _apiService = ApiService();

  final List<ChartData> pieData = [
    ChartData('Material', 45, Colors.cyanAccent),
    ChartData('Labour', 25, Colors.blueAccent),
    ChartData('Profit', 20, Colors.greenAccent),
    ChartData('Tax/GST', 10, Colors.purpleAccent),
  ];

  Widget _buildLiveTicker() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _apiService.fetchLiveRates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 35,
              child: Center(child: LinearProgressIndicator(minHeight: 2)));
        }
        final rates = snapshot.data?['rates'] ?? {};
        return Container(
          height: 35,
          color: Colors.cyanAccent.withOpacity(0.05),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _tickerItem("STEEL: \$${(rates['STEEL'] is num) ? (rates['STEEL'] as num).toDouble().toStringAsFixed(2) : 'N/A'}", true),
              _tickerItem("IRON: \$${(rates['IRON'] is num) ? (rates['IRON'] as num).toDouble().toStringAsFixed(2) : 'N/A'}", false),
              _tickerItem("GOLD: \$${(rates['XAU'] is num) ? (rates['XAU'] as num).toDouble().toStringAsFixed(2) : 'N/A'}", true),
            ],
          ),
        );
      },
    );
  }

  Widget _tickerItem(String text, bool up) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(width: 4),
          Icon(up ? Icons.trending_up : Icons.trending_down, color: up ? Colors.greenAccent : Colors.redAccent, size: 14),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TENDER ANALYTICS")),
      body: Column(
        children: [
          _buildLiveTicker(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cost Breakdown", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 10),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: pieData
                            .map((data) => PieChartSectionData(
                                color: data.color,
                                value: data.y,
                                title: '${data.y.toInt()}%',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
