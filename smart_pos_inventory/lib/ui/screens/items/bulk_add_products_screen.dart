import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../state/categories/category_provider.dart';
import '../../../state/products/product_provider.dart';

class BulkAddProductsScreen extends StatefulWidget {
  const BulkAddProductsScreen({super.key});

  @override
  State<BulkAddProductsScreen> createState() => _BulkAddProductsScreenState();
}

class _BulkAddProductsScreenState extends State<BulkAddProductsScreen> {
  bool _saving = false;

  final List<_RowModel> _rows = [_RowModel(), _RowModel(), _RowModel()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<CategoryProvider>().load();
    });
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_RowModel()));

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    final r = _rows.removeAt(index);
    r.dispose();
    setState(() {});
  }

  double? _toDouble(String s) => double.tryParse(s.trim());
  int? _toInt(String s) => int.tryParse(s.trim());

  Future<void> _saveAll() async {
    final payload = <Map<String, dynamic>>[];

    for (int i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      final name = r.name.text.trim();
      final sku = r.sku.text.trim();

      final price = _toDouble(r.price.text);
      final cost = r.cost.text.trim().isEmpty ? null : _toDouble(r.cost.text);
      final stock = _toInt(r.stock.text) ?? 0;

      final allEmpty = name.isEmpty &&
          sku.isEmpty &&
          (r.price.text.trim().isEmpty) &&
          (r.cost.text.trim().isEmpty) &&
          (r.stock.text.trim().isEmpty) &&
          (r.category == null || r.category!.trim().isEmpty);

      if (allEmpty) continue;

      payload.add({
        'name': name,
        'sku': sku.isEmpty ? null : sku,
        'category': (r.category == null || r.category!.trim().isEmpty) ? null : r.category!.trim(),
        'price': price,
        'cost': cost,
        'stock': stock,
      });
    }

    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least 1 product row')));
      return;
    }

    setState(() => _saving = true);
    final err = await context.read<ProductProvider>().addProductsBulk(payload);
    setState(() => _saving = false);

    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved ${payload.length} products')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<CategoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;

    final categoryList = cats.categories.map((e) => e.name).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Bulk Add Products', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Add Row',
            onPressed: _saving ? null : _addRow,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 92),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: const [
                Icon(Icons.tips_and_updates_outlined),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Add many products quickly.\nFill the rows and tap “Save All”.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 240.ms).slideY(begin: .10),

          const SizedBox(height: 12),

          ..._rows.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Row ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Remove row',
                        onPressed: _saving ? null : () => _removeRow(i),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  _field(r.name, 'Product Name *', Icons.shopping_bag_outlined),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(child: _field(r.sku, 'SKU (optional)', Icons.qr_code_2)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: (r.category != null && r.category!.isNotEmpty) ? r.category : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Category (optional)',
                            prefixIcon: const Icon(Icons.category_outlined),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF121A31) : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: categoryList
                              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => r.category = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(child: _field(r.price, 'Price (PKR) *', Icons.payments_outlined, isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _field(r.cost, 'Cost (PKR)', Icons.payments_outlined, isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _field(r.stock, 'Stock *', Icons.inventory_2_outlined, isNumber: true)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 220.ms, delay: (i * 70).ms).slideX(begin: .06);
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveAll,
              icon: _saving
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save All', style: const TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CC5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ).animate().fadeIn(duration: 260.ms).scale(begin: const Offset(.98, .98)),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF121A31) : Colors.white;

    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

class _RowModel {
  final name = TextEditingController();
  final sku = TextEditingController();
  final price = TextEditingController();
  final cost = TextEditingController();
  final stock = TextEditingController(text: '0');

  String? category;

  void dispose() {
    name.dispose();
    sku.dispose();
    price.dispose();
    cost.dispose();
    stock.dispose();
  }
}
