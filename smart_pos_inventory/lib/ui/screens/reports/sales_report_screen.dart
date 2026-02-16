import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../state/reports/report_provider.dart';
import '../../../state/reports/report_models.dart';

class SalesReportScreen extends StatefulWidget {
  final VoidCallback? onMenuTap; // ✅ optional
  final void Function(String route)? onNavigate; // ✅ optional

  const SalesReportScreen({
    super.key,
    this.onMenuTap,
    this.onNavigate,
  });

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReportProvider>().load());
  }

  void _go(String route) {
    // ✅ if inside HomeShell, switch tab
    if (widget.onNavigate != null) {
      widget.onNavigate!.call(route);
      return;
    }
    // ✅ otherwise normal navigation (if you ever push this screen directly)
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final rep = context.watch<ReportProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;

    final bgGradient = isDark
        ? const LinearGradient(
      colors: [Color(0xFF0F1320), Color(0xFF121A31), Color(0xFF0F1320)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFF4F7FF), Color(0xFFFFF6F9), Color(0xFFF6FFFB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(gradient: bgGradient),
      child: Column(
        children: [
          _topBar(titleColor, context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<ReportProvider>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (rep.error != null)
                    _errorBox(rep.error!)
                  else if (rep.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                      _kpiGrid(rep),
                      const SizedBox(height: 14),
                      _chartCard(
                        context,
                        isDark: isDark,
                        title: 'Last 7 Days Sales',
                        points: rep.lastDays(7),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              isDark: isDark,
                              title: 'Item Sales',
                              subtitle: 'Top selling items',
                              icon: Icons.inventory_2_outlined,
                              colors: const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                              onTap: () => _go(AppRoutes.itemSalesReport),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionCard(
                              isDark: isDark,
                              title: 'Purchase',
                              subtitle: 'Stock purchases',
                              icon: Icons.shopping_cart_outlined,
                              colors: const [Color(0xFFFF5E7E), Color(0xFFFFC371)],
                              onTap: () => _go(AppRoutes.purchaseReport),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _historyCard(rep, isDark),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(Color titleColor, BuildContext context) {
    final canOpenDrawer = widget.onMenuTap != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          IconButton(
            icon: Icon(canOpenDrawer ? Icons.menu : Icons.arrow_back, color: titleColor),
            onPressed: () {
              if (canOpenDrawer) {
                widget.onMenuTap!.call();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 8),
          Icon(Icons.bar_chart_outlined, color: titleColor),
          const SizedBox(width: 8),
          Text(
            'Reports',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<ReportProvider>().load(),
            icon: Icon(Icons.refresh, color: titleColor),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: titleColor),
            onSelected: (v) async {
              final rep = context.read<ReportProvider>();
              if (v == 'demo') await rep.generateDemo(days: 14);
              if (v == 'clear') await rep.clearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'demo', child: Text('Generate demo sales')),
              PopupMenuItem(value: 'clear', child: Text('Clear all')),
            ],
          )
        ],
      ),
    );
  }

  Widget _kpiGrid(ReportProvider rep) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.60,
      children: [
        _kpiCard(
          title: 'Sales Today',
          value: 'PKR ${rep.todayTotal.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          colors: const [Color(0xFFFF5E7E), Color(0xFFFFC371)],
        ),
        _kpiCard(
          title: 'This Month',
          value: 'PKR ${rep.monthTotal.toStringAsFixed(2)}',
          icon: Icons.calendar_month,
          colors: const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
        ),
        _kpiCard(
          title: 'Transactions',
          value: '${rep.monthTransactions}',
          icon: Icons.receipt_long,
          colors: const [Color(0xFF00C9A7), Color(0xFF92FE9D)],
        ),
        _kpiCard(
          title: 'Avg Ticket',
          value: 'PKR ${rep.monthAvgTicket.toStringAsFixed(2)}',
          icon: Icons.payments_outlined,
          colors: const [Color(0xFFFF4D6D), Color(0xFF6D5DF6)],
        ),
      ],
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

  Widget _chartCard(
      BuildContext context, {
        required bool isDark,
        required String title,
        required List<DayPoint> points,
      }) {
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    final double maxV = points.isEmpty ? 0.0 : points.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final double safeMax = maxV < 1.0 ? 1.0 : maxV;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: text)),
          const SizedBox(height: 4),
          Text('Simple line chart (no extra packages)', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: points.isEmpty
                ? Center(child: Text('No sales yet', style: TextStyle(color: sub, fontWeight: FontWeight.w800)))
                : CustomPaint(
              painter: _LineChartPainter(points: points, maxV: safeMax, isDark: isDark),
              child: Container(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points
                .map((p) => Text(p.label, style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w700)))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _actionCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(colors: colors),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: sub),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(ReportProvider rep, bool isDark) {
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Container(
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
              Expanded(child: Text('Recent Sales', style: TextStyle(color: text, fontWeight: FontWeight.w900))),
              Text('${rep.sales.length} records', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          if (rep.sales.isEmpty)
            Text('No sales found. Do checkout to generate sales.', style: TextStyle(color: sub, fontWeight: FontWeight.w700))
          else
            ...rep.sales.take(6).map((s) {
              final dt = DateTime.fromMillisecondsSinceEpoch(s.createdAt);
              final date =
                  '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invoice #${s.id}', style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text('$date • ${s.paymentMethod}', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Text('PKR ${s.grandTotal.toStringAsFixed(2)}', style: TextStyle(color: text, fontWeight: FontWeight.w900)),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
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

class _LineChartPainter extends CustomPainter {
  final List<DayPoint> points;
  final double maxV;
  final bool isDark;

  _LineChartPainter({required this.points, required this.maxV, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white12 : Colors.black12)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF3CC5FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = const Color(0xFF6D5DF6);

    final path = Path();
    final n = points.length;

    for (int i = 0; i < n; i++) {
      final x = (n == 1) ? 0.0 : (size.width * (i / (n - 1)));
      final v = points[i].total;
      final y = size.height - (v / maxV) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.maxV != maxV || oldDelegate.isDark != isDark;
  }
}
