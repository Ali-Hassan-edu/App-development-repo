import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/pos/cart_provider.dart';
import '../../../state/reports/report_provider.dart';
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

  // ✅ discount in rupees, tax in %
  final _discount = TextEditingController(text: '0');
  final _taxPercent = TextEditingController(text: '0');

  bool _processing = false;

  final List<Map<String, String>> _countries = const [
    {'name': 'Pakistan', 'code': '+92'},
    {'name': 'India', 'code': '+91'},
    {'name': 'UAE', 'code': '+971'},
    {'name': 'Saudi', 'code': '+966'},
    {'name': 'UK', 'code': '+44'},
    {'name': 'USA', 'code': '+1'},
  ];

  String _dialCode = '+92';

  // ✅ Payment methods (ALL)
  final List<String> _paymentMethods = const ['Cash', 'Card', 'UPI'];
  String _paymentMethod = 'Cash';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _discount.dispose();
    _taxPercent.dispose();
    super.dispose();
  }

  String _makeInvoiceNo() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'INV-$ms';
  }

  double _toDouble(String s) => double.tryParse(s.trim()) ?? 0;

  Future<void> _checkout() async {
    final cart = context.read<CartProvider>();

    final name = _name.text.trim();
    final phone = _phone.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter customer name')));
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter customer phone')));
      return;
    }
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    setState(() => _processing = true);

    // ✅ Apply discount + tax to provider
    cart.setDiscount(_toDouble(_discount.text));
    cart.setTaxPercent(_toDouble(_taxPercent.text));

    cart.setCustomer(name: name, phone: phone, dialCode: _dialCode);

    final invoiceNo = _makeInvoiceNo();
    final now = DateTime.now();

    final receiptItems = cart.items
        .map((l) => {
      'name': l.product.name,
      'qty': l.qty,
      'price': l.unitPrice.toStringAsFixed(2), // ✅ runtime price
      'lineTotal': l.lineTotal.toStringAsFixed(2),
    })
        .toList();

    final receiptText = ReceiptShareService.buildReceiptText(
      shopName: 'Smart POS',
      invoiceNo: invoiceNo,
      customerName: cart.customerName,
      customerPhone: cart.fullPhone,
      dateTime: now,
      subTotal: cart.subTotal,
      discount: cart.discountAmount,
      tax: cart.taxAmount,
      grandTotal: cart.grandTotal,
      items: receiptItems,
    );

    setState(() => _processing = false);
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Checkout Complete',
              style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Text(
              'Receipt created.\n\n'
                  'Customer: ${cart.customerName}\n'
                  'Phone: ${cart.fullPhone}\n'
                  'Payment: $_paymentMethod\n\n'
                  'Grand Total: ₹${cart.grandTotal.toStringAsFixed(2)}',
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
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('SMS app not available')));
                }
              },
              child:
              const Text('Send SMS', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            TextButton(
              onPressed: () async {
                final ok = await MessageLauncher.openWhatsApp(
                  phoneWithPlus: cart.fullPhone,
                  message: receiptText,
                );
                if (!ok && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('WhatsApp not available')));
                }
              },
              child: const Text('WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            ElevatedButton(
              onPressed: () async {
                // ✅ Save to reports before clearing
                final rep = context.read<ReportProvider>();
                await rep.addSaleFromCart(
                  invoiceId: invoiceNo,
                  cart: cart,
                  createdAt: now.millisecondsSinceEpoch,
                  paymentMethod: _paymentMethod, // ✅ SAVED
                );

                cart.clear();

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) Navigator.pop(context);
              },
              child:
              const Text('Done', style: TextStyle(fontWeight: FontWeight.w900)),
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
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ CART ITEMS (runtime price edit)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cart Items',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (cart.items.isEmpty)
                  const Text('No items')
                else
                  ...cart.items.map((l) {
                    final priceCtrl = TextEditingController(
                      text: l.unitPrice.toStringAsFixed(2),
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${l.qty}   Line: ₹${l.lineTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                isDense: true,
                              ),
                              onSubmitted: (v) {
                                final newPrice =
                                double.tryParse(v.trim());
                                if (newPrice == null || newPrice <= 0) return;
                                context
                                    .read<CartProvider>()
                                    .updateLinePrice(
                                  l.product.id,
                                  newPrice,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ✅ TOTALS + DISCOUNT + TAX + CUSTOMER + PAYMENT
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
                        'SubTotal: ₹${cart.subTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Discount (₹)',
                          filled: true,
                          fillColor: fill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => context
                            .read<CartProvider>()
                            .setDiscount(_toDouble(v)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _taxPercent,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Tax (%)',
                          filled: true,
                          fillColor: fill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => context
                            .read<CartProvider>()
                            .setTaxPercent(_toDouble(v)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Discount: ₹${cart.discountAmount.toStringAsFixed(2)}',
                        style:
                        const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tax: ₹${cart.taxAmount.toStringAsFixed(2)}',
                        style:
                        const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Grand Total: ₹${cart.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 14),

                // ✅ PAYMENT METHOD
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  items: _paymentMethods
                      .map(
                        (m) => DropdownMenuItem<String>(
                      value: m,
                      child: Text(m),
                    ),
                  )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _paymentMethod = v ?? 'Cash'),
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

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
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _processing ? 'Processing...' : 'Confirm Checkout',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3CC5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
