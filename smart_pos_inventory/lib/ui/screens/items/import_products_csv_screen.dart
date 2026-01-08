import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../state/products/product_provider.dart';

class ImportProductsCsvScreen extends StatefulWidget {
  const ImportProductsCsvScreen({super.key});

  @override
  State<ImportProductsCsvScreen> createState() => _ImportProductsCsvScreenState();
}

class _ImportProductsCsvScreenState extends State<ImportProductsCsvScreen> {
  bool _loading = false;
  bool _saving = false;
  bool _makingTemplate = false;

  String? _error;
  List<Map<String, dynamic>> _rows = [];

  /// ✅ Create & share a CSV template file
  Future<void> _downloadTemplate() async {
    setState(() {
      _makingTemplate = true;
      _error = null;
    });

    try {
      // Template data
      final template = [
        ['name', 'sku', 'category', 'price', 'cost', 'stock'],
        ['Tea', 'TEA-001', 'Beverage', '120', '80', '10'],
        ['Coffee', 'COF-001', 'Beverage', '200', '130', '15'],
        ['Sugar', 'SUG-001', 'Grocery', '90', '60', '20'],
      ];

      final csvText = const ListToCsvConverter().convert(template);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/products_template.csv');

      await file.writeAsString(csvText);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Products CSV Template',
        subject: 'products_template.csv',
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _makingTemplate = false);
  }

  // Expected columns (case-insensitive):
  // name, sku, category, price, cost, stock
  Future<void> _pickAndParseCsv() async {
    setState(() {
      _loading = true;
      _error = null;
      _rows = [];
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: false,
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _loading = false);
        return;
      }

      final path = result.files.single.path!;
      final content = await File(path).readAsString();

      final table = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(content);

      if (table.isEmpty) throw 'CSV is empty';

      // Header row
      final header = table.first.map((e) => e.toString().trim().toLowerCase()).toList();

      int idxOf(String col) => header.indexOf(col);

      final iName = idxOf('name');
      final iSku = idxOf('sku');
      final iCat = idxOf('category');
      final iPrice = idxOf('price');
      final iCost = idxOf('cost');
      final iStock = idxOf('stock');

      if (iName == -1 || iPrice == -1) {
        throw 'CSV must contain at least columns: name, price\nOptional: sku, category, cost, stock';
      }

      final parsed = <Map<String, dynamic>>[];

      for (int r = 1; r < table.length; r++) {
        final row = table[r];

        String cell(int i) => (i >= 0 && i < row.length) ? row[i].toString().trim() : '';

        final name = cell(iName);
        final sku = iSku == -1 ? '' : cell(iSku);
        final category = iCat == -1 ? '' : cell(iCat);

        final priceStr = cell(iPrice);
        final costStr = iCost == -1 ? '' : cell(iCost);
        final stockStr = iStock == -1 ? '' : cell(iStock);

        // Skip fully empty line
        if (name.isEmpty &&
            priceStr.isEmpty &&
            sku.isEmpty &&
            category.isEmpty &&
            costStr.isEmpty &&
            stockStr.isEmpty) {
          continue;
        }

        final price = double.tryParse(priceStr) ?? -1;
        final cost = costStr.isEmpty ? null : double.tryParse(costStr);
        final stock = stockStr.isEmpty ? 0 : (int.tryParse(stockStr) ?? 0);

        parsed.add({
          'name': name,
          'sku': sku.isEmpty ? null : sku,
          'category': category.isEmpty ? null : category,
          'price': price,
          'cost': cost,
          'stock': stock,
        });
      }

      if (parsed.isEmpty) throw 'No usable rows found in CSV';

      // Validate quickly
      for (int i = 0; i < parsed.length; i++) {
        final row = parsed[i];
        final name = (row['name'] ?? '').toString().trim();
        final price = row['price'];

        if (name.isEmpty) throw 'Row ${i + 1}: name is required';
        if (price is! double || price <= 0) throw 'Row ${i + 1}: price must be > 0';
        final stock = row['stock'];
        if (stock is! int || stock < 0) throw 'Row ${i + 1}: stock must be >= 0';
      }

      setState(() {
        _rows = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_rows.isEmpty) return;

    setState(() => _saving = true);
    final err = await context.read<ProductProvider>().addProductsBulk(_rows);
    setState(() => _saving = false);

    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported ${_rows.length} products')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Products (CSV)', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(
            onPressed: (_saving || _rows.isEmpty) ? null : _save,
            child: Text(
              _saving ? 'Saving...' : 'Save',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: const Text(
              'CSV columns (header):\nname, price (required)\nsku, category, cost, stock (optional)\n\nExample:\nname,sku,category,price,cost,stock',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ Download template button
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: (_makingTemplate || _loading || _saving) ? null : _downloadTemplate,
              icon: _makingTemplate
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
                  : const Icon(Icons.download),
              label: Text(
                _makingTemplate ? 'Preparing...' : 'Download Template CSV',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading || _saving ? null : _pickAndParseCsv,
              icon: _loading
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
                  : const Icon(Icons.upload_file),
              label: Text(
                _loading ? 'Loading...' : 'Choose CSV File',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CC5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (_error != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
              ),
              child: Text(_error!, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),

          if (_rows.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Preview (${_rows.length} rows)', style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),

            ..._rows.take(10).map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((r['name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      'Price: ${r['price']} • Stock: ${r['stock']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    if ((r['sku'] ?? '').toString().trim().isNotEmpty)
                      Text('SKU: ${r['sku']}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                    if ((r['category'] ?? '').toString().trim().isNotEmpty)
                      Text('Category: ${r['category']}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  ],
                ),
              );
            }).toList(),

            if (_rows.length > 10)
              Text('Showing first 10 rows only...', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
          ],
        ],
      ),
    );
  }
}
