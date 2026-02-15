import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/boq_item.dart';

class PdfService {
  static Future<void> generateAndSharePdf({
    required String businessType,
    required String clientName,
    required List<BOQItem> items,
    required double subTotal,
    required double gstAmount,
    required double grandTotal,
    required String terms,
  }) async {
    final pdf = pw.Document();
    final dateStr = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("QUOTATION", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text("Category: $businessType"),
            pw.Text("Date: $dateStr"),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.Text("To: $clientName", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Qty', 'Rate', 'Total'],
              data: items.map((i) => [i.name, i.quantity, i.baseRate, i.quantity * i.baseRate]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(children: [
                pw.Text("Sub Total: Rs. ${subTotal.toStringAsFixed(2)}"),
                pw.Text("GST (18%): Rs. ${gstAmount.toStringAsFixed(2)}"),
                pw.Divider(),
                pw.Text("Grand Total: Rs. ${grandTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ]),
            ),
            pw.Spacer(),
            pw.Text("Terms:"),
            pw.Text(terms, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Quotation.pdf');
  }
}