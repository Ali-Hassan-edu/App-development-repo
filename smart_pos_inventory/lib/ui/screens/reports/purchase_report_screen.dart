import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../../core/route_observer.dart';
import '../../../state/reports/report_models.dart';
import '../../../state/reports/report_store.dart';

class PurchaseReportScreen extends StatefulWidget {
  final VoidCallback? onMenuTap; // ✅ optional now
  const PurchaseReportScreen({super.key, this.onMenuTap});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> with RouteAware {
  bool _loading = true;
  String? _error;
  List<PurchaseRecord> _purchases = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ✅ auto refresh when returning back
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await ReportStore.getPurchases();
      if (!mounted) return;
      setState(() => _purchases = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  double get _todayTotal {
    final now = DateTime.now();
    return _purchases.where((p) {
      final d = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (a, b) => a + b.grandTotal);
  }

  double get _monthTotal {
    final now = DateTime.now();
    return _purchases.where((p) {
      final d = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
      return d.year == now.year && d.month == now.month;
    }).fold(0.0, (a, b) => a + b.grandTotal);
  }

  int get _monthTx {
    final now = DateTime.now();
    return _purchases.where((p) {
      final d = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
      return d.year == now.year && d.month == now.month;
    }).length;
  }

  double get _monthAvg => _monthTx == 0 ? 0.0 : _monthTotal / _monthTx;

  Future<void> _clearAll() async {
    await ReportStore.clearPurchases();
    await _load();
  }

  Future<void> _generateDemo({int days = 14}) async {
    final rnd = Random();
    final now = DateTime.now();
    final uuid = const Uuid();

    for (int i = 0; i < days; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final txCount = 1 + rnd.nextInt(3);

      for (int t = 0; t < txCount; t++) {
        final createdAt = day.add(Duration(hours: 9 + rnd.nextInt(8), minutes: rnd.nextInt(60)));
        final itemCount = 1 + rnd.nextInt(4);

        final items = <PurchaseLineItem>[];
        for (int k = 0; k < itemCount; k++) {
          final qty = 5 + rnd.nextInt(20);
          final cost = 10 + rnd.nextInt(150);
          items.add(PurchaseLineItem(
            productId: 'p${1 + rnd.nextInt(6)}',
            name: ['Tea', 'Coffee', 'Biscuit', 'Chips', 'Milk', 'Bread'][rnd.nextInt(6)],
            qty: qty,
            unitCost: cost.toDouble(),
          ));
        }

        final sub = items.fold(0.0, (a, b) => a + b.total);
        final tax = sub * 0.01;
        final grand = sub + tax;

        final rec = PurchaseRecord(
          id: uuid.v4().substring(0, 8).toUpperCase(),
          createdAt: createdAt.millisecondsSinceEpoch,
          supplierName: rnd.nextBool() ? 'Local Supplier' : 'Wholesale Mart',
          supplierPhone: '',
          subTotal: sub,
          tax: tax,
          grandTotal: grand,
          items: items,
        );

        await ReportStore.addPurchase(rec);
      }
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Purchase Report', style: TextStyle(fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: Icon(widget.onMenuTap != null ? Icons.menu : Icons.arrow_back),
          onPressed: () {
            if (widget.onMenuTap != null) {
              widget.onMenuTap!.call();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'demo') await _generateDemo(days: 14);
              if (v == 'clear') await _clearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'demo', child: Text('Generate demo purchases')),
              PopupMenuItem(value: 'clear', child: Text('Clear purchases')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) _errorBox(_error!),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.60, // ✅ overflow fixed
            children: [
              _kpiCard(
                title: 'Purchases Today',
                value: 'PKR ${_todayTotal.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                colors: const [Color(0xFFFF5E7E), Color(0xFFFFC371)],
              ),
              _kpiCard(
                title: 'This Month',
                value: 'PKR ${_monthTotal.toStringAsFixed(2)}',
                icon: Icons.calendar_month,
                colors: const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
              ),
              _kpiCard(
                title: 'Transactions',
                value: '$_monthTx',
                icon: Icons.receipt_long,
                colors: const [Color(0xFF00C9A7), Color(0xFF92FE9D)],
              ),
              _kpiCard(
                title: 'Avg Ticket',
                value: 'PKR ${_monthAvg.toStringAsFixed(2)}',
                icon: Icons.payments_outlined,
                colors: const [Color(0xFFFF4D6D), Color(0xFF6D5DF6)],
              ),
            ],
          ).animate().fadeIn(duration: 260.ms).slideY(begin: .05),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Recent Purchases',
                          style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                    ),
                    Text('${_purchases.length} records',
                        style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                if (_purchases.isEmpty)
                  Text(
                    'No purchase records found.\nAdd a purchase or use menu → "Generate demo purchases".',
                    style: TextStyle(color: sub, fontWeight: FontWeight.w700),
                  )
                else
                  ..._purchases.take(10).toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;

                    final dt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
                    final date =
                        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
                        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: const Color(0xFF3CC5FF).withValues(alpha: 0.16),
                            ),
                            child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF3CC5FF)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PO #${p.id}',
                                  style: TextStyle(color: text, fontWeight: FontWeight.w900),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$date • ${p.supplierName.isEmpty ? 'Supplier' : p.supplierName}',
                                  style: TextStyle(color: sub, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text('${p.items.length} items',
                                    style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PKR ${p.grandTotal.toStringAsFixed(2)}',
                            style: TextStyle(color: text, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 220.ms, delay: (i * 60).ms).slideX(begin: .04);
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.22),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
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
