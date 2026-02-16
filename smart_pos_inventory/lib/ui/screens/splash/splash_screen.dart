import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../state/auth/auth_provider.dart';
import '../../../state/products/product_provider.dart';
import '../../../state/customers/customer_provider.dart';
import '../../../state/categories/category_provider.dart';
import '../../../state/reports/report_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;

    final auth = context.read<AuthProvider>();

    // ✅ wait until auth provider finishes bootstrap
    if (auth.isLoading) {
      Future.delayed(const Duration(milliseconds: 250), _goNext);
      return;
    }

    // ❌ Not logged in
    if (!auth.isLoggedIn) {
      _navigated = true;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      return;
    }

    // ✅ Logged in: NOW safe to load Firestore
    try {
      await Future.wait([
        context.read<ProductProvider>().load(),
        context.read<CustomerProvider>().load(),
        context.read<CategoryProvider>().load(),
        context.read<ReportProvider>().load(),
      ]);
    } catch (_) {
      // ignore: you can show a snackBar if you want
    }

    if (!mounted) return;
    _navigated = true;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF), Color(0xFFFF5E7E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: const Icon(Icons.point_of_sale, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Smart POS',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30),
                ),
                const SizedBox(height: 6),
                Text(
                  'Inventory • Billing • Reports',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text('Loading...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
