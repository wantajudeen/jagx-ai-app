import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      _token.text = p.getString('jx_gh_token') ?? '';
      _owner.text = p.getString('jx_gh_owner') ?? '';
      _repo.text = p.getString('jx_gh_repo') ?? '';
      _saved = _token.text.isNotEmpty;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('jx_gh_token', _token.text.trim());
    await p.setString('jx_gh_owner', _owner.text.trim());
    await p.setString('jx_gh_repo', _repo.text.trim());
    setState(() => _saved = _token.text.trim().isNotEmpty);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GitHub connection saved on this device'),
          backgroundColor: Jx.card,
        ),
      );
    }
  }

  Future<void> _clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('jx_gh_token');
    await p.remove('jx_gh_owner');
    await p.remove('jx_gh_repo');
    setState(() {
      _token.clear();
      _owner.clear();
      _repo.clear();
      _saved = false;
    });
  }

  @override
  void dispose() {
    _token.dispose();
    _owner.dispose();
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(
        title: const Text('Connect GitHub'),
        backgroundColor: Jx.bg,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'So Rex (GitHub agent) can work with your repos, create a Personal Access Token and paste it here. Token stays on this phone only.',
            style: TextStyle(color: Jx.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          const SelectableText(
            'Create token: https://github.com/settings/tokens/new',
            style: TextStyle(color: Jx.accentSoft, fontSize: 13),
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
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off,
                    color: Jx.muted),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _owner,
            style: const TextStyle(color: Jx.text),
            decoration: const InputDecoration(labelText: 'Owner / org'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _repo,
            style: const TextStyle(color: Jx.text),
            decoration: const InputDecoration(labelText: 'Repo name'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: Jx.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save on this device'),
          ),
          if (_saved) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clear,
              child: const Text('Clear connection',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ],
      ),
    );
  }
}
