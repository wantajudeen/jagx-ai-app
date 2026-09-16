import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Jx.bg,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Jx.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Jx.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Jx.accent,
                  child: Text(
                    (_name.isNotEmpty ? _name : 'J')[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name.isEmpty ? 'JagX User' : _name,
                          style: const TextStyle(
                              color: Jx.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(_email,
                          style: const TextStyle(color: Jx.muted, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/onboarding'),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('App',
                style: TextStyle(
                    color: Jx.dim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          _tile(Icons.link, 'Connectors', () => context.push('/connectors')),
          _tile(Icons.code, 'Connect GitHub', () => context.push('/github')),
          _tile(Icons.workspace_premium_outlined, 'Premium',
              () => context.push('/premium')),
          _tile(Icons.delete_outline, 'Clear chat history', _clearHistory),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Legal',
                style: TextStyle(
                    color: Jx.dim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          _tile(Icons.description_outlined, 'Terms & Privacy',
              () => context.push('/terms')),
          const Divider(color: Jx.border, height: 32),
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
              child: Text('JagX AI · 2.5.0 · JagX & JRILICENSE',
                  style: TextStyle(color: Jx.dim, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Jx.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Jx.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: Jx.muted),
        title: Text(title, style: const TextStyle(color: Jx.text)),
        trailing: const Icon(Icons.chevron_right, color: Jx.dim),
        onTap: onTap,
      ),
    );
  }
}
