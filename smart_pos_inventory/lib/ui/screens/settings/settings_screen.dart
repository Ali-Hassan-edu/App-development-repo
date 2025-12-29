import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onMenuTap;
  const SettingsScreen({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;
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
                IconButton(icon: Icon(Icons.menu, color: titleColor), onPressed: onMenuTap),
                const SizedBox(width: 8),
                Icon(Icons.settings, color: titleColor),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161E35) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: titleColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Dark Mode',
                          style: TextStyle(color: titleColor, fontWeight: FontWeight.w900),
                        ),
                      ),
                      Switch(
                        value: isDark,
                        onChanged: (v) => context.read<ThemeProvider>().setDark(v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
