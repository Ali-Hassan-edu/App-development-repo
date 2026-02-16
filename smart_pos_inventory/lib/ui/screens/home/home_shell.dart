import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../widgets/app_drawer.dart';

// screens
import '../dashboard/dashboard_screen.dart';
import '../items/categories_screen.dart';
import '../items/products_screen.dart';
import '../customers/customers_screen.dart';
import '../settings/settings_screen.dart';
import '../pos/bill_screen.dart';

// reports
import '../reports/sales_report_screen.dart';
import '../reports/item_sales_report_screen.dart';
import '../reports/purchase_report_screen.dart';

// tax/discount
import '../tax_discount/tax_screen.dart';
import '../tax_discount/discount_screen.dart';

// ledger
import '../ledger/ledger_screen.dart';

class HomeShell extends StatefulWidget {
  final String startRoute;
  const HomeShell({super.key, this.startRoute = AppRoutes.dashboard});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late String _activeRoute;

  @override
  void initState() {
    super.initState();
    _activeRoute = widget.startRoute;
  }

  void _navigate(String route) {
    if (_activeRoute == route) return;
    setState(() => _activeRoute = route);
  }

  Widget _screenFor(String route, VoidCallback openDrawer) {
    switch (route) {
      case AppRoutes.dashboard:
        return DashboardScreen(onMenuTap: openDrawer, onNavigate: _navigate);

      case AppRoutes.products:
        return ProductsScreen(onMenuTap: openDrawer);

      case AppRoutes.categories:
        return CategoriesScreen(onMenuTap: openDrawer);

      case AppRoutes.bill:
        return BillScreen(onMenuTap: openDrawer, onNavigate: _navigate);

      case AppRoutes.customers:
        return CustomersScreen(onMenuTap: openDrawer);

      case AppRoutes.settings:
        return SettingsScreen(onMenuTap: openDrawer);

    // Tax & Discount
      case AppRoutes.tax:
        return TaxScreen(onMenuTap: openDrawer);

      case AppRoutes.discount:
        return DiscountScreen(onMenuTap: openDrawer);

    // Reports ✅ (PASS onNavigate so reports can switch tabs inside shell)
      case AppRoutes.salesReport:
        return SalesReportScreen(onMenuTap: openDrawer, onNavigate: _navigate);

      case AppRoutes.itemSalesReport:
        return ItemSalesReportScreen(onMenuTap: openDrawer, onNavigate: _navigate);

      case AppRoutes.purchaseReport:
        return PurchaseReportScreen(onMenuTap: openDrawer);

    // Ledger
      case AppRoutes.ledger:
        return LedgerScreen(onMenuTap: openDrawer);

      default:
        return DashboardScreen(onMenuTap: openDrawer, onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        activeRoute: _activeRoute,
        onNavigate: _navigate,
      ),
      body: Builder(
        builder: (ctx) {
          void openDrawer() => Scaffold.of(ctx).openDrawer();
          return _screenFor(_activeRoute, openDrawer);
        },
      ),
    );
  }
}
