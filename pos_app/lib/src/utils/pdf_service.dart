import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfLine {
  final String name;
  final int qty;
  final double price;
  PdfLine({required this.name, required this.qty, required this.price});
}

class SalesRow {
  final int id;
  final DateTime createdAt;
  final double total;
  SalesRow({required this.id, required this.createdAt, required this.total});
}

class PdfService {
  static Future<Directory> _downloadsDir() async {
    final dl = Directory('/storage/emulated/0/Download/POS_Receipts');
    try {
      if (!(await dl.exists())) await dl.create(recursive: true);
      return dl;
    } catch (_) {
      final docs = await getApplicationDocumentsDirectory();
      final fb = Directory('${docs.path}/POS_Receipts');
      if (!(await fb.exists())) await fb.create(recursive: true);
      return fb;
    }
  }

  static Future<String> generateReceipt({
    required int saleId,
    String? customerPhone,
    required List<PdfLine> lines,
    required double total,
    double previousDue = 0,
  }) async {
    final doc = pw.Document();
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('POS Receipt', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Sale #$saleId  •  $date'),
            if (customerPhone != null && customerPhone.isNotEmpty) pw.Text('Customer: $customerPhone'),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: const ['Item', 'Qty', 'Price', 'Total'],
              data: lines.map((l) => [
                l.name,
                l.qty.toString(),
                l.price.toStringAsFixed(0),
                (l.qty * l.price).toStringAsFixed(0),
              ]).toList(),
            ),
            pw.SizedBox(height: 10),
            if (previousDue > 0)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Previous Due: Rs. ${previousDue.toStringAsFixed(0)}'),
              ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Grand Total: Rs. ${total.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    final dir = await _downloadsDir();
    final file = File('${dir.path}/receipt_$saleId.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  static Future<String> generateSalesReport({
    required String title,
    required List<SalesRow> rows,
  }) async {
    final doc = pw.Document();
    final fmt = NumberFormat.currency(symbol: 'Rs. ');
    final total = rows.fold<double>(0, (p, e) => p + e.total);

    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}'),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: const ['Sale ID', 'Date/Time', 'Amount'],
              data: rows.map((r) => [
                r.id.toString(),
                DateFormat('dd MMM, hh:mm a').format(r.createdAt),
                fmt.format(r.total),
              ]).toList(),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Total: ${fmt.format(total)}',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    final dir = await _downloadsDir();
    final safe = title.toLowerCase().replaceAll(' ', '_');
    final file = File('${dir.path}/${safe}_report.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }
}
