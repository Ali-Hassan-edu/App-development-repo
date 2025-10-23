import 'package:flutter/material.dart';
import '../../auth/repo/user_repo.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  Future<void> _load() async {
    final rows = await UserRepo.products();
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory / Stock')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) {
          final r = _rows[i];
          return ListTile(
            leading: const Icon(Icons.inventory_2),
            title: Text('${r['name']}'),
            subtitle: Text('Price: ${r['price']}'),
            trailing: Text('Stock: ${r['stock']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemCount: _rows.length,
      ),
    );
  }
}
