import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';

class ConnectorsScreen extends StatefulWidget {
  const ConnectorsScreen({super.key});

  @override
  State<ConnectorsScreen> createState() => _ConnectorsScreenState();
}

class _ConnectorsScreenState extends State<ConnectorsScreen> {
  final Map<String, bool> _on = {};

  static const _items = [
    _Conn('github', 'GitHub', 'Repos, issues, PRs', Icons.code),
    _Conn('gmail', 'Gmail', 'Read & draft email', Icons.mail_outline),
    _Conn('drive', 'Google Drive', 'Files & docs', Icons.folder_outlined),
    _Conn('calendar', 'Calendar', 'Schedule & events', Icons.calendar_today),
    _Conn('notion', 'Notion', 'Notes & databases', Icons.note_outlined),
    _Conn('x', 'X (Twitter)', 'Posts & search', Icons.close),
    _Conn('slack', 'Slack', 'Workspace chat', Icons.chat_bubble_outline),
    _Conn('web', 'Web browser', 'Search the open web', Icons.language),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      for (final e in _items) {
        _on[e.id] = p.getBool('conn_${e.id}') ?? false;
      }
    });
  }

  Future<void> _toggle(String id, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('conn_$id', v);
    setState(() => _on[id] = v);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(v
              ? 'Connector enabled (tokens via Supabase / Settings)'
              : 'Connector off'),
          backgroundColor: Jx.card,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(title: const Text('Connectors')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Link tools JagX Bot can use. Full OAuth wiring comes next.',
            style: TextStyle(color: Jx.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          ..._items.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Jx.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Jx.border),
              ),
              child: SwitchListTile(
                secondary: Icon(e.icon, color: Jx.muted),
                title: Text(e.title, style: const TextStyle(color: Jx.text)),
                subtitle: Text(e.subtitle,
                    style: const TextStyle(color: Jx.dim, fontSize: 12)),
                value: _on[e.id] ?? false,
                activeThumbColor: Jx.accent,
                onChanged: (v) => _toggle(e.id, v),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Conn {
  const _Conn(this.id, this.title, this.subtitle, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
