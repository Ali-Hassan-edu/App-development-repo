import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const primaryColor = Color(0xFF0D47A1);
  late TextEditingController _nameController;
  bool _editingName = false;
  bool _savingName = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isAdmin = user?.role.name == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (user?.name.isNotEmpty == true)
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAdmin ? '👑 Admin' : '👤 User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const _SectionTitle(label: 'Account', icon: Icons.person_rounded),
            const SizedBox(height: 12),
            _SettingsCard(children: [
              if (!_editingName)
                _SettingsTile(
                  icon: Icons.badge_outlined,
                  label: 'Display Name',
                  subtitle: user?.name ?? '',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: primaryColor, size: 20),
                    onPressed: () => setState(() => _editingName = true),
                  ),
                )
              else
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined,
                          color: primaryColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            labelStyle: const TextStyle(color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _savingName
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            )
                          : Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_rounded,
                                      color: Colors.green),
                                  onPressed: _saveName,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      color: Colors.red),
                                  onPressed: () {
                                    _nameController.text = user?.name ?? '';
                                    setState(() => _editingName = false);
                                  },
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.email_outlined,
                label: 'Email Address',
                subtitle: user?.email ?? '',
              ),
            ]),
            const SizedBox(height: 20),
            const _SectionTitle(label: 'App', icon: Icons.settings_rounded),
            const SizedBox(height: 12),
            _SettingsCard(children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                subtitle: 'In-app and push alerts enabled',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: primaryColor,
                ),
              ),
              const Divider(height: 1),
              const _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                subtitle: '1.0.0',
              ),
            ]),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _savingName = true);

    try {
      await ref.read(authStateProvider.notifier).updateUserName(newName);

      if (!mounted) return;

      setState(() {
        _editingName = false;
        _savingName = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Name updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _savingName = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmLogout(BuildContext context) {
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
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              await ref.read(authStateProvider.notifier).logout();

              if (!context.mounted) return;

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
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
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionTitle({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0D47A1), size: 18),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF0D47A1),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            )
          : null,
      trailing: trailing,
    );
  }
}
