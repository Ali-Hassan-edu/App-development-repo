import 'package:flutter/material.dart';
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
    final titleColor = isDark ? Colors.white : Colors.black87;

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

    void openBackup() {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
    }

    return BackToDashboardWrapper(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
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
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card(
                      isDark: isDark,
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
                    const SizedBox(height: 12),

                    // Local + restore + Drive (same screen)
                    _card(
                      isDark: isDark,
                      child: ListTile(
                        leading: Icon(Icons.backup_outlined, color: titleColor),
                        title: Text(
                          'Backup & Restore',
                          style: TextStyle(fontWeight: FontWeight.w900, color: titleColor),
                        ),
                        subtitle: Text(
                          'Manual, auto & restore backups',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: titleColor),
                        onTap: openBackup,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ✅ Now it OPENS the backup screen (no snackbar)
                    _card(
                      isDark: isDark,
                      child: ListTile(
                        leading: const Icon(Icons.cloud_outlined, color: Color(0xFF3CC5FF)),
                        title: Text(
                          'Google Drive Backup',
                          style: TextStyle(fontWeight: FontWeight.w900, color: titleColor),
                        ),
                        subtitle: Text(
                          'Sync backups to Google Drive',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: titleColor),
                        onTap: openBackup,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E35) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: child,
    );
  }
}
