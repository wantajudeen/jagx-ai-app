import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth.dart';
import '../core/profile.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _name = '';
  String _email = '';
  bool _guest = true;
  bool _haptics = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await Profile.name();
    final e = await Auth.sessionEmail();
    final g = await Auth.isGuest();
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name = n ?? '';
      _email = e ?? '';
      _guest = g || (e == null || e.isEmpty);
      _haptics = p.getBool('jx_haptics') ?? true;
    });
  }

  Future<void> _clearHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('jx_chat_history');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Chat history cleared on this device'),
            backgroundColor: Jx.card),
      );
    }
  }

  Future<void> _signOut() async {
    await Auth.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Jx.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Jx.accent,
                  child: Text(
                    (_name.isNotEmpty ? _name : 'J')[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name.isEmpty ? 'JagX User' : _name,
                          style: const TextStyle(
                              color: Jx.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      Text(
                          _guest
                              ? 'Guest mode'
                              : (_email.isEmpty ? 'Signed in' : _email),
                          style: const TextStyle(color: Jx.muted, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Jx.dim),
                  onPressed: () => context.push('/onboarding'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _section('Preferences'),
          _card([
            _row(Icons.contrast, 'Appearance', 'Dark', () {}),
            SwitchListTile(
              secondary: const Icon(Icons.vibration, color: Jx.muted),
              title: const Text('Haptics', style: TextStyle(color: Jx.text)),
              value: _haptics,
              activeColor: Jx.accent,
              onChanged: (v) async {
                setState(() => _haptics = v);
                final p = await SharedPreferences.getInstance();
                await p.setBool('jx_haptics', v);
              },
            ),
            _row(Icons.language, 'App language', 'Follows chat language', () {}),
            _row(Icons.tune, 'Advanced', null, () {}),
          ]),
          const SizedBox(height: 18),
          _section('JagX'),
          _card([
            _row(Icons.hub_outlined, 'Connectors', null,
                () => context.push('/connectors')),
            _row(Icons.smart_toy_outlined, 'JagX Bot agents', null,
                () => context.push('/bot')),
            _row(Icons.code, 'Connect GitHub', null,
                () => context.push('/github')),
            _row(Icons.workspace_premium_outlined, 'Premium', null,
                () => context.push('/premium')),
          ]),
          const SizedBox(height: 18),
          _section('Account'),
          _card([
            if (_guest)
              _row(Icons.login, 'Sign in / Create account', null,
                  () => context.go('/auth'))
            else
              _row(Icons.logout, 'Sign out', _email, _signOut),
          ]),
          const SizedBox(height: 18),
          _section('Data & information'),
          _card([
            _row(Icons.delete_outline, 'Clear chat history', null, _clearHistory),
            _row(Icons.description_outlined, 'Terms of Use', null,
                () => context.push('/terms')),
            _row(Icons.lock_outline, 'Privacy Policy', null,
                () => context.push('/privacy')),
          ]),
          const SizedBox(height: 28),
          const Center(
            child: Text('JagX AI · 3.3.0 · JagX & JRILICENSE',
                style: TextStyle(color: Jx.dim, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(t,
            style: const TextStyle(
                color: Jx.dim, fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Jx.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      );

  Widget _row(IconData icon, String title, String? subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Jx.muted, size: 22),
      title: Text(title, style: const TextStyle(color: Jx.text)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(color: Jx.dim, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Jx.dim, size: 20),
      onTap: onTap,
    );
  }
}
