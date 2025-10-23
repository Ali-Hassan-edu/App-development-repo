import 'package:flutter/material.dart';
import '../../auth/repo/user_repo.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '0');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 10),
                TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
                const SizedBox(height: 10),
                TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Opening Stock')),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading
                      ? null
                      : () async {
                    if (_name.text.trim().isEmpty || double.tryParse(_price.text) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid name and price')));
                      return;
                    }
                    setState(() => _loading = true);
                    await UserRepo.addProduct(
                      name: _name.text.trim(),
                      price: double.parse(_price.text),
                      stock: int.tryParse(_stock.text) ?? 0,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added')));
                    setState(() => _loading = false);
                  },
                  icon: const Icon(Icons.save),
                  label: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
