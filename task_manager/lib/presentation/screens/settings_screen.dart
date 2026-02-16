import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/services/profile_image_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      final imageFile = await ProfileImageService().getProfileImage(user.id);
      if (imageFile != null && mounted) {
        setState(() {
          profileImagePath = imageFile.path;
        });
      }
    }
  }

  void _showProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF0D47A1),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final user = ref.read(authStateProvider).user;
                if (user != null) {
                  final imagePath = await ProfileImageService()
                      .pickAndSaveImage(user.id);
                  if (imagePath != null && mounted) {
                    setState(() {
                      profileImagePath = imagePath;
                    });
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D47A1)),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final user = ref.read(authStateProvider).user;
                if (user != null) {
                  final imagePath = await ProfileImageService()
                      .captureAndSaveImage(user.id);
                  if (imagePath != null && mounted) {
                    setState(() {
                      profileImagePath = imagePath;
                    });
                  }
                }
              },
            ),
            if (profileImagePath != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final user = ref.read(authStateProvider).user;
                  if (user != null) {
                    await ProfileImageService().deleteProfileImage(user.id);
                    if (mounted) {
                      setState(() {
                        profileImagePath = null;
                      });
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          'ACCOUNT SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showProfileImageOptions,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                      child: ClipOval(
                        child: profileImagePath != null
                            ? Image.file(
                                File(profileImagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return CircleAvatar(
                                    radius: 40,
                                    backgroundColor: primaryColor,
                                    child: Text(
                                      user?.name[0].toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: primaryColor,
                                child: Text(
                                  user?.name[0].toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        Text(
                          user?.email ?? 'email@example.com',
                          style: const TextStyle(
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.role.name.toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Add upload text
                        Text(
                          'Tap profile picture to upload',
                          style: TextStyle(
                            color: primaryColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSettingTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => _showEditProfileDialog(ref, user),
              color: primaryColor,
            ),
            _buildSettingTile(
              icon: Icons.security,
              title: 'Security',
              onTap: () => _showSecurityDialog(),
              color: primaryColor,
            ),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => _showHelpDialog(),
              color: primaryColor,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(WidgetRef ref, user) {
    final nameController = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D47A1),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person, color: Color(0xFF0D47A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty && user != null) {
                // Update name in Supabase
                try {
                  final updatedUser = UserEntity(
                    id: user.id,
                    name: nameController.text.trim(),
                    email: user.email,
                    role: user.role,
                  );
                  await ref
                      .read(userRepositoryProvider)
                      .updateUser(updatedUser);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating name: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Security Settings',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D47A1),
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.lock, color: Color(0xFF0D47A1)),
              title: Text('Change Password'),
              subtitle: Text('Update your account password'),
            ),
            ListTile(
              leading: Icon(Icons.security, color: Color(0xFF0D47A1)),
              title: Text('Two-Factor Authentication'),
              subtitle: Text('Add an extra layer of security'),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Color(0xFF0D47A1)),
              title: Text('Login History'),
              subtitle: Text('View recent login activity'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D47A1),
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.help, color: Color(0xFF0D47A1)),
              title: Text('FAQ'),
              subtitle: Text('Frequently asked questions'),
            ),
            ListTile(
              leading: Icon(Icons.contact_support, color: Color(0xFF0D47A1)),
              title: Text('Contact Support'),
              subtitle: Text('Get help from our support team'),
            ),
            ListTile(
              leading: Icon(Icons.feedback, color: Color(0xFF0D47A1)),
              title: Text('Send Feedback'),
              subtitle: Text('Share your thoughts with us'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D47A1),
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF0D47A1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
