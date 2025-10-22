import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/inventory/screens/stock_screen.dart';
import '../features/products/screens/add_product_screen.dart';
import '../features/sales/screens/sales_entry_screen.dart';
import '../features/reports/screens/reports_screen.dart';

class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot';
  static const reset = '/reset';
  static const dashboard = '/dashboard';
  static const stock = '/stock';
  static const addProduct = '/add-product';
  static const sales = '/sales';
  static const reports = '/reports';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    switch (name) {
      case '/':
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgot:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case reset:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case stock:
        return MaterialPageRoute(builder: (_) => const StockScreen());
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      case sales:
        return MaterialPageRoute(builder: (_) => const SalesEntryScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
