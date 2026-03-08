import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import 'admin/admin_dashboard.dart';
import 'admin/user_management_screen.dart';
import 'admin/task_assignment_screen.dart';
import 'admin/admin_notifications_screen.dart';
import 'user/user_dashboard.dart';
import 'user/tasks_screen.dart';
import 'user/notifications_screen.dart';
import 'settings_screen.dart';
import '../../domain/entities/user_entity.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _adminScreens = const [
    AdminDashboard(),
    UserManagementScreen(),
    TaskAssignmentScreen(),
    AdminNotificationsScreen(),
    SettingsScreen(),
  ];

  final List<Widget> _userScreens = const [
    UserDashboard(),
    UserTasksScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  Widget _buildNotificationIcon(IconData icon, int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) return const SizedBox.shrink();

    final isAdmin = user.role == UserRole.admin;
    final screens = isAdmin ? _adminScreens : _userScreens;

    // Listen for auth state changes (logout)
    ref.listen(authStateProvider, (prev, next) {
      if (next.user == null && prev?.user != null) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final allNotifications = ref.watch(notificationServiceProvider);
          final unreadCount = allNotifications
                    .where((n) => n.userId == user.id && !n.isRead)
                    .length;

          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: isAdmin
                ? [
                    const NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Stats',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: 'Users',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment),
                      label: 'Tasks',
                    ),
                    NavigationDestination(
                      icon: _buildNotificationIcon(Icons.notifications_outlined, unreadCount),
                      selectedIcon: _buildNotificationIcon(Icons.notifications, unreadCount),
                      label: 'Alerts',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ]
                : [
                    const NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Home',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.list_alt_outlined),
                      selectedIcon: Icon(Icons.list_alt),
                      label: 'My Tasks',
                    ),
                    NavigationDestination(
                      icon: _buildNotificationIcon(Icons.notifications_outlined, unreadCount),
                      selectedIcon: _buildNotificationIcon(Icons.notifications, unreadCount),
                      label: 'Alerts',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
          );
        },
      ),
    );
  }
}
