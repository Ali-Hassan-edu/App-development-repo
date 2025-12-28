import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';

// AUTH
import 'state/auth/auth_provider.dart';
import 'services/auth_service.dart';
import 'data/remote/auth_remote.dart';
import 'data/repositories/auth_repository.dart';

// PRODUCTS (Local)
import 'data/local/dao/product_dao.dart';
import 'data/local/dao/inventory_dao.dart';
import 'data/repositories/product_repository.dart';
import 'state/products/product_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // AUTH DI
  final authRemote = AuthRemote();
  final authRepository = AuthRepository(authRemote);
  final authService = AuthService(authRepository);

  // PRODUCTS DI
  final productRepository = ProductRepository(ProductDao(), InventoryDao());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository)..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
