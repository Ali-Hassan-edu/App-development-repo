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
  final _pass = TextEditingController();

  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _shop.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final shop = _shop.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    if (shop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter shop name')));
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid email')));
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be 6+ chars')));
      return;
    }

    setState(() => _loading = true);
    final err = await context.read<AuthProvider>().signup(email, pass, shop);
    setState(() => _loading = false);

    if (!mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 4),
                const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ).animate().fadeIn(duration: 240.ms),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 10))],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _shop,
                    decoration: InputDecoration(
                      labelText: 'Shop Name',
                      prefixIcon: const Icon(Icons.storefront),
                      filled: true,
                      fillColor: const Color(0xFFF6F7FB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF6F7FB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pass,
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CC5FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _loading ? null : _signup,
                      child: _loading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                          : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 360.ms).slideY(begin: .10),
          ],
        ),
      ),
    );
  }
}
