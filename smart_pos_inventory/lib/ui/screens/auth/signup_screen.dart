import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../state/auth/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _shop = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _hide1 = true;
  bool _hide2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _shop.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_shop.text.trim().isEmpty ||
        !_email.text.contains('@') ||
        _password.text.length < 6 ||
        _password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    setState(() => _loading = true);
    final err = await context.read<AuthProvider>().signup(
      _email.text.trim(),
      _password.text.trim(),
      _shop.text.trim(),
    );
    setState(() => _loading = false);

    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            // BACK
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // HEADER CENTER
            Column(
              children: [
                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x336D5DF6),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(Icons.point_of_sale, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Smart POS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create your merchant account',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
              ],
            ).animate().fadeIn(duration: 320.ms).slideY(begin: .18),

            const SizedBox(height: 22),

            const Text(
              'Sign Up',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ).animate().fadeIn(duration: 380.ms),

            const SizedBox(height: 18),

            // CARD
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
                  _field(
                    controller: _shop,
                    label: 'Shop Name',
                    icon: Icons.storefront,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _email,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _password,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _hide1,
                    suffix: IconButton(
                      icon: Icon(_hide1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hide1 = !_hide1),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _confirm,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscure: _hide2,
                    suffix: IconButton(
                      icon: Icon(_hide2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hide2 = !_hide2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SAME COLOR AS LOGIN BUTTON ✅
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CC5FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _loading ? null : _signup,
                      child: _loading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                          : const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 520.ms).slideY(begin: .10),

            const SizedBox(height: 18),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Already have an account? Log in',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
