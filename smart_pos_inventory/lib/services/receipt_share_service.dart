class ReceiptShareService {
  static String buildReceiptText({
    required String shopName,
    required String invoiceNo,
    required String customerName,
    required String customerPhone,
    required DateTime dateTime,
    required double subTotal,
    required double discount,
    required double tax,
    required double grandTotal,
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
      final price = (it['price'] ?? '0').toString();
      final lineTotal = (it['lineTotal'] ?? '0').toString();
      b.writeln('$name  x$qty  @ ₹$price  = ₹$lineTotal');
    }

    b.writeln('-------------------------');
    b.writeln('SUBTOTAL: ₹${subTotal.toStringAsFixed(2)}');
    b.writeln('DISCOUNT: -₹${discount.toStringAsFixed(2)}');
    b.writeln('TAX:      +₹${tax.toStringAsFixed(2)}');
    b.writeln('-------------------------');
    b.writeln('TOTAL: ₹${grandTotal.toStringAsFixed(2)}');
    b.writeln('-------------------------');
    b.writeln('Thanks for shopping!');

    return b.toString();
  }

  static String toWhatsAppDigits(String phoneWithPlus) {
    return phoneWithPlus.replaceAll('+', '').replaceAll(RegExp(r'[^0-9]'), '');
  }
}
