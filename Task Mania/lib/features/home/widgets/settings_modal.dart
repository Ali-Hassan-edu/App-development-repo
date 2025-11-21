import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../data/services/export_service.dart';
import '../../../data/services/permission_service.dart';
import '../../task_management/providers/task_provider.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  Future<void> _export(BuildContext context, {required bool isPdf}) async {
    final provider = context.read<TaskProvider>();
    final export = ExportService();

    try {
      final tasks = provider.tasks;
      final subs = provider.subtasks;

      final path = isPdf
          ? await export.exportTasksToPdf(tasks, subs)
          : await export.exportTasksToCsv(tasks, subs);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPdf ? 'PDF exported successfully!' : 'CSV exported successfully!'),
            backgroundColor: const Color(0xFF00BC8C),
          ),
        );
      }

      if (isPdf) {
        await export.sharePdf(path);
      } else {
        await export.shareCsv(path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestPermissions(BuildContext context) async {
    try {
      await PermissionService.requestAllPermissions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Permissions requested! Notifications will work even when app is killed'),
            backgroundColor: Color(0xFF00BC8C),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final taskProv = context.watch<TaskProvider>();
    final isDark = themeProv.themeMode == ThemeMode.dark;

    // Calculate task statistics
    final totalTasks = taskProv.tasks.length;
    final completedTasks = taskProv.tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFF0F4FF), Colors.white],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00BC8C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2D3748),
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // App Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF00BC8C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_rounded, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Task Mania',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Ultimate Task Manager',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total', totalTasks.toString()),
                        _buildStatItem('Pending', pendingTasks.toString()),
                        _buildStatItem('Done', completedTasks.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionHeader('Appearance', Icons.palette_rounded, isDark),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                isDark: isDark,
                trailing: Switch(
                  value: themeProv.themeMode == ThemeMode.dark,
                  onChanged: (_) => themeProv.toggleTheme(),
                  activeColor: const Color(0xFF00BC8C),
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader('Data Management', Icons.folder_rounded, isDark),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Export to PDF',
                subtitle: 'Download all tasks as PDF document',
                isDark: isDark,
                onTap: () => _export(context, isPdf: true),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.table_rows_rounded,
                iconColor: Colors.blue,
                title: 'Export to CSV',
                subtitle: 'Download tasks as spreadsheet file',
                isDark: isDark,
                onTap: () => _export(context, isPdf: false),
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionHeader('Notifications', Icons.notifications_rounded, isDark),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.security_rounded,
                iconColor: Colors.orange,
                title: 'Enable Background Notifications',
                subtitle: 'Allow notifications when app is killed/removed from RAM',
                isDark: isDark,
                onTap: () => _requestPermissions(context),
              ),
              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('About', Icons.info_rounded, isDark),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.code_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Version',
                subtitle: '1.0.0+1',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.favorite_rounded,
                iconColor: Colors.red,
                title: 'Made with Flutter',
                subtitle: 'Built with ❤️ for productivity',
                isDark: isDark,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6C63FF),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}