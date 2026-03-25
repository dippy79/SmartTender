import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/tender_model.dart';
import '../../../core/theme/app_theme.dart';

enum TenderType { private, government }

class TenderDetailsScreen extends StatelessWidget {
  final Tender tender;
  const TenderDetailsScreen({super.key, required this.tender});

  String get _link => tender.link ?? 'N/A (use tender ID: ${tender.id})';

  void _share() {
    final text = "📢 *New Tender Opportunity*\n\n"
        "🏢 *Title:* ${tender.title}\n"
        "🏛️ *Dept:* ${tender.department}\n"
        "💰 *Value:* ₹${tender.value.toStringAsFixed(0)}\n"
        "📅 *Deadline:* ${tender.deadline.toLocal().toString().split(' ')[0]}\n"
        "📂 *Category:* ${tender.category}\n\n"
        "🔗 *Apply Here:* $_link\n\n"
        "Shared via Smart Tender App";

    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final type = tender.type as TenderType? ?? TenderType.government;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tender Details"),
        foregroundColor: AppTheme.goldPrimary,
        backgroundColor: AppTheme.surfaceElevated.withValues(alpha: 0.85),
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
                color: type == TenderType.private 
                  ? AppTheme.accentRed.withValues(alpha: 0.1) 
                  : AppTheme.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type == TenderType.private ? "PRIVATE SECTOR" : "GOVERNMENT SECTOR",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: type == TenderType.private 
                    ? AppTheme.accentRed 
                    : AppTheme.accentGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tender.title, 
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2, color: AppTheme.textPrimary),
            ),
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
                  // Link opening logic - use url_launcher for tender.link
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text("VIEW OFFICIAL DOCUMENT", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
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
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated.withValues(alpha: 0.5), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: AppTheme.accentBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                Text(value, style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? AppTheme.goldPrimary : AppTheme.textPrimary,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

