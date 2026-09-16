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

  Future<void> _sendCode() async {
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
      setState(() => _error =
          'Could not send code. Check SUPABASE_URL / ANON_KEY and Email provider.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final email = _email.text.trim();
    final token = _otp.text.trim();
    if (token.length < 6) {
      setState(() => _error = 'Enter the 6-digit code from your email');
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
      setState(() => _error = 'Invalid or expired code. Request a new one.');
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
          'OAuth failed. Enable Google / X in Supabase and set redirect URL.');
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
                _sent
                    ? 'Enter the code we emailed you'
                    : 'Sign in with email code',
                style: const TextStyle(fontSize: 16, color: Jx.muted),
              ),
              const SizedBox(height: 28),
              _oauthBtn('Continue with Google', Icons.g_mobiledata,
                  () => _oauth(OAuthProvider.google)),
              const SizedBox(height: 12),
              _oauthBtn(
                  'Continue with X', Icons.close, () => _oauth(OAuthProvider.twitter)),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider(color: Jx.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or email code', style: TextStyle(color: Jx.dim)),
                  ),
                  Expanded(child: Divider(color: Jx.border)),
                ],
              ),
              const SizedBox(height: 20),
              if (!_sent) ...[
                TextField(
                  controller: _name,
                  style: const TextStyle(color: Jx.text),
                  decoration: _dec('Name (optional)', 'Taju'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Jx.text),
                  decoration: _dec('Email', 'you@example.com'),
                ),
              ] else ...[
                Text(
                  _email.text,
                  style: const TextStyle(color: Jx.muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: Jx.text, letterSpacing: 4, fontSize: 20),
                  decoration: _dec('6-digit code', '000000'),
                ),
              ],
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
                  onPressed: _loading
                      ? null
                      : (_sent ? _verifyCode : _sendCode),
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
                          _sent ? 'Verify code' : 'Send code',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                ),
              ),
              if (_sent) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _sent = false;
                              _otp.clear();
                              _error = null;
                            }),
                    child: const Text('Use a different email',
                        style: TextStyle(color: Jx.muted)),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : _sendCode,
                    child: const Text('Resend code',
                        style: TextStyle(color: Jx.muted)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
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
      );

  Widget _oauthBtn(String label, IconData icon, VoidCallback onTap) {
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
}
