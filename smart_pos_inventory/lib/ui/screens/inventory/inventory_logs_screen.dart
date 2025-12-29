import 'package:flutter/material.dart';

class InventoryLogsScreen extends StatelessWidget {
  final VoidCallback onMenuTap;
  const InventoryLogsScreen({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
          colors: [Color(0xFF0F1320), Color(0xFF121A31), Color(0xFF0F1320)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFFF4F7FF), Color(0xFFFFF6F9), Color(0xFFF6FFFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: titleColor),
                  onPressed: onMenuTap,
                ),
                const SizedBox(width: 8),
                Icon(Icons.receipt_outlined, color: titleColor),
                const SizedBox(width: 8),
                Text(
                  'Inventory Logs',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(child: Text('Inventory Logs Screen (Todo)')),
          ),
        ],
      ),
    );
  }
}
