import 'package:flutter/material.dart';

/// Permission service - requests handled natively via AndroidManifest.xml
/// No external permission plugin required
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  Future<void> requestAllPermissions() async {
    // Android handles notification permission via system dialog automatically
    // on Android 13+ when FCM initializes
  }

  Future<bool> isNotificationGranted() async {
    return true; // Managed by system
  }

  /// Show informational dialog about app notifications (no plugin needed)
  Future<void> showPermissionDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF0D47A1)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Enable Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D47A1),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Manager will notify you about:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            SizedBox(height: 12),
            _PermissionItem(
              icon: Icons.assignment_ind,
              text: 'New tasks assigned to you',
            ),
            SizedBox(height: 8),
            _PermissionItem(
              icon: Icons.check_circle_outline,
              text: 'Task completion confirmations',
            ),
            SizedBox(height: 8),
            _PermissionItem(
              icon: Icons.photo_library,
              text: 'Photos & Camera for profile picture',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PermissionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D47A1)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
