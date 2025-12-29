import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final text = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Text(
          'Checkout Screen (Todo)',
          style: TextStyle(color: text, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
