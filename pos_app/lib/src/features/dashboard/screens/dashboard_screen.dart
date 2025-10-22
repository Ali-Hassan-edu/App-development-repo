import 'package:flutter/material.dart';
import '../../../core/router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [s.primary, s.secondary]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: s.onPrimary)),
                  const SizedBox(height: 8),
                  Text('Your POS quick actions', style: TextStyle(color: s.onPrimary.withOpacity(0.9))),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _Tile(
                  icon: Icons.point_of_sale,
                  label: 'Sales',
                  colors: [s.primary, s.primaryContainer],
                  onTap: () => Navigator.pushNamed(context, AppRouter.sales),
                ),
                _Tile(
                  icon: Icons.add_box,
                  label: 'Add Product',
                  colors: [s.tertiary, s.secondaryContainer],
                  onTap: () => Navigator.pushNamed(context, AppRouter.addProduct),
                ),
                _Tile(
                  icon: Icons.inventory_2,
                  label: 'Stock',
                  colors: [s.secondary, s.tertiaryContainer],
                  onTap: () => Navigator.pushNamed(context, AppRouter.stock),
                ),
                _Tile(
                  icon: Icons.assessment,
                  label: 'Reports',
                  colors: [s.error, s.errorContainer],
                  onTap: () => Navigator.pushNamed(context, AppRouter.reports),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Tip'),
                  subtitle: const Text('Use Sales to create invoices; Reports to export PDFs to Downloads.'),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 42, color: Colors.white),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}
