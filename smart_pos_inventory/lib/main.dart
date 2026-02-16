import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// ✅ NEW: for auto-refresh on reports screen (RouteAware)


import 'app.dart';

// THEME
import 'state/theme/theme_provider.dart';

// AUTH
import 'state/auth/auth_provider.dart';
import 'services/auth_service.dart';
import 'data/remote/auth_remote.dart';
import 'data/repositories/auth_repository.dart';

// ONLINE PROVIDERS
import 'state/products/product_provider.dart';
import 'state/pos/cart_provider.dart';
import 'state/reports/report_provider.dart';
import 'state/customers/customer_provider.dart';
import 'state/categories/category_provider.dart';
import 'state/ledger/ledger_provider.dart';

// BACKUP
import 'services/backup_service.dart';
import 'services/app_lifecycle_backup.dart';
import 'services/drive_backup_service.dart';
final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // AUTH DI
  final authRemote = AuthRemote();
  final authRepository = AuthRepository(authRemote);
  final authService = AuthService(authRepository);

  // BACKUP DI + lifecycle observer start
  final backupService = BackupService();
  final lifecycleBackup = AppLifecycleBackup(backupService)..start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)..bootstrap()),

        // ✅ Providers (NO load here)
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => LedgerProvider()),

        Provider<BackupService>.value(value: backupService),
        Provider<DriveBackupService>.value(value: DriveBackupService()),
      ],
      child: const MyApp(),
    ),
  );

  // keep lifecycleBackup alive for full app session
  // ignore: unused_local_variable
  final keepAlive = lifecycleBackup;
}
