import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/permission_service.dart';
import 'core/services/push_notification_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/admin_signup_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: 'https://xzbljwikiygxxozijqfy.supabase.co',
    anonKey: 'sb_publishable_u5r9zigh79peRXHp0Wuoig_E2WTotB0',
  );

  await PushNotificationService().initialize();

  runApp(const ProviderScope(child: TaskManagerApp()));
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin-signup': (context) => const AdminSignupScreen(),
        '/main': (context) => const MainScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await ref.read(userRepositoryProvider).removeDuplicateAdmins();
    } catch (_) {}

    await ref.read(authStateProvider.notifier).autoLogin();

    if (!mounted) return;

    setState(() => _isInitializing = false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await PermissionService().showPermissionDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) return const SplashScreen();

    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) return const SplashScreen();
    if (authState.user != null) return const MainScreen();

    return const LoginScreen();
  }
}
