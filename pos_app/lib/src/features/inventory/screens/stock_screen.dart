import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_db.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Map<String, Object?>> _rows = [];
  String _query = '';

  Future<void> _load() async {
    final db = await AppDB().database;
    final rows = await db.query(
      'products',
      where: _query.isEmpty ? null : 'name LIKE ?',
      whereArgs: _query.isEmpty ? null : ['%$_query%'],
      orderBy: 'name',
    );
    setState(() => _rows = rows);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Current Stock')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search product',
            ),
            onChanged: (v) {
              _query = v.trim();
              _load();
            },
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = _rows[i];
              final name = r['name'] as String? ?? '';
              final qty = r['stock_qty'] as int? ?? 0;
              final price = r['price'] as num? ?? 0;
              final reorder = (r['reorder_level'] as int? ?? 0);
              Color badge = qty == 0
                  ? Colors.red
                  : (qty <= reorder ? Colors.orange : Colors.green);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: badge, radius: 10),
                  title: Text(name),
                  subtitle: Text('Qty: $qty  •  Price: $price'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // optional: open product edit (not implemented)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit coming soon')),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}
