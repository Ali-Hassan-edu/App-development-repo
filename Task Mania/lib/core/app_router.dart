import 'package:flutter/material.dart';

import '../features/home/screens/main_screen.dart';
import '../features/home/screens/splash_screen.dart';
import '../features/task_management/screens/add_edit_task_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(nextScreen: MainScreen()),
        );

      case '/home':
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case '/addTask':
        return MaterialPageRoute(builder: (_) => const AddEditTaskScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route defined')),
          ),
        );
    }
  }
}
