// lib/ui/screens/pos/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../state/customers/customer_models.dart';
import '../../../state/customers/customer_provider.dart';
import '../../../state/pos/cart_provider.dart';
import '../../../state/reports/report_models.dart';
import '../../../state/reports/report_provider.dart';
import 'receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Customer? _customer;
  String _payment = 'Cash';

  final _discount = TextEditingController(text: '0'); // flat
  final _taxPercent = TextEditingController(text: '0'); // %

  bool _paying = false;

  @override
  void dispose() {
    _discount.dispose();
    _taxPercent.dispose();
    super.dispose();
  }

  double _toDouble(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  Future<void> _pickCustomer() async {
    final picked = await showModalBottomSheet<Customer?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => const _CustomerPickerSheet(),
    );

    if (!mounted) return;
    setState(() => _customer = picked);
  }

  Future<void> _pay() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final discount = _toDouble(_discount).clamp(0, 999999).toDouble();
    final taxPercent = _toDouble(_taxPercent).clamp(0, 100).toDouble();

    final subTotal = cart.subTotal;
    final afterDiscount = (subTotal - discount) < 0 ? 0.0 : (subTotal - discount);
    final tax = afterDiscount * (taxPercent / 100.0);
    final grand = afterDiscount + tax;

    setState(() => _paying = true);

    try {
      final items = cart.items
          .map(
            (l) => SaleLineItem(
          productId: l.product.id,
          name: l.product.name,
          qty: l.qty,
          unitPrice: l.product.price,
        ),
      )
          .toList();

      final record = SaleRecord(
        id: const Uuid().v4().substring(0, 8).toUpperCase(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        customerName: (_customer?.name.trim().isNotEmpty ?? false) ? _customer!.name : 'Walk-in',
        customerPhone: _customer?.phone ?? '',
        paymentMethod: _payment,
        subTotal: subTotal,
        discount: discount,
        tax: tax,
        grandTotal: grand,
        items: items,
      );

      await context.read<ReportProvider>().addSale(record);

      cart.clear();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ReceiptScreen(sale: record)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    final discount = _toDouble(_discount);
    final taxPercent = _toDouble(_taxPercent);

    final subTotal = cart.subTotal;
    final afterDiscount = (subTotal - discount) < 0 ? 0.0 : (subTotal - discount);
    final tax = afterDiscount * (taxPercent / 100.0);
    final grand = afterDiscount + tax;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Customer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: Color(0xFF3CC5FF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer', style: TextStyle(color: sub, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        (_customer?.name.trim().isNotEmpty ?? false) ? _customer!.name : 'Walk-in',
                        style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      if ((_customer?.phone ?? '').trim().isNotEmpty)
                        Text(_customer!.phone, style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _pickCustomer,
                  child: const Text('Select', style: TextStyle(fontWeight: FontWeight.w900)),
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Payment method
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Method', style: TextStyle(color: sub, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['Cash', 'UPI', 'Card'].map((m) {
                    final selected = _payment == m;
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => _payment = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: selected ? const Color(0xFF3CC5FF).withOpacity(0.18) : Colors.transparent,
                          border: Border.all(
                            color: selected ? const Color(0xFF3CC5FF) : (isDark ? Colors.white12 : Colors.black12),
                          ),
                        ),
                        child: Text(m, style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Discount + tax
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _discount,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Discount (flat)',
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _taxPercent,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Tax %',
                    prefixIcon: Icon(Icons.percent),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Column(
              children: [
                _row('Subtotal', '₹${subTotal.toStringAsFixed(2)}', text, sub),
                const SizedBox(height: 6),
                _row('Discount', '- ₹${discount.toStringAsFixed(2)}', text, sub),
                const SizedBox(height: 6),
                _row('Tax', '+ ₹${tax.toStringAsFixed(2)}', text, sub),
                const SizedBox(height: 6),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 6),
                _row('Grand Total', '₹${grand.toStringAsFixed(2)}', text, sub, bold: true),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3CC5FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _paying ? null : _pay,
                    icon: _paying
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _paying ? 'Processing...' : 'Pay & Generate Receipt',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
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

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet();

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF121A31) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;

    final list = prov.search(_q.text);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Select Customer', style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 16)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: text)),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _q,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search...'),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () => Navigator.pop<Customer?>(context, null),
              leading: const Icon(Icons.person_outline),
              title: Text('Walk-in', style: TextStyle(color: text, fontWeight: FontWeight.w900)),
              subtitle: const Text('No customer selected'),
            ),
            Divider(color: border),
            if (prov.loading)
              const Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator())
            else if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text('No customers found'),
              )
            else
              ...list.take(10).map((c) {
                return ListTile(
                  onTap: () => Navigator.pop<Customer?>(context, c),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF3CC5FF).withOpacity(0.18),
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3CC5FF)),
                    ),
                  ),
                  title: Text(c.name, style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                  subtitle: Text(c.phone),
                );
              }),
          ],
        ),
      ),
    );
  }
}
