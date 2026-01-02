import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';

// AUTH
import 'state/auth/auth_provider.dart';
import 'services/auth_service.dart';
import 'data/remote/auth_remote.dart';
import 'data/repositories/auth_repository.dart';
import 'state/pos/cart_provider.dart';
import 'state/reports/report_provider.dart';
import 'state/customers/customer_provider.dart';


// PRODUCTS (Local SQLite)
import 'data/local/dao/product_dao.dart';
import 'data/local/dao/inventory_dao.dart';
import 'data/repositories/product_repository.dart';
import 'state/products/product_provider.dart';

// THEME
import 'state/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // AUTH DI
  final authRemote = AuthRemote();
  final authRepository = AuthRepository(authRemote);
  final authService = AuthService(authRepository);

  // PRODUCTS DI
  final productRepo = ProductRepository(ProductDao(), InventoryDao());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)..bootstrap()),
        ChangeNotifierProvider(create: (_) => ProductProvider(productRepo)..load()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()..load()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()..load()),




      ],
      child: const MyApp(),
    ),
  );
}
