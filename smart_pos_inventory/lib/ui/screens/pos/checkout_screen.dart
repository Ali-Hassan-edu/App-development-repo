// lib/ui/screens/pos/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/pos/cart_provider.dart';
import '../../../services/receipt_share_service.dart';
import '../../../services/message_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  bool _processing = false;

  // ✅ Country dropdown (dial codes)
  final List<Map<String, String>> _countries = const [
    {'name': 'Pakistan', 'code': '+92'},
    {'name': 'India', 'code': '+91'},
    {'name': 'UAE', 'code': '+971'},
    {'name': 'Saudi', 'code': '+966'},
    {'name': 'UK', 'code': '+44'},
    {'name': 'USA', 'code': '+1'},
  ];

  String _dialCode = '+92';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  String _makeInvoiceNo() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'INV-$ms';
  }

  Future<void> _checkout() async {
    final cart = context.read<CartProvider>();

    final name = _name.text.trim();
    final phone = _phone.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter customer name')),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter customer phone')),
      );
      return;
    }
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    setState(() => _processing = true);

    // ✅ Save customer info into cart (for receipt)
    cart.setCustomer(name: name, phone: phone, dialCode: _dialCode);

    // TODO: here you can also save invoice into DB / Firebase etc.
    // For now: just create receipt + show share options.

    final invoiceNo = _makeInvoiceNo();
    final now = DateTime.now();

    final receiptItems = cart.items
        .map((l) => {
      'name': l.product.name,
      'qty': l.qty,
      'price': l.product.price.toStringAsFixed(2),
      'lineTotal': l.lineTotal.toStringAsFixed(2),
    })
        .toList();

    final receiptText = ReceiptShareService.buildReceiptText(
      shopName: 'Smart POS',
      invoiceNo: invoiceNo,
      customerName: cart.customerName,
      customerPhone: cart.fullPhone,
      dateTime: now,
      total: cart.subTotal,
      items: receiptItems,
    );

    setState(() => _processing = false);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Checkout Complete', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Text(
              'Receipt created.\n\nDo you want to send it to customer?\n\nCustomer: ${cart.customerName}\nPhone: ${cart.fullPhone}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final ok = await MessageLauncher.openSms(
                  phoneWithPlus: cart.fullPhone,
                  message: receiptText,
                );
                if (!ok && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('SMS app not available')),
                  );
                }
              },
              child: const Text('Send SMS', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            TextButton(
              onPressed: () async {
                final ok = await MessageLauncher.openWhatsApp(
                  phoneWithPlus: cart.fullPhone,
                  message: receiptText,
                );
                if (!ok && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('WhatsApp not available')),
                  );
                }
              },
              child: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear cart after successful checkout
                cart.clear();
                Navigator.pop(ctx);
                Navigator.pop(context); // back to cart screen
              },
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final fill = isDark ? const Color(0xFF121A31) : const Color(0xFFF6F7FB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Total: ₹${cart.subTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 14),

                // ✅ Country dropdown
                DropdownButtonFormField<String>(
                  value: _dialCode,
                  items: _countries
                      .map(
                        (c) => DropdownMenuItem<String>(
                      value: c['code']!,
                      child: Text('${c['name']} (${c['code']})'),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => setState(() => _dialCode = v ?? '+92'),
                  decoration: InputDecoration(
                    labelText: 'Country',
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Customer Phone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _processing ? null : _checkout,
                    icon: _processing
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _processing ? 'Processing...' : 'Confirm Checkout',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3CC5FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
}
