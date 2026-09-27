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
  final _otp = TextEditingController();
  final _name = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String? _error;

  bool get _hasSupabase {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _afterLogin() async {
    final need = await Profile.needsOnboarding();
    if (!mounted) return;
    context.go(need ? '/onboarding' : '/chat');
  }

  Future<void> _guest() async {
    await Profile.save(name: _name.text.trim().isEmpty ? 'Friend' : _name.text.trim(), dob: '');
    if (!mounted) return;
    context.go('/chat');
  }

  Future<void> _sendCode() async {
    if (!_hasSupabase) {
      await _guest();
      return;
    }
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
      setState(() => _sent = true);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not send code. Continue as guest or check Supabase.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final email = _email.text.trim();
    final token = _otp.text.trim();
    if (token.length < 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      if (_name.text.trim().isNotEmpty) {
        await Profile.save(name: _name.text.trim(), dob: '');
      }
      await _afterLogin();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Invalid or expired code.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'J',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Understand\nthe universe.',
              style: TextStyle(
                color: Jx.text,
                fontSize: 36,
                height: 1.05,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'JagX AI — built by JagX & JRILICENSE',
              style: TextStyle(color: Jx.muted, fontSize: 15),
            ),
            const SizedBox(height: 36),
            if (!_sent) ...[
              TextField(
                controller: _name,
                style: const TextStyle(color: Jx.text),
                decoration: const InputDecoration(
                  hintText: 'Name (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Jx.text),
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
            ] else ...[
              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Jx.text, letterSpacing: 6),
                decoration: const InputDecoration(
                  hintText: '6-digit code',
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Jx.danger, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _loading ? null : (_sent ? _verifyCode : _sendCode),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        _sent ? 'Verify code' : 'Continue',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Jx.text,
                  side: const BorderSide(color: Jx.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _loading ? null : _guest,
                child: const Text(
                  'Continue as guest',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.push('/terms'),
                  child: const Text('Terms of Service', style: TextStyle(color: Jx.muted, fontSize: 13)),
                ),
                const Text('·', style: TextStyle(color: Jx.dim)),
                TextButton(
                  onPressed: () => context.push('/privacy'),
                  child: const Text('Privacy Policy', style: TextStyle(color: Jx.muted, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'By continuing you agree to JagX Terms and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Jx.dim, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
