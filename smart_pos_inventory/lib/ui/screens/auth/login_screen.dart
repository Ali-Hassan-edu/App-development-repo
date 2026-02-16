import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../state/auth/auth_provider.dart';

// preload online providers after login
import '../../../state/products/product_provider.dart';
import '../../../state/customers/customer_provider.dart';
import '../../../state/categories/category_provider.dart';
import '../../../state/reports/report_provider.dart';

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

  // Updated Blue Color Palette
  static const Color primaryColor = Color(0xFF4F46E5); // Modern Indigo/Blue
  static const Color secondaryColor = Color(0xFF0F172A); // Deep Navy
  static const Color scaffoldBg = Color(0xFFF8FAFC); // Soft Slate
  static const Color inputFill = Color(0xFFF1F5F9); // Light Slate

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _preloadOnlineData() async {
    await Future.wait([
      context.read<ProductProvider>().load(),
      context.read<CustomerProvider>().load(),
      context.read<CategoryProvider>().load(),
      context.read<ReportProvider>().load(),
    ]);
  }

  Future<void> _login() async {
    setState(() => _loading = true);

    final err = await context.read<AuthProvider>().login(
      _email.text.trim(),
      _password.text.trim(),
    );

    if (!mounted) return;

    if (err != null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    try {
      await _preloadOnlineData();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    final err = await context.read<AuthProvider>().loginWithGoogle();
    if (!mounted) return;

    if (err != null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    try {
      await _preloadOnlineData();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
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
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
          children: [
            Column(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFF3730A3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Smart POS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: secondaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Inventory • Billing • Reports',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 320.ms).slideY(begin: .18),
            const SizedBox(height: 32),
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: secondaryColor,
              ),
            ).animate().fadeIn(duration: 380.ms).slideY(begin: .12),
            const SizedBox(height: 8),
            const Text(
              'Sign in to manage your store & inventory',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ).animate().fadeIn(duration: 450.ms),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _password,
                    obscureText: _hide,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hide ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : const Text(
                        'Log In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: const [
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _SocialTile(
                    title: 'Continue with Google',
                    subtitle: 'Secure merchant access',
                    iconBuilder: (_) => const GoogleGIcon(size: 24),
                    onTap: _loading ? null : _google,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 520.ms).slideY(begin: .10),

            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: _loading ? null : () => Navigator.pushNamed(context, AppRoutes.signup),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: "Sign up",
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
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
  final Widget Function(BuildContext) iconBuilder;
  final VoidCallback? onTap;

  const _SocialTile({
    required this.title,
    required this.subtitle,
    required this.iconBuilder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF8FAFC),
              ),
              child: Center(child: iconBuilder(context)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).scale(begin: const Offset(.98, .98));
  }
}

class GoogleGIcon extends StatelessWidget {
  final double size;
  const GoogleGIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.18;
    final r = (s - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: r);

    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round;

    p.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.20, 2.20, false, p);
    p.color = const Color(0xFFDB4437);
    canvas.drawArc(rect, 2.00, 0.85, false, p);
    p.color = const Color(0xFFF4B400);
    canvas.drawArc(rect, 2.85, 0.85, false, p);
    p.color = const Color(0xFF0F9D58);
    canvas.drawArc(rect, 3.70, 0.95, false, p);

    final barPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round..color = const Color(0xFF4285F4);
    final y = center.dy + r * 0.08;
    final x1 = center.dx + r * 0.10;
    final x2 = center.dx + r * 0.78;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}