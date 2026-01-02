// lib/ui/screens/pos/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/pos/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Cart (${cart.count})'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => context.read<CartProvider>().clear(),
              child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w900)),
            )
        ],
      ),
      body: cart.items.isEmpty
          ? Center(child: Text('Cart is empty', style: TextStyle(color: sub, fontWeight: FontWeight.w800)))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...cart.items.map((line) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.product.name,
                            style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('₹${line.product.price.toStringAsFixed(2)}',
                            style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.read<CartProvider>().dec(line.product),
                    icon: Icon(Icons.remove_circle_outline, color: sub),
                  ),
                  Text('${line.qty}', style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                  IconButton(
                    onPressed: () => context.read<CartProvider>().inc(line.product),
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3CC5FF)),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Column(
              children: [
                _row('Subtotal', '₹${cart.subTotal.toStringAsFixed(2)}', text, sub),
                const SizedBox(height: 6),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 6),
                _row('Total', '₹${cart.subTotal.toStringAsFixed(2)}', text, sub, bold: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3CC5FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    ),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.w900)),
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
