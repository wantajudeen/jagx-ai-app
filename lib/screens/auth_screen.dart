import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth.dart';
import '../core/profile.dart';
import '../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = _signUp
        ? await Auth.signUp(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          )
        : await Auth.signIn(
            email: _email.text,
            password: _password.text,
          );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    final need = await Profile.needsOnboarding();
    if (!mounted) return;
    context.go(need ? '/onboarding' : '/chat');
  }

  Future<void> _guest() async {
    await Auth.continueAsGuest();
    if (!mounted) return;
    final need = await Profile.needsOnboarding();
    if (!mounted) return;
    context.go(need ? '/onboarding' : '/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('J',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _signUp ? 'Create account' : 'Sign in',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Jx.text, fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'JagX AI · JagX & JRILICENSE',
              textAlign: TextAlign.center,
              style: TextStyle(color: Jx.muted),
            ),
            const SizedBox(height: 28),
            if (_signUp) ...[
              TextField(
                controller: _name,
                style: const TextStyle(color: Jx.text),
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _email,
              style: const TextStyle(color: Jx.text),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              style: const TextStyle(color: Jx.text),
              obscureText: _hide,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_hide ? Icons.visibility : Icons.visibility_off,
                      color: Jx.muted),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_signUp ? 'Create account' : 'Sign in'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _signUp = !_signUp;
                        _error = null;
                      }),
              child: Text(
                _signUp
                    ? 'Already have an account? Sign in'
                    : 'New here? Create an account',
                style: const TextStyle(color: Jx.muted),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _guest,
              child: const Text('Continue as guest',
                  style: TextStyle(color: Jx.text)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/privacy'),
              child: const Text('Privacy Policy',
                  style: TextStyle(color: Jx.dim, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
