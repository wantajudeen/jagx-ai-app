import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/sandbox_api.dart';
import '../core/theme.dart';

/// Users paste a classic PAT so Bot can import/export their repos on the server.
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
  bool _busy = false;

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
    final token = _token.text.trim();
    if (token.isEmpty) return;
    setState(() => _busy = true);
    final p = await SharedPreferences.getInstance();
    await p.setString('jx_gh_token', token);
    await p.setString('jx_gh_owner', _owner.text.trim());
    await p.setString('jx_gh_repo', _repo.text.trim());

    // Also vault on server so sandbox/bot can import & export without retyping
    final vaultOk = await SandboxApi.saveGithubToken(token);

    if (!mounted) return;
    setState(() {
      _saved = true;
      _busy = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(vaultOk
            ? 'GitHub saved on device + server vault (token never returned)'
            : 'Saved on device. Server vault unavailable — redeploy backend if needed.'),
        backgroundColor: Jx.card,
      ),
    );
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
            'Paste a Personal Access Token so JagX Bot can import files from your repos, run them in the sandbox, and export changes back. Token is stored on this phone and in the server vault (never shown again).',
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
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: Jx.accent,
              foregroundColor: Colors.white,
            ),
            child: Text(_busy ? 'Saving…' : 'Save device + server vault'),
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
