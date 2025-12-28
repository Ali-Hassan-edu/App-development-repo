import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product.dart';
import '../../../state/products/product_provider.dart';
import '../../widgets/app_drawer.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProductSheet(),
    );
  }

  void _openEdit(BuildContext context, Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductSheet(editing: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();

    return Scaffold(
      drawer: const AppDrawer(activeRoute: AppRoutes.products),

      // ✅ Not white, not dark: soft professional gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4F7FF),
              Color(0xFFFFF6F9),
              Color(0xFFF6FFFB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(context).animate().fadeIn(duration: 240.ms).slideY(begin: .12),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<ProductProvider>().load(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _TopInfoCard(
                        title: 'Products',
                        subtitle: 'Add, edit, delete and manage your stock items.',
                        icon: Icons.inventory_2_outlined,
                        onAdd: () => _openAdd(context),
                      ).animate().fadeIn(duration: 280.ms).slideY(begin: .12),

                      const SizedBox(height: 14),

                      if (prov.loading) ...[
                        const SizedBox(height: 120),
                        const Center(child: CircularProgressIndicator()),
                      ] else if (prov.error != null) ...[
                        _ErrorBox(message: prov.error!),
                      ] else if (prov.items.isEmpty) ...[
                        _EmptyState(onAdd: () => _openAdd(context)),
                      ] else ...[
                        ...prov.items.asMap().entries.map((entry) {
                          final i = entry.key;
                          final p = entry.value;

                          return _ProductTile(
                            product: p,
                            onEdit: () => _openEdit(context, p),
                            onDelete: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Product'),
                                  content: Text('Delete "${p.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (ok != true) return;
                              final err = await context.read<ProductProvider>().deleteProduct(p.id);

                              if (!context.mounted) return;
                              if (err != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                              }
                            },
                          )
                              .animate()
                              .fadeIn(duration: 240.ms, delay: (i * 60).ms)
                              .slideX(begin: .06);
                        }),
                        const SizedBox(height: 90),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Big + FAB (animated + visible)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add, size: 30),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF3CC5FF),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
        duration: 900.ms,
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.06, 1.06),
        curve: Curves.easeInOut,
      ),
    );
  }

  // ✅ Custom top bar like dashboard (readable + drawer)
  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.inventory_2_outlined, color: Colors.black87),
          const SizedBox(width: 8),
          const Text(
            'Products',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87),
          ),
          const Spacer(),

          // ✅ big + in header too (visible + works)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openAdd(context),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF3CC5FF).withValues(alpha: 0.18),
                border: Border.all(color: const Color(0xFF3CC5FF).withValues(alpha: 0.35)),
              ),
              child: const Icon(Icons.add, size: 30, color: Color(0xFF3CC5FF)),
            ),
          ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(.95, .95)),

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onAdd;

  const _TopInfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3CC5FF).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.22),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onAdd,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.22),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 900.ms, begin: const Offset(1, 1), end: const Offset(1.08, 1.08)),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final price = product.price.toStringAsFixed(2);
    final stock = product.stock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              gradient: const LinearGradient(colors: [Color(0xFFFF5E7E), Color(0xFFFFC371)]),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'Price: ₹$price  •  Stock: $stock',
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                ),
                if ((product.sku ?? '').trim().isNotEmpty || (product.category ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${(product.sku ?? '').trim().isNotEmpty ? "SKU: ${product.sku}" : ""}'
                        '${((product.sku ?? '').trim().isNotEmpty && (product.category ?? '').trim().isNotEmpty) ? " • " : ""}'
                        '${(product.category ?? '').trim().isNotEmpty ? "Cat: ${product.category}" : ""}',
                    style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.black87)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 52),
          const SizedBox(height: 10),
          const Text('No products yet', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'Tap the button below to add your first product.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 26),
              label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CC5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: .08);
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ProductSheet extends StatefulWidget {
  final Product? editing;
  const _ProductSheet({this.editing});

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _stock = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editing;
    if (p != null) {
      _name.text = p.name;
      _sku.text = p.sku ?? '';
      _category.text = p.category ?? '';
      _price.text = p.price.toString();
      _cost.text = (p.cost == null) ? '' : p.cost.toString();
      _stock.text = p.stock.toString();
    } else {
      _stock.text = '0';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _category.dispose();
    _price.dispose();
    _cost.dispose();
    _stock.dispose();
    super.dispose();
  }

  double? _toDouble(String s) => double.tryParse(s.trim());
  int? _toInt(String s) => int.tryParse(s.trim());

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = _toDouble(_price.text);
    final stock = _toInt(_stock.text) ?? 0;
    final cost = _cost.text.trim().isEmpty ? null : _toDouble(_cost.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter product name')));
      return;
    }
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid price')));
      return;
    }

    setState(() => _saving = true);

    String? err;
    if (widget.editing == null) {
      err = await context.read<ProductProvider>().addProduct(
        name: name,
        sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
        category: _category.text.trim().isEmpty ? null : _category.text.trim(),
        price: price,
        cost: cost,
        stock: stock,
      );
    } else {
      final p = widget.editing!;
      err = await context.read<ProductProvider>().updateProduct(
        p.copyWith(
          name: name,
          sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
          category: _category.text.trim().isEmpty ? null : _category.text.trim(),
          price: price,
          cost: cost,
          stock: stock,
        ),
      );
    }

    setState(() => _saving = false);

    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.editing != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
                  ),
                  child: Icon(isEdit ? Icons.edit : Icons.add, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Product' : 'Add Product',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 12),

            _field(_name, 'Product Name', Icons.shopping_bag_outlined),
            const SizedBox(height: 10),
            _field(_sku, 'SKU (optional)', Icons.qr_code_2),
            const SizedBox(height: 10),
            _field(_category, 'Category (optional)', Icons.category_outlined),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _field(_price, 'Price', Icons.currency_rupee, isNumber: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(_cost, 'Cost (optional)', Icons.money_outlined, isNumber: true)),
              ],
            ),
            const SizedBox(height: 10),
            _field(_stock, 'Stock', Icons.inventory_2_outlined, isNumber: true),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CC5FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Icon(Icons.check, size: 24),
                label: Text(
                  _saving ? 'Saving...' : (isEdit ? 'Update Product' : 'Add Product'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 220.ms).slideY(begin: .12),
    );
  }

  Widget _field(
      TextEditingController c,
      String label,
      IconData icon, {
        bool isNumber = false,
      }) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
