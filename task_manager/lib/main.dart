import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/auth/admin_signup_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (Primary Database)
  await Supabase.initialize(
    url: 'https://xzbljwikiygxxozijqfy.supabase.co',
    anonKey: 'sb_publishable_u5r9zigh79peRXHp0Wuoig_E2WTotB0',
  );

  // Firebase initialization removed - using local notification service instead

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
  bool _isAppStarting = true;

  @override
  void initState() {
    super.initState();
    // Remove duplicate admins on app start
    Future.microtask(() async {
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.removeDuplicateAdmins();

      // Then proceed with auto-login
      await ref.read(authStateProvider.notifier).autoLogin();

      // Mark app as finished starting
      if (mounted) {
        setState(() {
          _isAppStarting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Show splash screen only during initial app startup
    if (_isAppStarting) {
      return const SplashScreen();
    }

    // Show splash screen only during initial loading (first time)
    if (authState.isLoading && authState.user == null && !_isAppStarting) {
      // This is for login/signup operations, not app startup
      return const LoginScreen();
    }

    if (authState.user != null) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}
