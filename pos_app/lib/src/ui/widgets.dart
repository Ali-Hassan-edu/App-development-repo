import 'package:flutter/material.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  const ThemedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
    return card;
  }
}

class PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.icon, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(icon: Icon(icon), onPressed: onPressed, label: Text(label));
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;
  const StatCard({super.key, required this.title, required this.value, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      gradient: LinearGradient(
        colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.tertiaryContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8, top: 6),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

class TileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const TileButton({super.key, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [cs.primaryContainer, cs.secondaryContainer]),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: cs.onPrimaryContainer),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
