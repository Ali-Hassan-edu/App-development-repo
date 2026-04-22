import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/services/permission_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/session_service.dart';
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
            '/login': (context) => const LoginScreen(),
            '/admin-signup': (context) => const AdminSignupScreen(),
            '/main': (context) => const MainScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
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

class _AuthGateState extends ConsumerState<AuthGate>
    with WidgetsBindingObserver {
  bool _isInitializing = true;
  bool _isFirstLaunch = false;
  final _appLinks = AppLinks();
  final _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    _handleDeepLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('🔄 App lifecycle state changed: $state');

    if (state == AppLifecycleState.resumed) {
      // App resumed - refresh session
      _refreshSessionOnResume();
    } else if (state == AppLifecycleState.paused) {
      // App going to background - can save state here if needed
      debugPrint('📱 App going to background');
    }
  }

  Future<void> _refreshSessionOnResume() async {
    try {
      // Refresh the session timestamp to keep it alive
      await _sessionService.refreshSession();

      final isStillLoggedIn = await _sessionService.isLoggedIn();
      if (isStillLoggedIn) {
        debugPrint('✅ Session still valid after app resume');
      } else {
        debugPrint('❌ Session expired while app was in background');
        if (mounted && ref.read(authStateProvider).user != null) {
          // If user was logged in but session expired, trigger re-login
          ref.read(authStateProvider.notifier).logout();
        }
      }
    } catch (e) {
      debugPrint('❌ Error refreshing session on resume: $e');
    }
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
      debugPrint('🚀 First launch status: $_isFirstLaunch');

      // Ensure first_launch is properly set in prefs
      if (_isFirstLaunch) {
        await prefs.setBool('first_launch', true);
        debugPrint('📝 Ensured first_launch flag is set in SharedPreferences');
      }

      // Perform auto-login
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
          debugPrint('✅ Introduction completed, marking first_launch as done');
        },
      );
    }

    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) return const SplashScreen();

    if (authState.user != null) {
      debugPrint(
          '✅ User authenticated: ${authState.user!.email} (${authState.user!.role})');
      return const MainScreen();
    }

    debugPrint('❌ No authenticated user, showing LoginScreen');
    return const LoginScreen();
  }
}
