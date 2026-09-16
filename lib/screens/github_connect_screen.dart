import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';

/// Users paste a classic PAT so Rex (GitHub agent) can act on their repos.
class GithubConnectScreen extends StatefulWidget {
  const GithubConnectScreen({super.key});

  @override
  State<GithubConnectScreen> createState() => _GithubConnectScreenState();
}

class _GithubConnectScreenState extends State<GithubConnectScreen> {
  final _token = TextEditingController();
  final _owner = TextEditingController();
  final _repo = TextEditingController();
  bool _saved = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _token.text = p.getString('gh_token') ?? '';
      _owner.text = p.getString('gh_owner') ?? '';
      _repo.text = p.getString('gh_repo') ?? '';
      _saved = (_token.text).isNotEmpty;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('gh_token', _token.text.trim());
    await p.setString('gh_owner', _owner.text.trim());
    await p.setString('gh_repo', _repo.text.trim());
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GitHub connected on this device'),
          backgroundColor: Jx.card,
        ),
      );
    }
  }

  Future<void> _clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('gh_token');
    await p.remove('gh_owner');
    await p.remove('gh_repo');
    _token.clear();
    setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(title: const Text('Connect GitHub')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'So Rex (GitHub agent) can push like a teammate, create a Personal Access Token and paste it here. Token stays on this phone only.',
            style: TextStyle(color: Jx.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/settings/tokens/new'),
              mode: LaunchMode.externalApplication,
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Jx.border),
              foregroundColor: Jx.text,
            ),
            child: const Text('Open GitHub → create token'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scopes: repo (full control of private repositories)',
            style: TextStyle(color: Jx.dim, fontSize: 12),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _token,
            obscureText: _obscure,
            style: const TextStyle(color: Jx.text),
            decoration: InputDecoration(
              labelText: 'Personal access token',
              labelStyle: const TextStyle(color: Jx.muted),
              filled: true,
              fillColor: Jx.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    color: Jx.dim),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _owner,
            style: const TextStyle(color: Jx.text),
            decoration: InputDecoration(
              labelText: 'Username / org',
              hintText: 'wantajudeen',
              labelStyle: const TextStyle(color: Jx.muted),
              hintStyle: const TextStyle(color: Jx.dim),
              filled: true,
              fillColor: Jx.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _repo,
            style: const TextStyle(color: Jx.text),
            decoration: InputDecoration(
              labelText: 'Default repo',
              hintText: 'jagx-ai-app',
              labelStyle: const TextStyle(color: Jx.muted),
              hintStyle: const TextStyle(color: Jx.dim),
              filled: true,
              fillColor: Jx.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Jx.accent,
              foregroundColor: Colors.black,
            ),
            child: Text(_saved ? 'Update connection' : 'Save connection'),
          ),
          if (_saved)
            TextButton(
              onPressed: _clear,
              child: const Text('Disconnect',
                  style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
    );
  }
}
