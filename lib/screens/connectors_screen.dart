import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';

class ConnectorsScreen extends StatefulWidget {
  const ConnectorsScreen({super.key});

  @override
  State<ConnectorsScreen> createState() => _ConnectorsScreenState();
}

class _ConnectorsScreenState extends State<ConnectorsScreen> {
  final Map<String, bool> _on = {};
  final _search = TextEditingController();
  String _q = '';

  static const _items = [
    _Conn('github', 'GitHub', 'Repos, issues, PRs', Icons.code, true),
    _Conn('gmail', 'Gmail', 'Read & draft email', Icons.mail_outline, true),
    _Conn('drive', 'Google Drive', 'Files & docs', Icons.folder_outlined, true),
    _Conn('calendar', 'Google Calendar', 'Schedule & events', Icons.calendar_today, false),
    _Conn('notion', 'Notion', 'Notes & databases', Icons.note_outlined, true),
    _Conn('slack', 'Slack', 'Workspace chat', Icons.chat_bubble_outline, false),
    _Conn('x', 'X', 'Posts & search', Icons.close, false),
    _Conn('web', 'Web browser', 'Search the open web', Icons.language, true),
    _Conn('finance', 'Finance', 'Naira budgets & education', Icons.account_balance, false),
    _Conn('vercel', 'Vercel', 'Deploy previews', Icons.cloud_outlined, false),
    _Conn('figma', 'Figma', 'Design context', Icons.brush_outlined, false),
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
        _on[e.id] = p.getBool('conn_${e.id}') ?? e.featured;
      }
    });
  }

  Future<void> _toggle(String id, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('conn_$id', v);
    setState(() => _on[id] = v);
    if (id == 'github' && v && mounted) {
      context.push('/github');
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.toLowerCase();
    final filtered = _items
        .where((e) =>
            q.isEmpty ||
            e.title.toLowerCase().contains(q) ||
            e.subtitle.toLowerCase().contains(q))
        .toList();
    final connected = filtered.where((e) => _on[e.id] == true).toList();
    final rest = filtered.where((e) => _on[e.id] != true).toList();

    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(
        title: const Text('Connectors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const Text(
            'Connectors let JagX Bot use external tools and data sources.',
            style: TextStyle(color: Jx.muted, height: 1.4),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _q = v),
            style: const TextStyle(color: Jx.text),
            decoration: InputDecoration(
              hintText: 'Search connectors…',
              prefixIcon: const Icon(Icons.search, color: Jx.dim),
              filled: true,
              fillColor: Jx.card,
            ),
          ),
          if (connected.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Connected',
                style: TextStyle(
                    color: Jx.dim, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...connected.map(_tile),
          ],
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Available',
                style: TextStyle(
                    color: Jx.dim, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...rest.map(_tile),
          ],
        ],
      ),
    );
  }

  Widget _tile(_Conn e) {
    final on = _on[e.id] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Jx.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Jx.surface,
          child: Icon(e.icon, color: Jx.text, size: 20),
        ),
        title: Text(e.title,
            style: const TextStyle(color: Jx.text, fontWeight: FontWeight.w600)),
        subtitle: Text(e.subtitle,
            style: const TextStyle(color: Jx.muted, fontSize: 12)),
        trailing: on
            ? Switch(
                value: true,
                onChanged: (v) => _toggle(e.id, v),
                activeColor: Jx.accent,
              )
            : TextButton(
                onPressed: () => _toggle(e.id, true),
                child: const Text('Connect',
                    style: TextStyle(color: Jx.accentSoft)),
              ),
      ),
    );
  }
}

class _Conn {
  const _Conn(this.id, this.title, this.subtitle, this.icon, this.featured);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool featured;
}
