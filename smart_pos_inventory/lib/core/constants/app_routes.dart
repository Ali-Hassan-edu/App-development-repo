import 'package:flutter/material.dart';

import '../../ui/screens/home/home_shell.dart';
import '../../ui/screens/splash/splash_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/signup_screen.dart';

// extra screens (direct navigation)
import '../../ui/screens/pos/cart_screen.dart';
import '../../ui/screens/pos/checkout_screen.dart';
import '../../ui/screens/customers/customer_detail_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';

  static const home = '/home';

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

  // direct screens (not tabs)
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const customerDetail = '/customerDetail';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),

    home: (_) => const HomeShell(),

    // ✅ Inner routes open Shell with correct start tab
    dashboard: (_) => const HomeShell(startRoute: dashboard),
    products: (_) => const HomeShell(startRoute: products),
    categories: (_) => const HomeShell(startRoute: categories),
    bill: (_) => const HomeShell(startRoute: bill),
    customers: (_) => const HomeShell(startRoute: customers),
    settings: (_) => const HomeShell(startRoute: settings),
    tax: (_) => const HomeShell(startRoute: tax),
    discount: (_) => const HomeShell(startRoute: discount),
    salesReport: (_) => const HomeShell(startRoute: salesReport),

    // ✅ Direct routes
    cart: (_) => const CartScreen(),
    checkout: (_) => const CheckoutScreen(),
    customerDetail: (_) => const CustomerDetailScreen(),
  };
}
