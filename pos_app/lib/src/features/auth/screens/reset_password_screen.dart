import 'package:flutter/material.dart';
import '../../auth/repo/user_repo.dart';
import '../../../core/router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String? _argPhone;
  String? _argUsername;

  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _argPhone = args['phone'] as String?;
      _argUsername = args['username'] as String?;
      if ((_argPhone ?? '').isNotEmpty && _phoneCtrl.text.isEmpty) {
        _phoneCtrl.text = _argPhone!;
      }
    }
  }

  Future<void> _reset() async {
    final phone = _phoneCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    final newPass = _passCtrl.text;

    if (phone.isEmpty || otp.isEmpty || newPass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter phone, valid OTP, and a 4+ char password')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final db = await UserRepo.database;

      await db.execute('''
        CREATE TABLE IF NOT EXISTS password_resets (
          phone TEXT PRIMARY KEY,
          otp TEXT,
          expires_at TEXT
        )
      ''');

      final rows = await db.query('password_resets', where: 'phone = ?', whereArgs: [phone], limit: 1);
      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No OTP requested for this phone. Please request again.')),
        );
        return;
      }

      final savedOtp = (rows.first['otp'] ?? '').toString();
      final expiresRaw = (rows.first['expires_at'] ?? '').toString();
      DateTime? expiresAt;
      try { expiresAt = DateTime.parse(expiresRaw); } catch (_) {}

      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP expired. Please request a new one.')));
        return;
      }

      if (savedOtp != otp) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP.')));
        return;
      }

      final users = await db.query('users', where: 'phone = ?', whereArgs: [phone], limit: 1);
      if (users.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user found for this phone number.')));
        return;
      }

      await UserRepo.updatePasswordByPhone(phone: phone, newPassword: newPass);
      await db.delete('password_resets', where: 'phone = ?', whereArgs: [phone]);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated. Please login.')));
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (r) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [s.primary, s.tertiary])),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((_argUsername ?? '').isNotEmpty || (_argPhone ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('Reset for: ${_argUsername ?? ''} ${(_argPhone ?? '').isNotEmpty ? '($_argPhone)' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone))),
                    const SizedBox(height: 10),
                    TextField(controller: _otpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP Code', prefixIcon: Icon(Icons.password))),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _loading ? null : _reset,
                      icon: const Icon(Icons.lock_reset),
                      label: _loading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Reset Password'),
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
