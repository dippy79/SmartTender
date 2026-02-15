import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../models/boq_item.dart';

class TenderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> tender;
  const TenderDetailsScreen({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    // Converting JSON items back to BOQItem objects for PDF service compatibility
    final List<dynamic> rawItems = tender['items'];
    final List<BOQItem> items = rawItems.map((item) => BOQItem(
      id: '',
      name: item['name'],
      quantity: (item['qty'] as num).toDouble(),
      baseRate: (item['rate'] as num).toDouble(),
    )).toList();

    double totalBase = tender['total_base'];
    double margin = tender['margin'];
    double finalQuote = totalBase * (1 + margin / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text("Tender Details", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tender['business_type'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Saved on: ${tender['created_at'].toString().split('T')[0]}", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          // BOQ List
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item.quantity} x ₹${item.baseRate}"),
                  trailing: Text("₹${item.totalBaseCost.toStringAsFixed(0)}"),
                );
              },
            ),
          ),
          // Summary & PDF Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(
              children: [
                _row("Base Total", totalBase),
                _row("Margin Applied", "$margin%"),
                const Divider(),
                _row("Final Quote", finalQuote, isBold: true),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => PdfService.generateAndSharePdf(
                      businessType: tender['business_type'],
                      clientName: 'Client',
                      items: items,
                      subTotal: totalBase,
                      gstAmount: 0,
                      grandTotal: finalQuote,
                      terms: 'Standard terms and conditions apply.',
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("RE-GENERATE PDF"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _row(String label, dynamic val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val is String ? val : "₹${val.toStringAsFixed(2)}", style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Tender?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await DatabaseService().deleteTender(tender['id']);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to history
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}