import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:animations/animations.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _adminScreens = [
    const AdminDashboard(),
    const UserManagementScreen(),
    const TaskAssignmentScreen(),
    const AdminNotificationsScreen(),
    const SettingsScreen(),
  ];

  Widget _buildNotificationIcon(IconData icon, String label, int unreadCount) {
    return Stack(
      children: [
        Icon(icon),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  final List<Widget> _userScreens = [
    const UserDashboard(),
    const UserTasksScreen(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) return const SizedBox.shrink();

    final isAdmin = user.role == UserRole.admin;
    final screens = isAdmin ? _adminScreens : _userScreens;

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
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
          final user = ref.watch(authStateProvider).user;
          final allNotifications = ref.watch(notificationServiceProvider);
          final unreadCount = user != null
              ? allNotifications
                    .where(
                      (notification) =>
                          notification.userId == user.id &&
                          !notification.isRead,
                    )
                    .length
              : 0;

          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
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
                      icon: _buildNotificationIcon(
                        Icons.notifications_outlined,
                        'Alerts',
                        unreadCount,
                      ),
                      selectedIcon: _buildNotificationIcon(
                        Icons.notifications,
                        'Alerts',
                        unreadCount,
                      ),
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
                      icon: _buildNotificationIcon(
                        Icons.notifications_outlined,
                        'Alerts',
                        unreadCount,
                      ),
                      selectedIcon: _buildNotificationIcon(
                        Icons.notifications,
                        'Alerts',
                        unreadCount,
                      ),
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
