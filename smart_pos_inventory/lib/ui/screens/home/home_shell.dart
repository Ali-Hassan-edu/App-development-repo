import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../widgets/app_drawer.dart';

import '../dashboard/dashboard_screen.dart';
import '../items/products_screen.dart';
import '../items/categories_screen.dart';
import '../customers/customers_screen.dart';
import '../pos/bill_screen.dart';
import '../settings/settings_screen.dart';
import '../tax_discount/tax_screen.dart';
import '../tax_discount/discount_screen.dart';
import '../reports/sales_report_screen.dart';

class HomeShell extends StatefulWidget {
  final String startRoute;
  const HomeShell({super.key, this.startRoute = AppRoutes.dashboard});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late String _active;

  @override
  void initState() {
    super.initState();
    _active = widget.startRoute;
  }

  void _go(String route) {
    Navigator.pop(context); // close drawer
    if (_active == route) return;
    setState(() => _active = route);
  }

  void _openDrawer() {
    // ✅ remember: Scaffold.of(context) can fail if context is not under Scaffold
    // So we call ScaffoldMessenger context via Builder in each screen is not needed.
    // Here we just open using ScaffoldState key? We can do simplest:
    Scaffold.of(context).openDrawer();
  }

  Widget _body() {
    // ✅ Important: Using Builder so "Scaffold.of(context)" works inside each screen
    return Builder(
      builder: (ctx) {
        VoidCallback onMenuTap = () => Scaffold.of(ctx).openDrawer();

        switch (_active) {
          case AppRoutes.products:
            return ProductsScreen(onMenuTap: onMenuTap);

          case AppRoutes.categories:
            return CategoriesScreen(onMenuTap: onMenuTap);

          case AppRoutes.customers:
            return CustomersScreen(onMenuTap: onMenuTap);

          case AppRoutes.bill:
            return BillScreen(onMenuTap: onMenuTap);

          case AppRoutes.settings:
            return SettingsScreen(onMenuTap: onMenuTap);

          case AppRoutes.tax:
            return TaxScreen(onMenuTap: onMenuTap);

          case AppRoutes.discount:
            return DiscountScreen(onMenuTap: onMenuTap);

          case AppRoutes.salesReport:
            return SalesReportScreen(onMenuTap: onMenuTap);

          case AppRoutes.dashboard:
          default:
            return DashboardScreen(onMenuTap: onMenuTap);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        activeRoute: _active,
        onNavigate: _go,
      ),
      body: SafeArea(child: _body()),
    );
  }
}
