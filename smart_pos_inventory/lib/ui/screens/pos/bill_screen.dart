// lib/ui/screens/pos/bill_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/products/product_provider.dart';
import '../../../state/pos/cart_provider.dart';
import 'cart_screen.dart';

class BillScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  const BillScreen({super.key, required this.onMenuTap});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;

    final prov = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    final q = _search.text.trim().toLowerCase();
    final items = prov.items.where((p) {
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.sku ?? '').toLowerCase().contains(q) ||
          (p.category ?? '').toLowerCase().contains(q);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
          colors: [Color(0xFF0F1320), Color(0xFF121A31), Color(0xFF0F1320)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFFF4F7FF), Color(0xFFFFF6F9), Color(0xFFF6FFFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.menu, color: titleColor), onPressed: widget.onMenuTap),
                const SizedBox(width: 8),
                Icon(Icons.receipt_long, color: titleColor),
                const SizedBox(width: 8),
                Text(
                  'Bill / POS',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor),
                ),
                const Spacer(),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart_outlined, color: titleColor),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                      },
                    ),
                    if (cart.totalQty > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${cart.totalQty}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search products (name / sku / category)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF161E35) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProductProvider>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                children: [
                  if (prov.loading) ...[
                    const SizedBox(height: 140),
                    const Center(child: CircularProgressIndicator()),
                  ] else if (prov.error != null) ...[
                    _Err(prov.error!),
                  ] else if (items.isEmpty) ...[
                    const SizedBox(height: 120),
                    Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ] else ...[
                    ...items.map((p) => _ProductCard(productName: p.name, stock: p.stock, price: p.price, onAdd: () {
                      if (p.stock <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Out of stock')));
                        return;
                      }
                      context.read<CartProvider>().addProduct(p);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added "${p.name}"')));
                    })),
                    const SizedBox(height: 90),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String productName;
  final int stock;
  final double price;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.productName,
    required this.stock,
    required this.price,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final title = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName, style: TextStyle(color: title, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Stock: $stock  •  ₹${price.toStringAsFixed(2)}',
                    style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3CC5FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          )
        ],
      ),
    );
  }
}

class _Err extends StatelessWidget {
  final String msg;
  const _Err(this.msg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}
