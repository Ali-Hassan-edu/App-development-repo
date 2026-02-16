import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../state/auth/auth_provider.dart';
import '../../../state/products/product_provider.dart';
import '../../../state/theme/theme_provider.dart';
import '../../../state/customers/customer_provider.dart';
import '../../../state/reports/report_provider.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onMenuTap;

  // ✅ NEW: for HomeShell tab switching (no Navigator.pushNamed)
  final void Function(String route) onNavigate;

  const DashboardScreen({
    super.key,
    required this.onMenuTap,
    required this.onNavigate,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Future.wait([
        context.read<ProductProvider>().load(),
        context.read<CustomerProvider>().load(),
        context.read<ReportProvider>().load(),
      ]);
    });
  }

  void _onNavTap(int i) {
    setState(() => _index = i);

    switch (i) {
      case 0:
      // stay on dashboard
        widget.onNavigate(AppRoutes.dashboard);
        break;
      case 1:
        widget.onNavigate(AppRoutes.customers);
        break;
      case 2:
        widget.onNavigate(AppRoutes.bill);
        break;
      case 3:
        widget.onNavigate(AppRoutes.bill);
        break;
      case 4:
        widget.onNavigate(AppRoutes.salesReport);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final customers = context.watch<CustomerProvider>();
    final reports = context.watch<ReportProvider>();
    final theme = context.watch<ThemeProvider>();

    final shopName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!.trim()
        : 'Your Shop';

    final isDark = theme.isDark;

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

    final titleColor = isDark ? Colors.white : Colors.black87;

    final salesTodayText = 'PKR ${reports.todayTotal.toStringAsFixed(0)}';

    final customersText = '${customers.customers.length}';

    return Scaffold(
      bottomNavigationBar: _bottomNav(isDark),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [
            _topBar(context, shopName, titleColor)
                .animate()
                .fadeIn(duration: 260.ms)
                .slideY(begin: .12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<ProductProvider>().load(),
                    context.read<CustomerProvider>().load(),
                    context.read<ReportProvider>().load(),
                  ]);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _welcomeCard(shopName)
                        .animate()
                        .fadeIn(duration: 280.ms)
                        .slideY(begin: .12),
                    const SizedBox(height: 14),

                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.55,
                      children: [
                        _statMini(
                          'Sales Today',
                          salesTodayText,
                          Icons.trending_up,
                          const [Color(0xFFFF5E7E), Color(0xFFFFC371)],
                        ),
                        _statMini(
                          'Items',
                          '${products.totalItems}',
                          Icons.inventory_2_outlined,
                          const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                        ),
                        _statMini(
                          'Customers',
                          customersText,
                          Icons.people_alt_outlined,
                          const [Color(0xFF00C9A7), Color(0xFF92FE9D)],
                        ),
                        _statMini(
                          'Low Stock',
                          '${products.lowStockCount}',
                          Icons.warning_amber_rounded,
                          const [Color(0xFFFF4D6D), Color(0xFF6D5DF6)],
                        ),
                      ],
                    ).animate().fadeIn(duration: 420.ms).slideY(begin: .10),

                    const SizedBox(height: 18),

                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ).animate().fadeIn(duration: 520.ms),

                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.10,
                      children: [
                        _quickActionPlus(
                          context,
                          isDark: isDark,
                          title: 'POS',
                          subtitle: 'Start billing',
                          icon: Icons.point_of_sale,
                          colors: const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                          onTap: () => widget.onNavigate(AppRoutes.bill),
                        ),
                        _quickActionPlus(
                          context,
                          isDark: isDark,
                          title: 'Add Product',
                          subtitle: 'Add new item',
                          icon: Icons.add_box_outlined,
                          colors: const [Color(0xFFFF5E7E), Color(0xFFFFC371)],
                          onTap: () => widget.onNavigate(AppRoutes.products),
                        ),
                        _quickActionPlus(
                          context,
                          isDark: isDark,
                          title: 'Customers',
                          subtitle: 'Manage',
                          icon: Icons.people_alt_outlined,
                          colors: const [Color(0xFF00C9A7), Color(0xFF92FE9D)],
                          onTap: () => widget.onNavigate(AppRoutes.customers),
                        ),
                        _quickActionPlus(
                          context,
                          isDark: isDark,
                          title: 'Reports',
                          subtitle: 'Sales insights',
                          icon: Icons.bar_chart,
                          colors: const [Color(0xFFFF4D6D), Color(0xFF6D5DF6)],
                          onTap: () => widget.onNavigate(AppRoutes.salesReport),
                        ),
                      ],
                    ).animate().fadeIn(duration: 620.ms).slideY(begin: .08),

                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav(bool isDark) {
    final bg = isDark ? const Color(0xFF0F1320) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bg,
          selectedItemColor: const Color(0xFF3CC5FF),
          unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Customers'),
            BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'POS'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add Bill'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, String shopName, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: titleColor),
            onPressed: widget.onMenuTap,
          ),
          const SizedBox(width: 4),
          Icon(Icons.point_of_sale, color: titleColor),
          const SizedBox(width: 8),
          Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor),
          ),
          const Spacer(),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _welcomeCard(String shopName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3CC5FF).withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.22),
            ),
            child: const Icon(Icons.storefront, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome 👋', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  shopName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.22),
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _statMini(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.22),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionPlus(
      BuildContext context, {
        required bool isDark,
        required String title,
        required String subtitle,
        required IconData icon,
        required List<Color> colors,
        required VoidCallback onTap,
      }) {
    final cardColor = isDark ? const Color(0xFF161E35) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: colors),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const Spacer(),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: colors.last.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.last.withOpacity(0.28)),
                  ),
                  child: Icon(Icons.add, size: 30, color: colors.last),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  duration: 900.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
