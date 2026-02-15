import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbService.fetchTenders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tenders = snapshot.data!;
          if (tenders.isEmpty) return const Center(child: Text("No projects found."));

          return ListView.builder(
            itemCount: tenders.length,
            itemBuilder: (context, index) {
              final t = tenders[index];
              final date = DateTime.parse(t['created_at']);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text("${t['business_type']} - ₹${t['total_base']}"),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(date)),
                  trailing: _buildStatusWidget(t),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusWidget(Map<String, dynamic> tender) {
    if (tender['status'] == 'Pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () async {
              await _dbService.updateTenderStatus(tender['id'], 'Won');
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () async {
              await _dbService.updateTenderStatus(tender['id'], 'Lost');
              setState(() {});
            },
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: tender['status'] == 'Won' ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tender['status'],
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}