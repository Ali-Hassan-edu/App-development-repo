import 'package:flutter/material.dart';
import '../../auth/repo/user_repo.dart';
import '../../auth/persistence/session_store.dart';
import '../../../core/router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _remember = true;
  bool _loading = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [s.primary, s.tertiary], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                          validator: (v) => (v == null || v.trim().length < 5) ? 'Valid phone required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 4) ? 'Min 4 chars' : null,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _remember,
                          onChanged: (v) => setState(() => _remember = v ?? false),
                          title: const Text('Remember me'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          icon: const Icon(Icons.login),
                          label: _loading
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Login'),
                          onPressed: _loading
                              ? null
                              : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _loading = true);
                            final row = await UserRepo.login(
                              username: _usernameCtrl.text.trim(),
                              phone: _phoneCtrl.text.trim(),
                              password: _passwordCtrl.text,
                            );
                            if (!mounted) return;
                            if (row != null) {
                              await SessionStore().setRemembered(_remember);
                              Navigator.pushReplacementNamed(context, AppRouter.dashboard);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid username/phone/password')),
                              );
                            }
                            if (mounted) setState(() => _loading = false);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, AppRouter.forgot),
                              child: const Text('Forgot Password?'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.register),
                              child: const Text('Create account'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
