import 'package:flutter/material.dart';

import '../../ui/screens/home/home_shell.dart';
import '../../ui/screens/splash/splash_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/signup_screen.dart';
import '../../ui/screens/ledger/ledger_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';

  static const home = '/home';
  static const itemSalesReport = '/itemSalesReport';
  static const purchaseReport = '/purchaseReport';

  // inner “tabs”
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const categories = '/categories';
  static const bill = '/bill';
  static const customers = '/customers';
  static const settings = '/settings';
  static const tax = '/tax';
  static const discount = '/discount';
  static const salesReport = '/salesReport';

  // ✅ Ledger
  static const ledger = '/ledger';

  // ✅ Ledger by customer (push route)
  static const ledgerCustomer = '/ledgerCustomer';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),

    home: (_) => const HomeShell(),

    dashboard: (_) => const HomeShell(startRoute: dashboard),
    products: (_) => const HomeShell(startRoute: products),
    categories: (_) => const HomeShell(startRoute: categories),
    bill: (_) => const HomeShell(startRoute: bill),
    customers: (_) => const HomeShell(startRoute: customers),
    settings: (_) => const HomeShell(startRoute: settings),
    tax: (_) => const HomeShell(startRoute: tax),
    discount: (_) => const HomeShell(startRoute: discount),
    salesReport: (_) => const HomeShell(startRoute: salesReport),
    itemSalesReport: (_) => const HomeShell(startRoute: itemSalesReport),
    purchaseReport: (_) => const HomeShell(startRoute: purchaseReport),

    // Ledger inside Shell
    ledger: (_) => const HomeShell(startRoute: ledger),

    // ✅ Ledger "direct" screen for a customer (opens on top)
    // expects arguments: customerId (String)
    ledgerCustomer: (ctx) {
      final args = ModalRoute.of(ctx)?.settings.arguments;
      final customerId = (args is String) ? args : null;

      // open as a normal screen (not via shell drawer)
      return LedgerScreen(
        onMenuTap: () => Navigator.pop(ctx),
        initialCustomerId: customerId,
      );
    },
  };
}
