import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../state/reports/report_provider.dart';

class ItemSalesReportScreen extends StatefulWidget {
  final VoidCallback? onMenuTap; // ✅ optional
  final void Function(String route)? onNavigate; // ✅ optional

  const ItemSalesReportScreen({
    super.key,
    this.onMenuTap,
    this.onNavigate,
  });

  @override
  State<ItemSalesReportScreen> createState() => _ItemSalesReportScreenState();
}

class _ItemSalesReportScreenState extends State<ItemSalesReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReportProvider>().load());
  }

  void _goBack() {
    // ✅ if inside HomeShell, switch back to Sales Report or Dashboard
    if (widget.onNavigate != null) {
      widget.onNavigate!.call(AppRoutes.salesReport);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final rep = context.watch<ReportProvider>();
    final items = rep.topItems(limit: 50);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Item Sales Report'),
        leading: IconButton(
          icon: Icon(widget.onMenuTap != null ? Icons.menu : Icons.arrow_back),
          onPressed: () {
            if (widget.onMenuTap != null) {
              widget.onMenuTap!.call();
            } else {
              _goBack();
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<ReportProvider>().load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ReportProvider>().load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: Color(0xFF3CC5FF)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Top selling items by revenue',
                      style: TextStyle(color: text, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text('${items.length}', style: TextStyle(color: sub, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (rep.loading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    'No sales found.\nDo checkout to generate sales.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: sub, fontWeight: FontWeight.w800),
                  ),
                ),
              )
            else
              ...items.map((it) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.name, style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('Qty sold: ${it.qty}', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Text(
                        'PKR ${it.revenue.toStringAsFixed(2)}',
                        style: TextStyle(color: text, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
