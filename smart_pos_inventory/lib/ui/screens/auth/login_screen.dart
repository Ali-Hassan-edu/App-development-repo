import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../state/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final err = await context.read<AuthProvider>().login(
      _email.text.trim(),
      _password.text.trim(),
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    final err = await context.read<AuthProvider>().loginWithGoogle();
    setState(() => _loading = false);

    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email first')),
      );
      return;
    }

    final msg = await context.read<AuthProvider>().resetPassword(email);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg ?? 'Reset link sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Column(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6D5DF6).withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(Icons.point_of_sale, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Smart POS',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Inventory • Billing • Reports',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                ),
              ],
            ).animate().fadeIn(duration: 320.ms).slideY(begin: .18),

            const SizedBox(height: 22),

            const Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
            ).animate().fadeIn(duration: 380.ms).slideY(begin: .12),

            const SizedBox(height: 6),

            const Text(
              'Sign in to manage your store & inventory',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
            ).animate().fadeIn(duration: 450.ms),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF6F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CC5FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                          : const Text(
                        'Log In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ✅ GOOGLE BUTTON
                  _SocialTile(
                    title: 'Continue with Google',
                    subtitle: 'Fast & secure sign-in',
                    colors: const [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                    icon: Icons.g_mobiledata,
                    onTap: _loading ? null : _google,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 520.ms).slideY(begin: .10),

            const SizedBox(height: 14),

            Center(
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.signup), // ✅ works now
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ).animate().fadeIn(duration: 650.ms),
          ],
        ),
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback? onTap;

  const _SocialTile({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: colors),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).scale(begin: const Offset(.98, .98));
  }
}
