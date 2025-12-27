import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../state/auth/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final shopName = (auth.user?.displayName?.trim().isNotEmpty ?? false)
        ? auth.user!.displayName!.trim()
        : 'Your Shop';

    return Scaffold(
      drawer: const AppDrawer(activeRoute: '/dashboard'),
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.point_of_sale),
            SizedBox(width: 8),
            Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              child: Text(shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S'),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(shopName).animate().fadeIn(duration: 280.ms).slideY(begin: .12),
          const SizedBox(height: 14),

          // ✅ 2 cards per row
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.55,
            children: [
              _statMini('Sales Today', '₹ 12,450', Icons.trending_up, const [Color(0xFFFF5E7E), Color(0xFFFFC371)]),
              _statMini('Items', '248', Icons.inventory_2_outlined, const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
              _statMini('Customers', '56', Icons.people_alt_outlined, const [Color(0xFF00C9A7), Color(0xFF92FE9D)]),
              _statMini('Low Stock', '7', Icons.warning_amber_rounded, const [Color(0xFFFF4D6D), Color(0xFF6D5DF6)]),
            ],
          ).animate().fadeIn(duration: 420.ms).slideY(begin: .10),

          const SizedBox(height: 18),

          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))
              .animate()
              .fadeIn(duration: 520.ms),

          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.15,
            children: [
              _actionTile('New Bill', 'Create invoice', Icons.receipt_long, const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)], onTap: () {}),
              _actionTile('Add Product', 'Add new item', Icons.add_box_outlined, const [Color(0xFFFF5E7E), Color(0xFFFFC371)], onTap: () {}),
              _actionTile('Inventory', 'Stock & logs', Icons.inventory_2_outlined, const [Color(0xFF00C9A7), Color(0xFF92FE9D)], onTap: () {}),
              _actionTile('Reports', 'Sales insights', Icons.bar_chart, const [Color(0xFFFF4D6D), Color(0xFF6D5DF6)], onTap: () {}),
            ],
          ).animate().fadeIn(duration: 620.ms).slideY(begin: .08),

          const SizedBox(height: 18),

          Text('Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))
              .animate()
              .fadeIn(duration: 740.ms),

          const SizedBox(height: 10),

          _activityCard('Sale completed', 'Bill #1021 • ₹ 1,250', Icons.check_circle)
              .animate()
              .fadeIn(duration: 860.ms)
              .slideX(begin: .06),
          _activityCard('Stock updated', '7 items low stock', Icons.inventory_2_outlined)
              .animate()
              .fadeIn(duration: 960.ms)
              .slideX(begin: .06),
          _activityCard('New customer', 'Added: Rahul Sharma', Icons.person_add_alt_1)
              .animate()
              .fadeIn(duration: 1060.ms)
              .slideX(begin: .06),
        ],
      ),
    );
  }

  Widget _welcomeCard(String shopName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
        boxShadow: [
          BoxShadow(color: const Color(0xFF3CC5FF).withAlpha(60), blurRadius: 28, offset: const Offset(0, 14))
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withAlpha(40),
            ),
            child: const Icon(Icons.storefront, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome 👋', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(shopName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withAlpha(40),
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _statMini(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: colors),
        boxShadow: [BoxShadow(color: colors.last.withAlpha(60), blurRadius: 22, offset: const Offset(0, 12))],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withAlpha(40),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
      String title,
      String subtitle,
      IconData icon,
      List<Color> colors, {
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(16), blurRadius: 18, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(colors: colors),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withAlpha(10),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
