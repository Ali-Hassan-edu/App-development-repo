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
  // int _selectedIndex = 0; // Moved to provider
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
    _itemControllers[ref.read(mainScreenIndexProvider)].forward();
  }

  @override
  void dispose() {
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNavTap(int index) {
    final currentIndex = ref.read(mainScreenIndexProvider);
    if (index == currentIndex) return;
    _itemControllers[currentIndex].reverse();
    ref.read(mainScreenIndexProvider.notifier).state = index;
    _itemControllers[index].forward();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authStateProvider.notifier).logout();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (r) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final isAdmin = user?.role.name == 'admin';
    final userId = user?.id ?? '';

    final screens = isAdmin ? _adminScreens(userId) : _userScreens(userId);
    final items  = isAdmin ? _adminItems : _userItems;

    final notifAsync = ref.watch(userNotificationsProvider(userId));
    final unreadCount = notifAsync.maybeWhen(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

    final selectedIndex = ref.watch(mainScreenIndexProvider);

    // Clamp index in case role switches mid-session
    final safeIndex = selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      drawer: _buildDrawer(
        items: items,
        safeIndex: safeIndex,
        primaryColor: primaryColor,
        unreadCount: unreadCount,
        notifIndex: isAdmin ? 3 : 2,
        userName: user?.name ?? 'User',
        userEmail: user?.email ?? '',
      ),
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

  Widget _buildDrawer({
    required List<_NavItem> items,
    required int safeIndex,
    required Color primaryColor,
    required int unreadCount,
    required int notifIndex,
    required String userName,
    required String userEmail,
  }) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(userEmail, style: const TextStyle(color: Colors.white70)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryColor),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == safeIndex;
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? primaryColor : Colors.grey.shade600,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  trailing: index == notifIndex && unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                  tileColor: isSelected ? primaryColor.withOpacity(0.08) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    _onNavTap(index);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          ListTile(
            leading: const Icon(Icons.lock_reset_rounded, color: Colors.black87),
            title: const Text('Reset Password', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: () async {
              Navigator.pop(context);
              if (userEmail.isNotEmpty) {
                await ref.read(authStateProvider.notifier).forgotPassword(userEmail);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset link sent to $userEmail'),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: () {
              Navigator.pop(context);
              _confirmLogout();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Swipe left or tap outside to close',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          )
        ],
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
