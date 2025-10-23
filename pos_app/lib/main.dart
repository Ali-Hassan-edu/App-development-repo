import 'package:flutter/material.dart';
import 'src/core/router.dart';
import 'src/ui/theme.dart';
import 'src/features/auth/persistence/session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionStore().init();
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: SessionStore().isBootRemembered ? AppRouter.dashboard : AppRouter.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
