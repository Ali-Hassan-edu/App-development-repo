import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/services/permission_service.dart';
import 'core/services/push_notification_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/intro_screens.dart';
import 'presentation/screens/auth/admin_signup_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/auth/reset_password_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Supabase.initialize(
      url: 'https://xzbljwikiygxxozijqfy.supabase.co',
      anonKey: 'sb_publishable_u5r9zigh79peRXHp0Wuoig_E2WTotB0',
    );
  } catch (e) {
    debugPrint('Offline boot or Supabase init error: $e');
  }

  await PushNotificationService().initialize();

  runApp(const ProviderScope(child: TaskManagerApp()));
}

// Global navigator key so we can navigate from outside widget tree
final _navigatorKey = GlobalKey<NavigatorState>();

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Task Manager',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0), // fixes font overlap
              ),
              child: widget!,
            );
          },
          routes: {
            '/login':           (context) => const LoginScreen(),
            '/admin-signup':    (context) => const AdminSignupScreen(),
            '/main':            (context) => const MainScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/reset-password':  (context) => const ResetPasswordScreen(),
          },
          home: const AuthGate(),
        );
      },
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
  bool _isFirstLaunch = false;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initialize();
    _handleDeepLinks();
  }

  /// Handles incoming deep links.
  /// 
  /// Supabase sends password reset emails with PKCE flow:
  ///   com.hassan.pro.task.manager://reset-password?code=XXXX
  /// 
  /// We catch this URL, call exchangeCodeForSession() to get a valid
  /// session, then navigate to ResetPasswordScreen.
  void _handleDeepLinks() {
    // Handle link that launched the app (cold start)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _processDeepLink(uri);
    }).catchError((_) {});

    // Handle link while app is already running (warm start)
    _appLinks.uriLinkStream.listen((uri) {
      _processDeepLink(uri);
    }, onError: (_) {});
  }

  Future<void> _processDeepLink(Uri uri) async {
    final uriStr = uri.toString();
    debugPrint('🔗 Deep link received: $uriStr');

    // Check if this is a password reset link
    final isReset = uriStr.contains('reset-password') &&
        (uri.queryParameters.containsKey('code') ||
         uriStr.contains('access_token') ||
         uriStr.contains('type=recovery'));

    if (!isReset) return;

    try {
      // Exchange the PKCE code for a session
      await Supabase.instance.client.auth.exchangeCodeForSession(uriStr);
      debugPrint('✅ Code exchanged — navigating to ResetPasswordScreen');

      // Navigate to reset screen, clearing all previous routes
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/reset-password',
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ exchangeCodeForSession failed: $e');
      // Still navigate — session may already be set
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/reset-password',
        (route) => false,
      );
    }
  }

  Future<void> _initialize() async {
    try {
      if (mounted) {
        await ref.read(userRepositoryProvider).removeDuplicateAdmins();
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      _isFirstLaunch = prefs.getBool('first_launch') ?? true;
      await ref.read(authStateProvider.notifier).autoLogin();
    }

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

    if (_isFirstLaunch) {
      return IntroScreens(
        onFinish: () {
          setState(() {
            _isFirstLaunch = false;
          });
        },
      );
    }

    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) return const SplashScreen();
    if (authState.user != null) return const MainScreen();

    return const LoginScreen();
  }
}
