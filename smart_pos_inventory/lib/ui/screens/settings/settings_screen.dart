import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../state/theme/theme_provider.dart';
import '../../widgets/back_to_dashboard.dart';
import 'backup_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onMenuTap; // keep for compatibility
  const SettingsScreen({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;

    final bgGradient = isDark
        ? const LinearGradient(
      colors: [Color(0xFF0F1320), Color(0xFF121A31), Color(0xFF0F1320)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFF4F7FF), Color(0xFFFFF6F9), Color(0xFFF6FFFB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final titleColor = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    void openBackup() {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
    }

    return BackToDashboardWrapper(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                  child: Row(
                    children: [
                      backToDashboardButton(context, color: titleColor),
                      const SizedBox(width: 8),
                      Icon(Icons.settings, color: titleColor),
                      const SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 240.ms).slideY(begin: .10),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    children: [
                      _sectionTitle('Appearance', titleColor).animate().fadeIn(duration: 260.ms),

                      const SizedBox(height: 10),
                      _card(
                        isDark: isDark,
                        child: Row(
                          children: [
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]
                                      : const [Color(0xFFFF5E7E), Color(0xFFFFC371)],
                                ),
                              ),
                              child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dark Mode',
                                      style: TextStyle(color: titleColor, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 2),
                                  Text('Switch theme appearance',
                                      style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            Switch(
                              value: isDark,
                              onChanged: (v) => context.read<ThemeProvider>().setDark(v),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 320.ms).slideY(begin: .06),

                      const SizedBox(height: 16),
                      _sectionTitle('Backup', titleColor).animate().fadeIn(duration: 260.ms),

                      const SizedBox(height: 10),

                      // ✅ ONLY ONE BACKUP TILE (removed duplicate drive tile)
                      _card(
                        isDark: isDark,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: openBackup,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  height: 46,
                                  width: 46,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                                    ),
                                  ),
                                  child: const Icon(Icons.backup_outlined, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Backup & Restore',
                                          style: TextStyle(fontWeight: FontWeight.w900, color: titleColor)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Local + Google Drive in one place',
                                        style: TextStyle(fontWeight: FontWeight.w700, color: sub),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: titleColor),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 360.ms).slideY(begin: .06),

                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t, Color c) {
    return Text(
      t,
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: c),
    );
  }

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E35) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }
}
