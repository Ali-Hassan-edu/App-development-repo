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
import '../ledger/ledger_screen.dart';

class HomeShell extends StatefulWidget {
  final String startRoute;
  const HomeShell({super.key, this.startRoute = AppRoutes.dashboard});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _active;

  @override
  void initState() {
    super.initState();
    _active = widget.startRoute;
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _go(String route) {
    // close drawer (only if open)
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    if (_active == route) return;
    setState(() => _active = route);
  }

  @override
  Widget build(BuildContext context) {
    final onMenuTap = _openDrawer;

    Widget screen;
    switch (_active) {
      case AppRoutes.products:
        screen = ProductsScreen(onMenuTap: onMenuTap);
        break;
      case AppRoutes.categories:
        screen = CategoriesScreen(onMenuTap: onMenuTap);
        break;
      case AppRoutes.customers:
        screen = CustomersScreen(
          onMenuTap: onMenuTap,
          onNavigate: _go,
        );

        break;
      case AppRoutes.bill:
        screen = BillScreen(
          onMenuTap: onMenuTap,
          onNavigate: _go,
        );

        break;
      case AppRoutes.settings:
        screen = SettingsScreen(onMenuTap: onMenuTap);
        break;
      case AppRoutes.tax:
        screen = TaxScreen(onMenuTap: onMenuTap);
        break;
      case AppRoutes.discount:
        screen = DiscountScreen(onMenuTap: onMenuTap);
        break;
      case AppRoutes.salesReport:
        screen = SalesReportScreen(onMenuTap: onMenuTap);
        break;
      case AppRoutes.ledger:
        screen = LedgerScreen(onMenuTap: onMenuTap);
        break;
      case AppRoutes.dashboard:
      default:
      screen = DashboardScreen(
        onMenuTap: onMenuTap,
        onNavigate: _go, // ✅ add this
      );

      break;
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        activeRoute: _active,
        onNavigate: _go, // ✅ drawer tells HomeShell which screen to show
      ),
      body: SafeArea(child: screen),
    );
  }
}
