import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


import 'app.dart';

// AUTH
import 'state/auth/auth_provider.dart';
import 'services/auth_service.dart';
import 'data/remote/auth_remote.dart';
import 'data/repositories/auth_repository.dart';

// POS / Reports / Customers
import 'state/pos/cart_provider.dart';
import 'state/reports/report_provider.dart';
import 'state/customers/customer_provider.dart';
import 'state/categories/category_provider.dart';
import 'services/drive_backup_service.dart';


// PRODUCTS (Local SQLite)
import 'data/local/dao/product_dao.dart';
import 'data/local/dao/inventory_dao.dart';
import 'data/repositories/product_repository.dart';
import 'state/products/product_provider.dart';

// LEDGER
import 'data/local/dao/ledger_dao.dart';
import 'data/repositories/ledger_repository.dart';
import 'state/ledger/ledger_provider.dart';

// THEME
import 'state/theme/theme_provider.dart';

// ✅ BACKUP (Auto on minimize/background)
import 'services/backup_service.dart';
import 'services/app_lifecycle_backup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // AUTH DI
  final authRemote = AuthRemote();
  final authRepository = AuthRepository(authRemote);
  final authService = AuthService(authRepository);

  // PRODUCTS DI
  final productRepo = ProductRepository(ProductDao(), InventoryDao());

  // LEDGER DI
  final ledgerRepo = LedgerRepository(LedgerDao());

  // ✅ BACKUP DI + lifecycle observer start
  final backupService = BackupService();
  final lifecycleBackup = AppLifecycleBackup(backupService)..start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..bootstrap(),
        ),

        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepo)..load(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()..load()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()..load()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..load()),



        // ✅ Ledger Provider
        ChangeNotifierProvider(create: (_) => LedgerProvider(ledgerRepo)),

        // ✅ Backup Service Provider
        Provider<BackupService>.value(value: backupService),
        Provider<DriveBackupService>.value(value: DriveBackupService()),
      ],
      child: const MyApp(),
    ),
  );

  // lifecycleBackup stays alive for the full app session.
  // ignore: unused_local_variable
  final _keepAlive = lifecycleBackup;
}
