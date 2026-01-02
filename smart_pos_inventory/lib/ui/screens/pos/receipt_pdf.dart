// lib/ui/screens/pos/receipt_pdf.dart
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../state/reports/report_models.dart';

class ReceiptPdf {
  static Future<Uint8List> buildPdf(SaleRecord sale) async {
    final pdf = pw.Document();

    final dt = DateTime.fromMillisecondsSinceEpoch(sale.createdAt);
    final date =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'SMART POS',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Invoice Receipt',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _kv('Invoice', sale.id),
                  _kv('Date', date),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _kv('Payment', sale.paymentMethod),
                  _kv('Customer', sale.customerName.isEmpty ? 'Walk-in' : sale.customerName),
                ],
              ),
              if (sale.customerPhone.trim().isNotEmpty) ...[
                pw.SizedBox(height: 4),
                _kvFull('Phone', sale.customerPhone.trim()),
              ],

              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.SizedBox(height: 10),
              pw.Text('Items', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _th('Item'),
                      _th('Qty'),
                      _th('Price'),
                      _th('Total'),
                    ],
                  ),
                  ...sale.items.map((i) {
                    return pw.TableRow(
                      children: [
                        _td(i.name),
                        _td(i.qty.toString(), alignRight: true),
                        _td('₹${i.unitPrice.toStringAsFixed(2)}', alignRight: true),
                        _td('₹${i.total.toStringAsFixed(2)}', alignRight: true),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 14),
              pw.Divider(),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 260,
                  child: pw.Column(
                    children: [
                      _moneyRow('Subtotal', sale.subTotal),
                      _moneyRow('Discount', -sale.discount),
                      _moneyRow('Tax', sale.tax),
                      pw.SizedBox(height: 6),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Grand Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('₹${sale.grandTotal.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Thank you!',
                  style: pw.TextStyle(color: PdfColors.grey700, fontSize: 11),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _kv(String k, String v) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(k, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(v, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _kvFull(String k, String v) {
    return pw.Row(
      children: [
        pw.Text('$k: ', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(v, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _th(String t) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(t, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
    );
  }

  static pw.Widget _td(String t, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: pw.Text(t, style: const pw.TextStyle(fontSize: 10)),
      ),
    );
  }

  static pw.Widget _moneyRow(String label, double value) {
    final sign = value < 0 ? '-' : '';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.Text('$sign₹${value.abs().toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }
}
