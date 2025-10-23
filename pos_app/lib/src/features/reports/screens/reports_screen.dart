import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../auth/repo/user_repo.dart';
import '../../../utils/pdf_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _range = 'Today'; // Today, Yesterday, Weekly, Monthly
  List<Map<String, dynamic>> _rows = [];
  bool _loading = false;

  (DateTime, DateTime) _getRange() {
    final now = DateTime.now();
    switch (_range) {
      case 'Yesterday':
        final y = DateTime(now.year, now.month, now.day - 1);
        return (DateTime(y.year, y.month, y.day), DateTime(y.year, y.month, y.day, 23, 59, 59));
      case 'Weekly':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return (DateTime(start.year, start.month, start.day), end);
      case 'Monthly':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (start, end);
      case 'Today':
      default:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return (start, end);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (s, e) = _getRange();
    final rows = await UserRepo.salesBetween(s, e);
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  double get _total => _rows.fold(0.0, (p, e) => p + (e['total'] as num).toDouble());

  Future<void> _export() async {
    final salesRows = _rows
        .map((r) => SalesRow(
      id: r['id'] as int,
      createdAt: DateTime.parse(r['created_at'] as String),
      total: (r['total'] as num).toDouble(),
    ))
        .toList();
    final title = '$_range Sales Report';
    final path = await PdfService.generateSalesReport(title: title, rows: salesRows);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported: $path')));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: 'Rs. ');
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _range,
                  items: const ['Today', 'Yesterday', 'Weekly', 'Monthly']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) { if (v != null) { setState(() => _range = v); _load(); } },
                ),
                const Spacer(),
                FilledButton.icon(onPressed: _export, icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF')),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              itemBuilder: (_, i) {
                final r = _rows[i];
                final dt = DateTime.parse(r['created_at'] as String);
                return ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('Sale #${r['id']} - ${fmt.format((r['total'] as num).toDouble())}'),
                  subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(dt)),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemCount: _rows.length,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text('Total: ${fmt.format(_total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
