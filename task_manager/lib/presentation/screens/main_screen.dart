import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import 'admin/admin_dashboard.dart';
import 'admin/user_management_screen.dart';
import 'admin/task_assignment_screen.dart';
import 'admin/admin_notifications_screen.dart';
import 'user/user_dashboard_screen.dart';
import 'user/user_tasks_screen.dart';
import 'user/user_notifications_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<AnimationController> _itemControllers;

  static const primaryColor = Color(0xFF0D47A1);

  // Admin: Dashboard | Assign | Team | Alerts | Settings
  static const _adminItems = [
    _NavItem(icon: Icons.dashboard_rounded,       label: 'Dashboard'),
    _NavItem(icon: Icons.assignment_ind_rounded,  label: 'Assign'),
    _NavItem(icon: Icons.people_alt_rounded,      label: 'Team'),
    _NavItem(icon: Icons.notifications_rounded,   label: 'Alerts'),
    _NavItem(icon: Icons.settings_rounded,        label: 'Settings'),
  ];

  // User: Home | Tasks | Alerts | Settings
  static const _userItems = [
    _NavItem(icon: Icons.home_rounded,            label: 'Home'),
    _NavItem(icon: Icons.task_alt_rounded,        label: 'Tasks'),
    _NavItem(icon: Icons.notifications_rounded,   label: 'Alerts'),
    _NavItem(icon: Icons.settings_rounded,        label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _itemControllers = List.generate(
      5, // max tabs
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
      ),
    );
    _itemControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    _itemControllers[_selectedIndex].reverse();
    setState(() => _selectedIndex = index);
    _itemControllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final isAdmin = user?.role.name == 'admin';
    final userId = user?.id ?? '';

    final screens = isAdmin ? _adminScreens(userId) : _userScreens(userId);
    final items  = isAdmin ? _adminItems : _userItems;

    final notifications = ref.watch(notificationServiceProvider);
    final unreadCount = userId.isNotEmpty
        ? notifications.where((n) => n.userId == userId && !n.isRead).length
        : 0;

    // Clamp index in case role switches mid-session
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey(safeIndex),
          child: screens[safeIndex],
        ),
      ),
      bottomNavigationBar: _AnimatedNavBar(
        selectedIndex: safeIndex,
        items: items,
        onTap: _onNavTap,
        primaryColor: primaryColor,
        unreadCount: unreadCount,
        notifIndex: isAdmin ? 3 : 2,
        itemControllers: _itemControllers,
      ),
    );
  }

  List<Widget> _adminScreens(String userId) => [
        const AdminDashboard(),
        const TaskAssignmentScreen(),
        const UserManagementScreen(),
        const AdminNotificationsScreen(),
        const SettingsScreen(),
      ];

  List<Widget> _userScreens(String userId) => [
        UserDashboardScreen(userId: userId),
        UserTasksScreen(userId: userId),
        UserNotificationsScreen(userId: userId),
        const SettingsScreen(),
      ];
}

// ─────────────────────────── Nav data ────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─────────────────────────── Animated NavBar ─────────────────────────────────

class _AnimatedNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final Color primaryColor;
  final int unreadCount;
  final int notifIndex;
  final List<AnimationController> itemControllers;

  const _AnimatedNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.primaryColor,
    required this.unreadCount,
    required this.notifIndex,
    required this.itemControllers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.14),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => _NavBarItem(
                item: items[i],
                isSelected: i == selectedIndex,
                controller: itemControllers[i],
                primaryColor: primaryColor,
                badgeCount: i == notifIndex ? unreadCount : 0,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final AnimationController controller;
  final Color primaryColor;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.controller,
    required this.primaryColor,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.elasticOut,
                  child: Icon(
                    item.icon,
                    color: isSelected ? primaryColor : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -7,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
