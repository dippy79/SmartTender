import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/tender_import_model.dart';
import 'supabase_client.dart';

class ExportService {
  static Future<int> saveToDatabase(List<TenderImportRow> rows) async {
    final validRows = rows.where((r) => r.validationError == null).toList();
    if (validRows.isEmpty) {
      throw Exception('No valid rows to save');
    }

    final maps = validRows.map((r) => r.toSupabaseMap()).toList();
    final response = await SupabaseClientHelper.client.from('tenders').insert(maps);
    return response.length;
  }

  static Future<Uint8List> generatePdf(List<TenderImportRow> rows) async {
    final pdf = pw.Document();

    final validRows = rows.where((r) => r.validationError == null).toList();
    final totalValue = validRows.fold<double>(0, (sum, r) => sum + r.value);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('SmartTender Hub', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Imported Tenders Report', style: pw.TextStyle(fontSize: 18)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Title', 'Department', 'Value (₹)', 'Deadline', 'Status'],
            data: validRows.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;
              return [
                '${idx + 1}',
                row.title,
                row.department,
                '₹${NumberFormat('#,###').format(row.value)}',
                DateFormat('dd MMM yyyy').format(row.deadline),
                row.status,
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#f0f0f0'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Tenders: ${validRows.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Total Value: ₹${NumberFormat('#,###').format(totalValue)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );

    return await pdf.save();
  }

  static Future<void> shareWhatsApp(List<TenderImportRow> rows) async {
    final validRows = rows.where((r) => r.validationError == null).toList();
    final summary = validRows.take(5).map((r) => 
      '• ${r.title.substring(0, min(40, r.title.length))} | ₹${NumberFormat('#,###').format(r.value)} | ${r.status}'
    ).join('\\n');
    final text = '🏗 SmartTender Hub Import\\n\\n$summary\\n\\nTotal: ${validRows.length} tenders | Value: ₹${NumberFormat('#,###').format(validRows.fold(0.0, (s, r) => s + r.value))}\\n\\n📱 Sent from SmartTender Hub';
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> shareEmail(List<TenderImportRow> rows) async {
    final validRows = rows.where((r) => r.validationError == null).toList();
    final subject = 'SmartTender Hub - ${validRows.length} Tenders Import';
    final body = 'SmartTender Hub processed ${validRows.length} tenders.\\n\\nTotal Value: ₹${NumberFormat('#,###').format(validRows.fold(0.0, (s, r) => s + r.value))}\\n\\nGenerated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}';
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {'subject': subject, 'body': body},
    );
    await launchUrl(uri);
  }

  static Future<void> downloadExcel(Uint8List bytes, String filename) async {
    if (!kIsWeb) throw UnimplementedError('Download only supported on web');
    // Web implementation requires dart:html conditional import
    // Implementation in screen widget for now
  }
}

