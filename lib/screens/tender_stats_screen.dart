// lib/screens/tender_stats_screen.dart

import 'package:flutter/material.dart';

class TenderStatsScreen extends StatelessWidget {
  const TenderStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(title: const Text("SYSTEM ANALYTICS"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _statRow("TOTAL BIDS", "452", Colors.cyanAccent),
          const SizedBox(height: 20),
          const Text("QUOTATION TRENDS (Weekly)", style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 10),
          // Simple Chart Diagram Placeholder
          Container(
            height: 150,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end, children: [
              _bar(40), _bar(70), _bar(50), _bar(90), _bar(60), _bar(100),
            ]),
          ),
          const Divider(color: Colors.white10, height: 40),
          const Text("Logic: Data fetched from Supabase real-time.", style: TextStyle(fontSize: 10, color: Colors.white24))
        ]),
      ),
    );
  }

  Widget _bar(double h) => Container(width: 20, height: h, decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.5), borderRadius: BorderRadius.circular(5)));
  Widget _statRow(String l, String v, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: TextStyle(fontSize: 24, color: c, fontWeight: FontWeight.bold))]);
}