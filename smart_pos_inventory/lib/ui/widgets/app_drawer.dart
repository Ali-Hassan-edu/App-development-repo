import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../state/auth/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final String activeRoute;
  const AppDrawer({super.key, required this.activeRoute});

  void _go(BuildContext context, String route) {
    Navigator.pop(context); // close drawer
    if (activeRoute == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final shopName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!.trim()
        : 'Admin';

    final email = auth.user?.email ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.20),
                    child: Text(
                      shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Dashboard',
                      selected: activeRoute == AppRoutes.dashboard,
                      onTap: () => _go(context, AppRoutes.dashboard),
                    ),

                    const Divider(height: 18),

                    _expandGroup(
                      context,
                      icon: Icons.list_alt,
                      title: 'Items',
                      children: [
                        _subItem(
                          context,
                          'Products',
                          selected: activeRoute == AppRoutes.products,
                          onTap: () => _go(context, AppRoutes.products),
                        ),
                        _subItem(
                          context,
                          'Categories',
                          selected: activeRoute == AppRoutes.categories,
                          onTap: () => _go(context, AppRoutes.categories),
                        ),
                      ],
                    ),

                    _drawerItem(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Bill',
                      selected: activeRoute == AppRoutes.bill,
                      onTap: () => _go(context, AppRoutes.bill),
                    ),

                    _drawerItem(
                      context,
                      icon: Icons.people_alt_outlined,
                      title: 'Customers',
                      selected: activeRoute == AppRoutes.customers,
                      onTap: () => _go(context, AppRoutes.customers),
                    ),

                    _drawerItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      selected: activeRoute == AppRoutes.settings,
                      onTap: () => _go(context, AppRoutes.settings),
                    ),

                    const Divider(height: 18),

                    _expandGroup(
                      context,
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventory',
                      children: [
                        _subItem(
                          context,
                          'Inventory List',
                          selected: activeRoute == AppRoutes.inventoryList,
                          onTap: () => _go(context, AppRoutes.inventoryList),
                        ),
                        _subItem(
                          context,
                          'Inventory Logs',
                          selected: activeRoute == AppRoutes.inventoryLogs,
                          onTap: () => _go(context, AppRoutes.inventoryLogs),
                        ),
                      ],
                    ),

                    _expandGroup(
                      context,
                      icon: Icons.bar_chart_outlined,
                      title: 'Reports',
                      children: [
                        _subItem(
                          context,
                          'Sales Report',
                          selected: activeRoute == AppRoutes.salesReport,
                          onTap: () => _go(context, AppRoutes.salesReport),
                        ),

                        // If these screens are not built yet, keep them disabled:
                        _subItem(
                          context,
                          'Purchase Report (Coming Soon)',
                          enabled: false,
                          onTap: () {},
                        ),
                        _subItem(
                          context,
                          'Item Sales (Coming Soon)',
                          enabled: false,
                          onTap: () {},
                        ),
                      ],
                    ),

                    _expandGroup(
                      context,
                      icon: Icons.discount_outlined,
                      title: 'Tax & Discount',
                      children: [
                        _subItem(
                          context,
                          'Tax (Coming Soon)',
                          enabled: false,
                          onTap: () {},
                        ),
                        _subItem(
                          context,
                          'Discount (Coming Soon)',
                          enabled: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                          (_) => false,
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool selected = false,
      }) {
    final bg = selected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
        : Colors.transparent;

    final fg = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: fg),
        title: Text(
          title,
          style: TextStyle(color: fg, fontWeight: FontWeight.w800),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _expandGroup(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<Widget> children,
      }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      children: children,
    );
  }

  Widget _subItem(
      BuildContext context,
      String title, {
        required VoidCallback onTap,
        bool selected = false,
        bool enabled = true,
      }) {
    final fg = enabled
        ? (selected ? Theme.of(context).colorScheme.primary : Colors.black87)
        : Colors.black38;

    return ListTile(
      enabled: enabled,
      contentPadding: const EdgeInsets.only(left: 68, right: 16),
      title: Text(
        title,
        style: TextStyle(
          color: fg,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
