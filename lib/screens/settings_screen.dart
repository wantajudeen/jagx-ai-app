import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await Profile.name();
    String e = '';
    try {
      e = Supabase.instance.client.auth.currentUser?.email ?? '';
    } catch (_) {}
    setState(() {
      _name = n ?? '';
      _email = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Jx.accent,
              child: Text(
                (_name.isNotEmpty ? _name : _email).isEmpty
                    ? 'J'
                    : (_name.isNotEmpty ? _name : _email)[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(_name.isEmpty ? 'JagX User' : _name,
                style: const TextStyle(color: Jx.text)),
            subtitle: Text(_email, style: const TextStyle(color: Jx.muted)),
            trailing: TextButton(
              onPressed: () => context.push('/onboarding'),
              child: const Text('Edit profile'),
            ),
          ),
          const Divider(color: Jx.border),
          _tile(Icons.link, 'Connectors', () => context.push('/connectors')),
          _tile(Icons.palette_outlined, 'Appearance', () {}),
          _tile(Icons.notifications_outlined, 'Notifications', () {}),
          _tile(Icons.security_outlined, 'Privacy', () {}),
          _tile(Icons.workspace_premium_outlined, 'Premium', () {}),
          _tile(Icons.help_outline, 'Help', () {}),
          const Divider(color: Jx.border),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign out',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
              if (context.mounted) context.go('/auth');
            },
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('JagX AI · 2.1.0',
                  style: TextStyle(color: Jx.dim, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Jx.muted),
      title: Text(title, style: const TextStyle(color: Jx.text)),
      trailing: const Icon(Icons.chevron_right, color: Jx.dim),
      onTap: onTap,
    );
  }
}
