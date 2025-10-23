import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/repo/user_repo.dart';
import '../../../utils/pdf_service.dart';

class _CartLine {
  String name;
  int qty;
  double price;
  _CartLine(this.name, this.qty, this.price);
}

class SalesEntryScreen extends StatefulWidget {
  const SalesEntryScreen({super.key});
  @override
  State<SalesEntryScreen> createState() => _SalesEntryScreenState();
}

class _SalesEntryScreenState extends State<SalesEntryScreen> {
  // Customer mode
  String _customerMode = 'New'; // 'New' or 'Existing'
  final _newName = TextEditingController();
  final _newPhone = TextEditingController();

  // Existing customer search
  final _searchCustomerCtrl = TextEditingController();
  List<Map<String, dynamic>> _allCustomers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  Map<String, dynamic>? _pickedCustomer;

  // Product search + live suggestions
  final _productSearchCtrl = TextEditingController();
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _foundProducts = []; // results when pressing Search

  // Cart
  final List<_CartLine> _cart = [];

  double get _cartSubtotal => _cart.fold(0.0, (p, e) => p + e.price * e.qty);
  double get _previousDue =>
      (_pickedCustomer?['previous_due'] as num?)?.toDouble() ?? 0.0;

  Future<void> _loadInitial() async {
    await UserRepo.seedDummyProductsIfEmpty();
    _allCustomers = await UserRepo.allCustomers();
    _filteredCustomers = _allCustomers;
    _allProducts = await UserRepo.products();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadInitial();

    _searchCustomerCtrl.addListener(() {
      final q = _searchCustomerCtrl.text.toLowerCase();
      _filteredCustomers = _allCustomers.where((c) {
        final n = (c['name'] ?? '').toString().toLowerCase();
        final p = (c['phone'] ?? '').toString().toLowerCase();
        return n.contains(q) || p.contains(q);
      }).toList();
      setState(() {});
    });

    _productSearchCtrl.addListener(() {
      final q = _productSearchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) {
        _suggestions = [];
      } else {
        _suggestions = _allProducts
            .where((p) =>
            (p['name'] ?? '').toString().toLowerCase().contains(q))
            .take(6)
            .toList();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCustomerCtrl.dispose();
    _productSearchCtrl.dispose();
    _newName.dispose();
    _newPhone.dispose();
    super.dispose();
  }

  // ----- Product search (button) -----
  Future<void> _searchProducts() async {
    final query = _productSearchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _foundProducts = []);
      return;
    }
    _foundProducts = _allProducts
        .where((p) =>
        (p['name'] ?? '').toString().toLowerCase().contains(query))
        .toList();
    setState(() {});
  }

  // ----- Cart ops -----
  void _addToCart(Map<String, dynamic> prod) {
    final idx = _cart.indexWhere(
          (e) => e.name.toLowerCase() == prod['name'].toString().toLowerCase(),
    );
    final price = (prod['price'] as num).toDouble();
    if (idx >= 0) {
      _cart[idx].qty++;
    } else {
      _cart.add(_CartLine(prod['name'], 1, price));
    }
    setState(() {});
  }

  void _removeLine(int i) {
    _cart.removeAt(i);
    setState(() {});
  }

  void _incQty(int i) {
    _cart[i].qty++;
    setState(() {});
  }

  void _decQty(int i) {
    if (_cart[i].qty > 1) {
      _cart[i].qty--;
      setState(() {});
    }
  }

  Future<void> _editPrice(int i) async {
    final ctrl =
    TextEditingController(text: _cart[i].price.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Price'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Price'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final v = double.tryParse(ctrl.text) ?? _cart[i].price;
      _cart[i].price = v;
      setState(() {});
    }
  }

