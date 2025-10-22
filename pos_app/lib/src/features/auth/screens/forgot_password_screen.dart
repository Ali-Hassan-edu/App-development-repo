import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/repo/user_repo.dart';
import '../../../core/router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _sending = false;

  /// Generates a random 6-digit OTP
  String _generateOtp() {
    final rnd = Random.secure();
    return (100000 + rnd.nextInt(900000)).toString();
  }

  /// Optional helper for Pakistan-style number formatting
  String _normalizePk(String raw) {
    var r = raw.replaceAll(RegExp(r'\s+'), '');
    if (r.startsWith('+')) return r;
    if (r.startsWith('0') && r.length >= 11) {
      return '+92${r.substring(1)}';
    }
    return r;
  }

  Future<void> _sendOtp() async {
    String phone = _phoneCtrl.text.trim();
    final username = _usernameCtrl.text.trim();

    if (phone.isEmpty && username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a username or phone number')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      // ✅ use the same database as UserRepo
      final db = await UserRepo.database;

      // ✅ Find user by username OR phone
      final users = await db.query(
        'users',
        where: 'phone = ? OR username = ?',
        whereArgs: [phone, username],
        limit: 1,
      );

      if (users.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found with this username or phone')),
        );
        return;
      }

      final user = users.first;
      final actualPhone = (user['phone'] ?? '').toString();
      final actualUsername = (user['username'] ?? '').toString();

      // ✅ Ensure password_resets table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS password_resets (
          phone TEXT PRIMARY KEY,
          otp TEXT,
          expires_at TEXT
        )
      ''');

      // ✅ Create and store OTP
      final otp = _generateOtp();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10)).toIso8601String();

      await db.insert(
        'password_resets',
        {'phone': actualPhone, 'otp': otp, 'expires_at': expiresAt},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // ✅ Always show OTP dialog in case SMS fails
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Your OTP Code'),
          content: SelectableText(
            '$otp\n\n(Valid for 10 minutes)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // ✅ Try to open the SMS composer (user must hit send)
      final dest = _normalizePk(phone.isEmpty ? actualPhone : phone);
      final body = Uri.encodeComponent('Your POS OTP is $otp (valid 10 minutes).');
      final uri = Uri.parse('sms:$dest?body=$body');

      try {
        final launched = await canLaunchUrl(uri) && await launchUrl(uri);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open SMS app. Use the OTP shown above.')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open SMS app. Use the OTP shown above.')),
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP generated successfully!')),
      );

      // ✅ Move to Reset Password screen
      Navigator.pushNamed(context, AppRouter.reset, arguments: {
        'phone': actualPhone,
        'username': actualUsername,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [s.primary, s.secondary]),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter your username or phone number to receive an OTP',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _sending ? null : _sendOtp,
                      icon: const Icon(Icons.sms),
                      label: _sending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Send OTP'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
