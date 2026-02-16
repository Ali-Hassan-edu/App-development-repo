import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/money.dart';
import '../../../data/models/product.dart';
import '../../../state/categories/category_provider.dart';
import '../../../state/products/product_provider.dart';
import '../../widgets/back_to_dashboard.dart';
import 'bulk_add_products_screen.dart';
import 'import_products_csv_screen.dart';

class ProductsScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  const ProductsScreen({super.key, required this.onMenuTap});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'All';

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => const _ProductSheet(),
    );
  }

  void _openEdit(BuildContext context, Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => _ProductSheet(editing: p),
    );
  }

  void _openBulk(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BulkAddProductsScreen()));
  }

  void _openCsvImport(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportProductsCsvScreen()));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.wait([
        context.read<ProductProvider>().load(),
        context.read<CategoryProvider>().load(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final cats = context.watch<CategoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
      colors: [Color(0xFF0F1320), Color(0xFF121A31), Color(0xFF0F1320)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFF4F7FF), Color(0xFFFFF6F9), Color(0xFFF6FFFB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final categories = [
      'All',
      ...cats.categories.map((e) => e.name).toSet().toList(),
    ];

    final filtered = (_selectedCategory == 'All')
        ? prov.items
        : prov.items.where((p) => (p.category ?? '').trim() == _selectedCategory).toList();

    return BackToDashboardWrapper(
      child: Scaffold(
        floatingActionButton: _fabMenu(
          isDark: isDark,
          onAdd: () => _openAdd(context),
          onBulk: () => _openBulk(context),
          onCsv: () => _openCsvImport(context),
        ),
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: bgGradient)),
            Column(
              children: [
                _topBar(context).animate().fadeIn(duration: 240.ms).slideY(begin: .12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait([
                        context.read<ProductProvider>().load(),
                        context.read<CategoryProvider>().load(),
                      ]);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                      children: [
                        _TopInfoCard(
                          title: 'Products',
                          subtitle: 'Manage items, prices, stock & categories.',
                          icon: Icons.inventory_2_outlined,
                        ).animate().fadeIn(duration: 280.ms).slideY(begin: .12),

                        const SizedBox(height: 12),

                        _categoryFilterCard(
                          isDark: isDark,
                          categories: categories,
                          selected: _selectedCategory,
                          onChanged: (v) => setState(() => _selectedCategory = v),
                        ).animate().fadeIn(duration: 320.ms).slideY(begin: .08),

                        const SizedBox(height: 14),

                        if (prov.loading || cats.loading) ...[
                          const SizedBox(height: 120),
                          const Center(child: CircularProgressIndicator()),
                        ] else if (prov.error != null) ...[
                          _ErrorBox(message: prov.error!),
                        ] else if (filtered.isEmpty) ...[
                          _EmptyState(onAdd: () => _openAdd(context)),
                        ] else ...[
                          ...filtered.asMap().entries.map((entry) {
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
                            ).animate().fadeIn(duration: 240.ms, delay: (i * 60).ms).slideX(begin: .06);
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.menu, color: titleColor), onPressed: widget.onMenuTap),
          const SizedBox(width: 8),
          Icon(Icons.inventory_2_outlined, color: titleColor),
          const SizedBox(width: 8),
          Text('Products', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor)),
        ],
      ),
    );
  }

  Widget _categoryFilterCard({
    required bool isDark,
    required List<String> categories,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, color: text),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selected,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Filter by Category',
                filled: true,
                fillColor: isDark ? const Color(0xFF121A31) : const Color(0xFFF6F7FB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              items: categories
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => onChanged(v ?? 'All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fabMenu({
    required bool isDark,
    required VoidCallback onAdd,
    required VoidCallback onBulk,
    required VoidCallback onCsv,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _miniFab(
          hero: 'csv',
          label: 'CSV',
          icon: Icons.upload_file,
          onTap: onCsv,
          gradient: const [Color(0xFFFF5E7E), Color(0xFFFFC371)],
        ).animate().fadeIn(duration: 240.ms).slideX(begin: .20),

        const SizedBox(height: 10),

        _miniFab(
          hero: 'bulk',
          label: 'Bulk',
          icon: Icons.playlist_add,
          onTap: onBulk,
          gradient: const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
        ).animate().fadeIn(duration: 280.ms).slideX(begin: .20),

        const SizedBox(height: 10),

        FloatingActionButton.extended(
          heroTag: 'add',
          onPressed: onAdd,
          backgroundColor: const Color(0xFF3CC5FF),
          icon: const Icon(Icons.add),
          label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w900)),
        ).animate().fadeIn(duration: 320.ms).slideX(begin: .20),
      ],
    );
  }

  Widget _miniFab({
    required String hero,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(colors: gradient),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _TopInfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
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
            color: const Color(0xFF3CC5FF).withOpacity(0.22),
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
              color: Colors.white.withOpacity(0.22),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.92), fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
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
                Text(product.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: titleColor)),
                const SizedBox(height: 4),
                Text(
                  '${pkr(product.price, decimals: 2)}  •  Stock: ${product.stock}  •  ${product.category ?? "No Category"}',
                  style: TextStyle(color: subColor, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: Icon(Icons.edit, color: titleColor)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161E35) : Colors.white.withOpacity(0.70);
    final text = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 52, color: text),
          const SizedBox(height: 10),
          Text('No products yet', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: text)),
          const SizedBox(height: 4),
          Text(
            'Tap "Add Product" to create your first item.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
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
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

/// ✅ Updated Product Sheet: Category Dropdown + PKR labels + better alignment
class _ProductSheet extends StatefulWidget {
  final Product? editing;
  const _ProductSheet({this.editing});

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _stock = TextEditingController();
  String? _selectedCategory;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editing;
    if (p != null) {
      _name.text = p.name;
      _sku.text = p.sku ?? '';
      _price.text = p.price.toString();
      _cost.text = (p.cost == null) ? '' : p.cost.toString();
      _stock.text = p.stock.toString();
      _selectedCategory = p.category;
    } else {
      _stock.text = '0';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
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
        category: (_selectedCategory == null || _selectedCategory!.trim().isEmpty) ? null : _selectedCategory!.trim(),
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
          category: (_selectedCategory == null || _selectedCategory!.trim().isEmpty) ? null : _selectedCategory!.trim(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cats = context.watch<CategoryProvider>();
    final categoryList = cats.categories.map((e) => e.name).toSet().toList()..sort();

    final sheetColor = isDark ? const Color(0xFF121A31) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 10))],
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
                      child: Icon(widget.editing == null ? Icons.add : Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.editing == null ? 'Add Product' : 'Edit Product',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: text),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: text),
                    )
                  ],
                ),

                const SizedBox(height: 12),

                _field(_name, 'Product Name', Icons.shopping_bag_outlined),
                const SizedBox(height: 10),
                _field(_sku, 'SKU (optional)', Icons.qr_code_2),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: (_selectedCategory != null && _selectedCategory!.isNotEmpty) ? _selectedCategory : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Category (optional)',
                    prefixIcon: const Icon(Icons.category_outlined),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF161E35) : const Color(0xFFF6F7FB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  items: categoryList
                      .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: _field(_price, 'Price (PKR)', Icons.payments_outlined, isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _field(_cost, 'Cost (PKR, optional)', Icons.payments_outlined, isNumber: true)),
                  ],
                ),

                const SizedBox(height: 10),

                _field(_stock, 'Stock', Icons.inventory_2_outlined, isNumber: true),

                const SizedBox(height: 18),

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
                      _saving ? 'Saving...' : (widget.editing == null ? 'Add Product' : 'Update Product'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 220.ms).slideY(begin: .12),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF161E35) : const Color(0xFFF6F7FB);
    final text = isDark ? Colors.white : Colors.black87;

    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: text, fontWeight: FontWeight.w700),
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
