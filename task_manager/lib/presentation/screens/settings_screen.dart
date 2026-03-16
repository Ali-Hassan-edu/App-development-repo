import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../core/services/profile_image_service.dart';
import '../../core/services/session_service.dart';

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

  File? _profileImage;
  bool _loadingImage = false;

  final _profileService = ProfileImageService();
  final _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _loadProfileImage(user?.id);
  }

  Future<void> _loadProfileImage(String? userId) async {
    if (userId == null) return;
    final file = await _profileService.getProfileImage(userId);
    if (mounted && file != null) setState(() => _profileImage = file);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Profile photo picker ───────────────────────────────────────────────────

  void _showPhotoOptions() {
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Update Profile Photo',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 20),
              _PhotoOptionTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                color: primaryColor,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(user.id, fromCamera: false);
                },
              ),
              const SizedBox(height: 12),
              _PhotoOptionTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                color: const Color(0xFF1976D2),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(user.id, fromCamera: true);
                },
              ),
              if (_profileImage != null) ...[
                const SizedBox(height: 12),
                _PhotoOptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _profileService.deleteProfileImage(user.id);
                    if (mounted) setState(() => _profileImage = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(String userId, {required bool fromCamera}) async {
    setState(() => _loadingImage = true);
    try {
      final path = fromCamera
          ? await _profileService.captureAndSaveImage(userId)
          : await _profileService.pickAndSaveImage(userId);

      if (path != null && mounted) {
        setState(() => _profileImage = File(path));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile photo updated!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingImage = false);
    }
  }

  // ── Name save ──────────────────────────────────────────────────────────────

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
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  // ── Logout confirm ─────────────────────────────────────────────────────────

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Sign Out',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content:
            const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authStateProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (r) => false);
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isAdmin = user?.role.name == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
            // ── Profile Card ─────────────────────────────────────────────
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
                      offset: const Offset(0, 8))
                ],
              ),
              child: Row(
                children: [
                  // Avatar with edit overlay
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2),
                          ),
                          child: _loadingImage
                              ? const Center(
                                  child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2)))
                              : ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(_profileImage!,
                                          fit: BoxFit.cover,
                                          width: 72,
                                          height: 72)
                                      : Center(
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
                        ),
                        // Camera badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: primaryColor, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 13, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'User',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(isAdmin ? '👑 Admin' : '👤 User',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _showPhotoOptions,
                icon: const Icon(Icons.camera_alt_rounded,
                    size: 16, color: primaryColor),
                label: const Text('Change Profile Photo',
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),

            const SizedBox(height: 16),
            // ── Account Section ──────────────────────────────────────────
            const _SectionTitle(
                label: 'Account', icon: Icons.person_rounded),
            const SizedBox(height: 12),
            _SettingsCard(children: [
              // Name edit
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
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
                              color: Color(0xFF1A1A2E)),
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            labelStyle: const TextStyle(color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: primaryColor),
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
                      const SizedBox(width: 6),
                      _savingName
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: primaryColor))
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.check_rounded,
                                        color: Colors.green),
                                    onPressed: _saveName),
                                IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        color: Colors.red),
                                    onPressed: () {
                                      _nameController.text =
                                          user?.name ?? '';
                                      setState(() => _editingName = false);
                                    }),
                              ],
                            ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              _SettingsTile(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  subtitle: user?.email ?? ''),
            ]),

            const SizedBox(height: 20),
            // ── App Section ──────────────────────────────────────────────
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
                  activeThumbColor: primaryColor,
                ),
              ),
              const Divider(height: 1),
              const _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  label: 'App Version',
                  subtitle: '1.0.0'),
            ]),

            const SizedBox(height: 28),
            // ── Sign Out ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
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
}

// ── Photo option tile ─────────────────────────────────────────────────────────

class _PhotoOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PhotoOptionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

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
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2)),
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
              offset: const Offset(0, 4))
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
  const _SettingsTile(
      {required this.icon,
      required this.label,
      this.subtitle,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            color: const Color(0xFF0D47A1).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1A1A2E))),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
          : null,
      trailing: trailing,
    );
  }
}
