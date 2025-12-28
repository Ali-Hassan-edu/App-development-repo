import 'package:flutter/material.dart';

import '../../ui/screens/splash/splash_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/signup_screen.dart';
import '../../ui/screens/dashboard/dashboard_screen.dart';

// real screens
import '../../ui/screens/items/products_screen.dart';
import '../../ui/screens/items/categories_screen.dart';
import '../../ui/screens/pos/bill_screen.dart';
import '../../ui/screens/customers/customers_screen.dart';
import '../../ui/screens/inventory/inventory_list_screen.dart';
import '../../ui/screens/inventory/inventory_logs_screen.dart';
import '../../ui/screens/reports/sales_report_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const dashboard = '/dashboard';

  static const products = '/products';
  static const categories = '/categories';
  static const bill = '/bill';
  static const customers = '/customers';
  static const inventoryList = '/inventoryList';
  static const inventoryLogs = '/inventoryLogs';
  static const salesReport = '/salesReport';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    dashboard: (_) => const DashboardScreen(),

    products: (_) => const ProductsScreen(),
    categories: (_) => const CategoriesScreen(),
    bill: (_) => const BillScreen(),
    customers: (_) => const CustomersScreen(),
    inventoryList: (_) => const InventoryListScreen(),
    inventoryLogs: (_) => const InventoryLogsScreen(),
    salesReport: (_) => const SalesReportScreen(),
    settings: (_) => const SettingsScreen(),
  };
}
