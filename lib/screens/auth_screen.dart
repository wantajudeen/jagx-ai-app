import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/profile.dart';
import '../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _afterLogin() async {
    final need = await Profile.needsOnboarding();
    if (!mounted) return;
    context.go(need ? '/onboarding' : '/chat');
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password min 6 characters');
      return;
    }
    if (_register && _name.text.trim().isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      if (_register) {
        final res = await client.auth.signUp(
          email: email,
          password: password,
          data: {'name': _name.text.trim()},
        );
        if (res.session != null) {
          await Profile.save(
            name: _name.text.trim(),
            dob: '',
          );
          await _afterLogin();
          return;
        }
        setState(() {
          _error = 'Check your email to confirm, then sign in.';
          _register = false;
        });
      } else {
        await client.auth.signInWithPassword(email: email, password: password);
        await _afterLogin();
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error =
          'Auth failed. Check SUPABASE_URL and SUPABASE_ANON_KEY.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _oauth(OAuthProvider provider) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.jagxai://login-callback/',
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error =
          'OAuth failed. Enable Google / X in Supabase Providers.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                'JagX AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Jx.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _register ? 'Create account' : 'Sign in to continue',
                style: const TextStyle(fontSize: 16, color: Jx.muted),
              ),
              const SizedBox(height: 28),
              _oauthBtn(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata,
                onTap: () => _oauth(OAuthProvider.google),
              ),
              const SizedBox(height: 12),
              _oauthBtn(
                label: 'Continue with X',
                icon: Icons.close, // X mark style
                onTap: () => _oauth(OAuthProvider.twitter),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider(color: Jx.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: Jx.dim)),
                  ),
                  Expanded(child: Divider(color: Jx.border)),
                ],
              ),
              const SizedBox(height: 20),
              if (_register) ...[
                _field(_name, 'Name', 'Taju'),
                const SizedBox(height: 14),
              ],
              _field(_email, 'Email', 'you@example.com',
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 14),
              TextField(
                controller: _password,
                obscureText: _obscure,
                style: const TextStyle(color: Jx.text),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Jx.muted),
                  filled: true,
                  fillColor: Jx.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Jx.dim,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Jx.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          _register ? 'Create account' : 'Sign in',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _register = !_register;
                    _error = null;
                  }),
                  child: Text(
                    _register
                        ? 'Already have an account? Sign in'
                        : 'New here? Create account',
                    style: const TextStyle(color: Jx.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _oauthBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : onTap,
        icon: Icon(icon, color: Jx.text),
        label: Text(label, style: const TextStyle(color: Jx.text)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Jx.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint,
      {TextInputType? keyboard}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      style: const TextStyle(color: Jx.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Jx.muted),
        hintStyle: const TextStyle(color: Jx.dim),
        filled: true,
        fillColor: Jx.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
