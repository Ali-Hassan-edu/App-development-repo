class ReceiptShareService {
  static String buildReceiptText({
    required String shopName,
    required String invoiceNo,
    required String customerName,
    required String customerPhone,
    required DateTime dateTime,
    required double total,
    required List<Map<String, dynamic>> items,
  }) {
    final b = StringBuffer();

    b.writeln('🧾 $shopName');
    b.writeln('Invoice: $invoiceNo');
    b.writeln('Date: ${dateTime.toLocal()}');
    b.writeln('Customer: $customerName ($customerPhone)');
    b.writeln('-------------------------');

    for (final it in items) {
      final name = (it['name'] ?? '').toString();
      final qty = (it['qty'] ?? 0).toString();
      final lineTotal = (it['lineTotal'] ?? 0).toString();
      b.writeln('$name  x$qty  = ₹$lineTotal');
    }

    b.writeln('-------------------------');
    b.writeln('TOTAL: ₹${total.toStringAsFixed(2)}');
    b.writeln('-------------------------');
    b.writeln('Thanks for shopping!');

    return b.toString();
  }

  static String toWhatsAppDigits(String phoneWithPlus) {
    return phoneWithPlus.replaceAll('+', '').replaceAll(RegExp(r'[^0-9]'), '');
  }
}
