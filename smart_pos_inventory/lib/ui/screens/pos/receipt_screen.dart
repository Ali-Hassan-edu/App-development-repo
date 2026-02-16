// lib/ui/screens/pos/receipt_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../state/reports/report_models.dart';
import 'receipt_pdf.dart';

class ReceiptScreen extends StatelessWidget {
  final SaleRecord sale;
  const ReceiptScreen({super.key, required this.sale});

  Future<Uint8List> _pdfBytes() async {
    // Uses your existing ReceiptPdf file
    return await ReceiptPdf.buildPdf(sale);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    final dt = DateTime.fromMillisecondsSinceEpoch(sale.createdAt);
    final date =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [
          IconButton(
            tooltip: 'Share PDF',
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final bytes = await _pdfBytes();
              await Printing.sharePdf(bytes: bytes, filename: 'receipt_${sale.id}.pdf');
            },
          ),
          IconButton(
            tooltip: 'Print',
            icon: const Icon(Icons.print_outlined),
            onPressed: () async {
              final bytes = await _pdfBytes();
              await Printing.layoutPdf(onLayout: (_) async => bytes);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Column(
              children: [
                Text('SMART POS', style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 6),
                Text('Invoice #${sale.id}', style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(date, style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 10),

                _row('Customer', sale.customerName.isEmpty ? 'Walk-in' : sale.customerName, text, sub),
                if (sale.customerPhone.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _row('Phone', sale.customerPhone, text, sub),
                ],
                const SizedBox(height: 6),
                _row('Payment', sale.paymentMethod, text, sub),

                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Items', style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 8),
                ...sale.items.map((it) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${it.name}  x${it.qty}',
                            style: TextStyle(color: text, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          'PKR${it.total.toStringAsFixed(2)}',
                          style: TextStyle(color: text, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 10),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 10),

                _row('Subtotal', 'PKR${sale.subTotal.toStringAsFixed(2)}', text, sub),
                const SizedBox(height: 6),
                _row('Discount', '- PKR${sale.discount.toStringAsFixed(2)}', text, sub),
                const SizedBox(height: 6),
                _row('Tax', '+ PKR${sale.tax.toStringAsFixed(2)}', text, sub),

                const SizedBox(height: 10),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 10),

                _row('Grand Total', 'PKR${sale.grandTotal.toStringAsFixed(2)}', text, sub, bold: true),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3CC5FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final bytes = await _pdfBytes();
                          await Printing.layoutPdf(onLayout: (_) async => bytes);
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Print', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String a, String b, Color text, Color sub, {bool bold = false}) {
    return Row(
      children: [
        Text(a, style: TextStyle(color: sub, fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(b, style: TextStyle(color: text, fontWeight: bold ? FontWeight.w900 : FontWeight.w800)),
      ],
    );
  }
}
