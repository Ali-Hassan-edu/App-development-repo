import 'package:flutter/material.dart';
import '../../../core/router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final cards = <_DashCard>[
      _DashCard('Sales', Icons.point_of_sale, AppRouter.sales),
      _DashCard('Add Product', Icons.add_box, AppRouter.addProduct),
      _DashCard('Inventory / Stock', Icons.inventory_2, AppRouter.stock),
      _DashCard('Reports', Icons.bar_chart, AppRouter.reports),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [s.primaryContainer, s.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Welcome 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards.map((c) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width > 600 ? 280 : double.infinity,
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pushNamed(context, c.route),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: s.primary,
                              child: Icon(c.icon, color: s.onPrimary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Text(c.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard {
  final String title;
  final IconData icon;
  final String route;
  _DashCard(this.title, this.icon, this.route);
}
