import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/tender_model.dart';

class TenderDetailsScreen extends StatelessWidget {
  final Tender tender;
  const TenderDetailsScreen({super.key, required this.tender});

  void _share() {
    final text = "📢 *New Tender Opportunity*\n\n"
        "🏢 *Title:* ${tender.title}\n"
        "🏛️ *Dept:* ${tender.department}\n"
        "💰 *Value:* ₹${tender.value.toStringAsFixed(0)}\n"
        "📅 *Deadline:* ${tender.deadline.toLocal().toString().split(' ')[0]}\n"
        "📂 *Category:* ${tender.category}\n\n"
        "🔗 *Apply Here:* ${tender.link ?? 'Link Not Available'}\n\n"
        "Shared via Smart Tender App";

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tender Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _share,
            tooltip: "Share Tender",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tender.type == TenderType.private ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tender.type == TenderType.private ? "PRIVATE SECTOR" : "GOVERNMENT SECTOR",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: tender.type == TenderType.private ? Colors.orange : Colors.green
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(tender.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 24),

            _buildInfoRow(Icons.business_center, "Department", tender.department),
            _buildInfoRow(Icons.category_outlined, "Category", tender.category),
            _buildInfoRow(Icons.payments_outlined, "Estimated Value", "₹${tender.value.toStringAsFixed(2)}", isHighlight: true),
            _buildInfoRow(Icons.calendar_month_outlined, "Submission Deadline", tender.deadline.toLocal().toString().split(' ')[0]),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Link opening logic can be added here
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text("VIEW OFFICIAL DOCUMENT", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.cyanAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.cyanAccent : Colors.white
              )),
            ],
          ),
        ],
      ),
    );
  }
}
