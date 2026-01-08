import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../state/auth/auth_provider.dart';
import '../../state/theme/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  final String activeRoute;
  final void Function(String route) onNavigate;

  const AppDrawer({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  void _go(BuildContext context, String route) {
    Navigator.pop(context); // close drawer
    onNavigate(route); // ✅ update HomeShell active screen
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;

    final shopName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!.trim()
        : 'Admin';
    final email = auth.user?.email ?? '';

    final bg = isDark ? const Color(0xFF0F1320) : Colors.white;
    final card = isDark ? const Color(0xFF161E35) : const Color(0xFFF6F7FB);
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // HEADER
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark ? Colors.white12 : Colors.green.withOpacity(0.15),
                    child: Icon(
                      Icons.person,
                      color: isDark ? Colors.white : Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shopName, style: TextStyle(fontWeight: FontWeight.w900, color: text)),
                        const SizedBox(height: 2),
                        Text(email, style: TextStyle(color: sub)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Dark Mode",
                    onPressed: () => context.read<ThemeProvider>().toggle(),
                    icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: text),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    _item(
                      icon: Icons.home,
                      title: 'Dashboard',
                      selected: activeRoute == AppRoutes.dashboard,
                      text: text,
                      isDark: isDark,
                      onTap: () => _go(context, AppRoutes.dashboard),
                    ),

                    const SizedBox(height: 6),
                    _sectionDivider(isDark),

                    _expandGroup(
                      context,
                      icon: Icons.list_alt,
                      title: 'Items',
                      isDark: isDark,
                      text: text,
                      children: [
                        _subItem(context, 'Products', () => _go(context, AppRoutes.products), text, sub),
                        _subItem(context, 'Categories', () => _go(context, AppRoutes.categories), text, sub),
                      ],
                    ),

                    _item(
                      icon: Icons.receipt_long,
                      title: 'Bill',
                      selected: activeRoute == AppRoutes.bill,
                      text: text,
                      isDark: isDark,
                      onTap: () => _go(context, AppRoutes.bill),
                    ),

                    _item(
                      icon: Icons.people,
                      title: 'Customers',
                      selected: activeRoute == AppRoutes.customers,
                      text: text,
                      isDark: isDark,
                      onTap: () => _go(context, AppRoutes.customers),
                    ),

                    _item(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Ledger',
                      selected: activeRoute == AppRoutes.ledger,
                      text: text,
                      isDark: isDark,
                      onTap: () => _go(context, AppRoutes.ledger),
                    ),

                    _item(
                      icon: Icons.settings,
                      title: 'Settings',
                      selected: activeRoute == AppRoutes.settings,
                      text: text,
                      isDark: isDark,
                      onTap: () => _go(context, AppRoutes.settings),
                    ),

                    const SizedBox(height: 6),
                    _sectionDivider(isDark),

                    _expandGroup(
                      context,
                      icon: Icons.discount,
                      title: 'Tax & Discount',
                      isDark: isDark,
                      text: text,
                      children: [
                        _subItem(context, 'Tax', () => _go(context, AppRoutes.tax), text, sub),
                        _subItem(context, 'Discount', () => _go(context, AppRoutes.discount), text, sub),
                      ],
                    ),

                    _expandGroup(
                      context,
                      icon: Icons.bar_chart,
                      title: 'Reports',
                      isDark: isDark,
                      text: text,
                      children: [
                        _subItem(context, 'Sales Report', () => _go(context, AppRoutes.salesReport), text, sub),
                        _subItem(context, 'Item Sales Report', () => _go(context, AppRoutes.itemSalesReport), text, sub),
                        _subItem(context, 'Purchase Report', () => _go(context, AppRoutes.purchaseReport), text, sub),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // LOGOUT
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                  },
                  child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionDivider(bool isDark) =>
      Divider(height: 18, color: isDark ? Colors.white12 : Colors.black12);

  Widget _item({
    required IconData icon,
    required String title,
    required bool selected,
    required Color text,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bg = selected ? (isDark ? Colors.white12 : Colors.green.withOpacity(0.18)) : Colors.transparent;
    final fg = selected ? (isDark ? Colors.white : Colors.green) : text;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: fg),
        title: Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w800)),
        onTap: onTap,
      ),
    );
  }

  Widget _expandGroup(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<Widget> children,
        required bool isDark,
        required Color text,
      }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: text),
        iconColor: text,
        collapsedIconColor: text,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: text)),
        children: children,
      ),
    );
  }

  Widget _subItem(
      BuildContext context,
      String title,
      VoidCallback onTap,
      Color text,
      Color sub,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 68, right: 16),
      title: Text(title, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
      onTap: onTap,
    );
  }
}