  // ----- Complete sale -----
  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart is empty')));
      return;
    }

    int? customerId;
    String? phone;

    if (_customerMode == 'New') {
      if (_newName.text.trim().isEmpty ||
          _newPhone.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter name & phone')));
        return;
      }
      await UserRepo.upsertCustomer(
          name: _newName.text.trim(), phone: _newPhone.text.trim());
      final cust = await UserRepo.customerByPhone(_newPhone.text.trim());
      customerId = cust?['id'] as int?;
      phone = _newPhone.text.trim();
    } else {
      if (_pickedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select a customer')));
        return;
      }
      customerId = _pickedCustomer!['id'] as int?;
      phone = _pickedCustomer!['phone'] as String?;
    }

    final items = _cart
        .map((e) => {'name': e.name, 'qty': e.qty, 'price': e.price})
        .toList();
    final total = _cartSubtotal + _previousDue;

    final saleId = await UserRepo.insertSale(
        customerId: customerId, total: total, items: items);

    // adjust stock
    for (final it in _cart) {
      await UserRepo.adjustStock(it.name, -it.qty);
    }

    if (phone != null) await UserRepo.updateCustomerDue(phone, 0);

    final path = await PdfService.generateReceipt(
      saleId: saleId,
      customerPhone: phone,
      previousDue: _previousDue,
      total: total,
      lines: _cart
          .map((e) => PdfLine(name: e.name, qty: e.qty, price: e.price))
          .toList(),
    );

    if (phone != null && phone.isNotEmpty) {
      final msg = Uri.encodeComponent(
          'Thanks for your purchase! Sale #$saleId, Total Rs.${total.toStringAsFixed(0)}');
      final uri = Uri.parse('sms:$phone?body=$msg');
      try {
        await canLaunchUrl(uri) ? await launchUrl(uri) : null;
      } catch (_) {}
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale complete. Receipt saved: $path')));

    // reset
    _cart.clear();
    _pickedCustomer = null;
    _newName.clear();
    _newPhone.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Entry')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [s.primaryContainer, s.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ===== CUSTOMER =====
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('New'),
                          selected: _customerMode == 'New',
                          onSelected: (_) =>
                              setState(() => _customerMode = 'New'),
                        ),
                        ChoiceChip(
                          label: const Text('Existing'),
                          selected: _customerMode == 'Existing',
                          onSelected: (_) =>
                              setState(() => _customerMode = 'Existing'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_customerMode == 'New') ...[
                      TextField(
                        controller: _newName,
                        decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_add)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPhone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone)),
                      ),
                    ] else ...[
                      TextField(
                        controller: _searchCustomerCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Search by name or phone',
                            prefixIcon: Icon(Icons.search)),
                      ),
                      const SizedBox(height: 8),
                      if (_filteredCustomers.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: s.outlineVariant),
                              borderRadius: BorderRadius.circular(8)),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount:
                            _filteredCustomers.length.clamp(0, 5),
                            separatorBuilder: (_, __) =>
                            const Divider(height: 0),
                            itemBuilder: (_, i) {
                              final c = _filteredCustomers[i];
                              final picked =
                                  _pickedCustomer?['id'] == c['id'];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: picked
                                      ? s.primary
                                      : s.secondaryContainer,
                                  child: Icon(Icons.person,
                                      color: picked
                                          ? s.onPrimary
                                          : s.onSecondaryContainer),
                                ),
                                title: Text(c['name']),
                                subtitle: Text(c['phone']),
                                trailing: picked
                                    ? const Icon(Icons.check_circle)
                                    : const Icon(Icons.person_outline),
                                onTap: () =>
                                    setState(() => _pickedCustomer = c),
                              );
                            },
                          ),
                        ),
                    ],
                    if (_pickedCustomer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                            'Previous Due: Rs. ${_previousDue.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: s.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ),

            // ===== PRODUCT SEARCH (with live suggestions) =====
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Search Product',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              TextField(
                                controller: _productSearchCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Enter product name',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                              if (_suggestions.isNotEmpty)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 58,
                                  child: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxHeight: 260),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: _suggestions.length,
                                        separatorBuilder: (_, __) =>
                                        const Divider(height: 0),
                                        itemBuilder: (_, i) {
                                          final p = _suggestions[i];
                                          return ListTile(
                                            dense: true,
                                            title: Text(
                                              p['name'],
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight:
                                                  FontWeight.w600),
                                            ),
                                            subtitle: Text(
                                              'Rs. ${(p['price'] as num).toStringAsFixed(0)}',
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons
                                                  .add_shopping_cart),
                                              onPressed: () => _addToCart(p),
                                            ),
                                            onTap: () => _addToCart(p),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _searchProducts,
                          icon: const Icon(Icons.manage_search),
                          label: const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_foundProducts.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _foundProducts.map((p) {
                          return Card(
                            color: s.surfaceVariant,
                            child: ListTile(
                              title: Text(
                                p['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                  'Rs. ${(p['price'] as num).toStringAsFixed(0)} • Stock: ${p['stock']}'),
                              trailing: FilledButton(
                                onPressed: () => _addToCart(p),
                                child: const Text('Add to Cart'),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // ===== CART (REWORKED) =====
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: s.surface,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Cart',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    if (_cart.isEmpty)
                      const Text('No items in cart'),
                    ..._cart.asMap().entries.map((e) {
                      final i = e.key;
                      final it = e.value;
                      return _CartRow(
                        name: it.name,
                        qty: it.qty,
                        price: it.price,
                        onEditPrice: () => _editPrice(i),
                        onDec: () => _decQty(i),
                        onInc: () => _incQty(i),
                        onRemove: () => _removeLine(i),
                      );
                    }),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          'Subtotal: Rs. ${_cartSubtotal.toStringAsFixed(0)}'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          'Previous Due: Rs. ${_previousDue.toStringAsFixed(0)}'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: Rs. ${(_cartSubtotal + _previousDue).toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _completeSale,
                      icon: const Icon(Icons.done_all),
                      label: const Text('Complete Sale'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clean, compact cart row that never crushes the product name.
class _CartRow extends StatelessWidget {
  final String name;
  final int qty;
  final double price;
  final VoidCallback onEditPrice;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onRemove;

  const _CartRow({
    required this.name,
    required this.qty,
    required this.price,
    required this.onEditPrice,
    required this.onDec,
    required this.onInc,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final total = (price * qty);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT: name + math
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${price.toStringAsFixed(0)} × $qty = Rs. ${total.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: s.outline),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // RIGHT: compact actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit price',
                iconSize: 20,
                onPressed: onEditPrice,
                icon: const Icon(Icons.edit),
                constraints:
                const BoxConstraints.tightFor(width: 36, height: 36),
              ),
              IconButton(
                tooltip: 'Decrease',
                iconSize: 22,
                onPressed: onDec,
                icon: const Icon(Icons.remove_circle_outline),
                constraints:
                const BoxConstraints.tightFor(width: 36, height: 36),
              ),
              Text('$qty',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              IconButton(
                tooltip: 'Increase',
                iconSize: 22,
                onPressed: onInc,
                icon: const Icon(Icons.add_circle_outline),
                constraints:
                const BoxConstraints.tightFor(width: 36, height: 36),
              ),
              IconButton(
                tooltip: 'Remove',
                iconSize: 22,
                onPressed: onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
                constraints:
                const BoxConstraints.tightFor(width: 36, height: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
