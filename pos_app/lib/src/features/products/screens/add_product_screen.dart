import 'package:flutter/material.dart';
import '../../../core/db/app_db.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController(text: '0');
  final _reorder = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
              validator: (v) =>
              (v == null || double.tryParse(v) == null) ? 'Enter number' : null,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _qty,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _reorder,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reorder Level'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final db = await AppDB().database;
                await db.insert('products', {
                  'name': _name.text.trim(),
                  'price': double.parse(_price.text),
                  'stock_qty': int.tryParse(_qty.text) ?? 0,
                  'reorder_level': int.tryParse(_reorder.text) ?? 0,
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added')),
                );
                Navigator.pop(context);
              },
              label: const Text('Save'),
            )
          ]),
        ),
      ),
    );
  }
}
