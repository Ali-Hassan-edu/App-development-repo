import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'ui/screens/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart POS Inventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: AppRoutes.routes,
      home: const SplashScreen(), // ✅ App always starts here
    );
  }
}
