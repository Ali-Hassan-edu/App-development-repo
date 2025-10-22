import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_db.dart';
import 'package:intl/intl.dart';
import '../../../utils/pdf_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double today = 0, yesterday = 0, week = 0, month = 0;

  Future<void> _load() async {
    final db = await AppDB().database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfDay.subtract(const Duration(days: 1));
    final startOfWeek = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    today = await _sumBetween(db, startOfDay, now);
    yesterday = await _sumBetween(db, startOfYesterday, startOfDay);
    week = await _sumBetween(db, startOfWeek, now);
    month = await _sumBetween(db, startOfMonth, now);
    setState(() {});
  }

  Future<double> _sumBetween(Database db, DateTime from, DateTime to) async {
    final rows = await db.rawQuery(
      'SELECT SUM(total_amount) as s FROM sales WHERE created_at >= ? AND created_at < ?',
      [from.toIso8601String(), to.toIso8601String()],
    );
    final v = rows.first['s'] as num?;
    return (v ?? 0).toDouble();
  }

  Future<void> _exportRange(String title, DateTime from, DateTime to) async {
    final db = await AppDB().database;
    final rows = await db.rawQuery(
      'SELECT id, total_amount, created_at FROM sales WHERE created_at >= ? AND created_at < ? ORDER BY created_at DESC',
      [from.toIso8601String(), to.toIso8601String()],
    );
    final items = rows.map((r) => SalesRow(
      id: r['id'] as int,
      total: (r['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(r['created_at'] as String),
    )).toList();

    final path = await PdfService.generateSalesReport(
      title: title,
      rows: items,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report PDF: $path')));
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: 'Rs. ');
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfDay.subtract(const Duration(days: 1));
    final startOfWeek = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _StatRow(
            title: 'Today',
            value: fmt.format(today),
            onExport: () => _exportRange('Today Sales', startOfDay, now),
          ),
          _StatRow(
            title: 'Yesterday',
            value: fmt.format(yesterday),
            onExport: () => _exportRange('Yesterday Sales', startOfYesterday, startOfDay),
          ),
          _StatRow(
            title: 'This Week',
            value: fmt.format(week),
            onExport: () => _exportRange('Weekly Sales', startOfWeek, now),
          ),
          _StatRow(
            title: 'This Month',
            value: fmt.format(month),
            onExport: () => _exportRange('Monthly Sales', startOfMonth, now),
          ),
        ]),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onExport;
  const _StatRow({required this.title, required this.value, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          FilledButton.icon(onPressed: onExport, icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF')),
        ]),
      ),
    );
  }
}
