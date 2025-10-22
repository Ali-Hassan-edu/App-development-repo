import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_db.dart';
import '../../../utils/pdf_service.dart';
import 'package:url_launcher/url_launcher.dart';

enum CustomerMode { newCustomer, oldCustomer }

class SalesEntryScreen extends StatefulWidget {
  const SalesEntryScreen({super.key});
  @override
  State<SalesEntryScreen> createState() => _SalesEntryScreenState();
}

class _SalesEntryScreenState extends State<SalesEntryScreen> {
  final _search = TextEditingController();
  List<Map<String, Object?>> _products = [];
  final List<_CartLine> _cart = [];

  CustomerMode _mode = CustomerMode.newCustomer;
  String? _newCustomerPhone;
  String? _newCustomerName;
  int? _oldCustomerId;
  double _oldCustomerPending = 0;
  List<Map<String, Object?>> _allCustomers = [];

  Future<void> _loadProducts([String q = '']) async {
    final db = await AppDB().database;
    final rows = await db.query(
      'products',
      where: q.isEmpty ? null : 'name LIKE ?',
      whereArgs: q.isEmpty ? null : ['%$q%'],
    );
    setState(() => _products = rows);
  }

  Future<void> _loadCustomers() async {
    final db = await AppDB().database;
    final rows = await db.query('customers', orderBy: 'name');
    setState(() => _allCustomers = rows);
  }

  Future<void> _loadOldCustomerPending() async {
    if (_oldCustomerId == null) { _oldCustomerPending = 0; return; }
    final db = await AppDB().database;
    final rows = await db.query('customers', where: 'id = ?', whereArgs: [_oldCustomerId]);
    _oldCustomerPending = rows.isNotEmpty ? (rows.first['pending_balance'] as num? ?? 0).toDouble() : 0;
  }

  Future<int> _ensureNewCustomer({required String phone, String? name}) async {
    final db = await AppDB().database;
    final rows = await db.query('customers', where: 'phone = ?', whereArgs: [phone], limit: 1);
    if (rows.isNotEmpty) return rows.first['id'] as int;
    final id = await db.insert('customers', {'name': name ?? phone, 'phone': phone});
    await _loadCustomers(); // refresh Existing dropdown immediately
    return id;
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCustomers();
  }

  double get cartSubtotal => _cart.fold(0, (p, e) => p + e.qty * e.price);
  double get total => cartSubtotal + (_mode == CustomerMode.oldCustomer ? _oldCustomerPending : 0);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: Column(children: [
        // Customer mode
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('New Customer'),
                selected: _mode == CustomerMode.newCustomer,
                onSelected: (_) => setState(() => _mode = CustomerMode.newCustomer),
              ),
              ChoiceChip(
                label: const Text('Existing Customer'),
                selected: _mode == CustomerMode.oldCustomer,
                onSelected: (_) => setState(() => _mode = CustomerMode.oldCustomer),
              ),
            ],
          ),
        ),
        if (_mode == CustomerMode.newCustomer)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Customer Name (optional)'),
                onChanged: (v) => _newCustomerName = v.trim(),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Customer Phone (required)'),
                keyboardType: TextInputType.phone,
                onChanged: (v) => _newCustomerPhone = v.trim(),
              ),
            ]),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<int>(
              value: _oldCustomerId,
              decoration: const InputDecoration(labelText: 'Select existing customer'),
              items: _allCustomers.map((c) => DropdownMenuItem(
                value: c['id'] as int,
                child: Text('${c['name'] ?? c['phone']}  (Pending: Rs. ${(c['pending_balance'] as num? ?? 0).toString()})'),
              )).toList(),
              onChanged: (v) async {
                setState(() => _oldCustomerId = v);
                await _loadOldCustomerPending();
                setState(() {});
              },
            ),
          ),

        // Search + products
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search product'),
            onChanged: (v) => _loadProducts(v.trim()),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (_, i) {
              final p = _products[i];
              return Card(
                child: ListTile(
                  title: Text('${p['name']}'),
                  subtitle: Text('Price: ${p['price']}  •  Stock: ${p['stock_qty']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      setState(() => _cart.add(_CartLine(
                        productId: p['id'] as int,
                        name: p['name'] as String,
                        price: (p['price'] as num).toDouble(),
                        qty: 1,
                      )));
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: scheme.surfaceVariant),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cart.map((e) => Chip(label: Text('${e.name} x${e.qty}'))).toList(),
              ),
              const SizedBox(height: 8),
              if (_mode == CustomerMode.oldCustomer)
                Text('Previous due: Rs. ${_oldCustomerPending.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Subtotal: Rs. ${cartSubtotal.toStringAsFixed(0)}'),
              Text('Total: Rs. ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Sale'),
                onPressed: _cart.isEmpty ? null : () async {
                  final db = await AppDB().database;

                  int customerId;
                  String? phoneForSms;

                  if (_mode == CustomerMode.newCustomer) {
                    if (_newCustomerPhone == null || _newCustomerPhone!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Phone required for new customer')),
                      );
                      return;
                    }
                    customerId = await _ensureNewCustomer(phone: _newCustomerPhone!, name: _newCustomerName);
                    phoneForSms = _newCustomerPhone!;
                  } else {
                    if (_oldCustomerId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select an existing customer')),
                      );
                      return;
                    }
                    customerId = _oldCustomerId!;
                    final r = await db.query('customers', where: 'id = ?', whereArgs: [customerId], limit: 1);
                    phoneForSms = r.isNotEmpty ? r.first['phone'] as String? : null;
                  }

                  final saleId = await db.insert('sales', {
                    'customer_id': customerId,
                    'total_amount': total,
                    'created_at': DateTime.now().toIso8601String(),
                  });

                  for (final line in _cart) {
                    await db.insert('sale_items', {
                      'sale_id': saleId,
                      'product_id': line.productId,
                      'qty': line.qty,
                      'unit_price': line.price,
                      'line_total': line.qty * line.price,
                    });
                    await db.rawUpdate(
                      'UPDATE products SET stock_qty = stock_qty - ? WHERE id = ?',
                      [line.qty, line.productId],
                    );
                  }

                  // Clear pending after adding to bill
                  if (_mode == CustomerMode.oldCustomer) {
                    await db.update('customers', {'pending_balance': 0}, where: 'id = ?', whereArgs: [customerId]);
                  }

                  final path = await PdfService.generateReceipt(
                    saleId: saleId,
                    customerPhone: phoneForSms,
                    lines: _cart.map((e) => PdfLine(name: e.name, qty: e.qty, price: e.price)).toList(),
                    total: total,
                    previousDue: _mode == CustomerMode.oldCustomer ? _oldCustomerPending : 0,
                  );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receipt saved: $path')));

                  if (phoneForSms != null && phoneForSms!.isNotEmpty) {
                    final msg = Uri.encodeComponent('Thank you! Your total is Rs. ${total.toStringAsFixed(0)}.');
                    final smsUri = Uri.parse('sms:$phoneForSms?body=$msg');
                    if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
                  }

                  setState(() {
                    _cart.clear();
                    _oldCustomerPending = 0;
                  });
                },
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class _CartLine {
  final int productId;
  final String name;
  final double price;
  int qty;
  _CartLine({required this.productId, required this.name, required this.price, this.qty = 1});
}
