import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/mcp_catalog.dart';
import '../core/theme.dart';

class ConnectorsScreen extends StatefulWidget {
  const ConnectorsScreen({super.key});

  @override
  State<ConnectorsScreen> createState() => _ConnectorsScreenState();
}

class _ConnectorsScreenState extends State<ConnectorsScreen> {
  final _search = TextEditingController();
  String _q = '';
  String _cat = 'All';
  /// id -> {url, auth, name, enabled}
  Map<String, Map<String, dynamic>> _connected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('jx_mcp_connected');
    if (raw != null && raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        setState(() {
          _connected = m.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
        });
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('jx_mcp_connected', jsonEncode(_connected));
  }

  Future<void> _connect(McpItem item) async {
    final url = item.url;
    setState(() {
      _connected[item.id] = {
        'name': item.name,
        'url': url ?? '',
        'auth': item.auth,
        'enabled': true,
        'remote': item.remote,
        'blurb': item.blurb,
      };
    });
    await _save();
    if (!mounted) return;

    if (item.id == 'github') {
      context.push('/github');
      return;
    }

    if (url != null && url.isNotEmpty) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Jx.card,
          title: Text('Connect ${item.name}',
              style: const TextStyle(color: Jx.text)),
          content: Text(
            item.auth == 'none'
                ? 'Remote MCP:\n$url\n\nNo login required for this server.'
                : 'Remote MCP:\n$url\n\nAuth: ${item.auth.toUpperCase()}\n\n'
                    'JagX stores this endpoint on your device. '
                    'For OAuth servers, open the URL in a browser to authorize, '
                    'then return here. Never paste production secrets.',
            style: const TextStyle(color: Jx.muted, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Done'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open URL'),
            ),
          ],
        ),
      );
      if (open == true) {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} enabled. '
            '${item.auth == 'api_key' ? 'Add your API key in Vault when ready.' : 'Uses JagX backend tools where available.'}',
          ),
        ),
      );
    }
  }

  Future<void> _disconnect(String id) async {
    setState(() => _connected.remove(id));
    await _save();
  }

  Future<void> _addCustom() async {
    final nameC = TextEditingController();
    final urlC = TextEditingController(text: 'https://');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Jx.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Custom MCP server',
                  style: TextStyle(
                      color: Jx.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text(
                'Paste a remote MCP URL (Streamable HTTP). Only add servers you trust.',
                style: TextStyle(color: Jx.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameC,
                style: const TextStyle(color: Jx.text),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlC,
                style: const TextStyle(color: Jx.text),
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'https://example.com/mcp',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Add Connector'),
              ),
            ],
          ),
        );
      },
    );
    if (ok != true) return;
    final name = nameC.text.trim();
    final url = urlC.text.trim();
    if (name.isEmpty || !url.startsWith('http')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name and a valid https URL')),
      );
      return;
    }
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _connected[id] = {
        'name': name,
        'url': url,
        'auth': 'unknown',
        'enabled': true,
        'remote': true,
        'blurb': 'Custom MCP',
      };
    });
    await _save();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var list = McpCatalog.search(_q);
    if (_cat != 'All') {
      list = list.where((e) => e.category == _cat).toList();
    }
    final connectedIds = _connected.keys.toSet();
    final connectedItems =
        list.where((e) => connectedIds.contains(e.id)).toList();
    final available =
        list.where((e) => !connectedIds.contains(e.id)).toList();
    // custom-only
    final customs = _connected.entries
        .where((e) => e.key.startsWith('custom_'))
        .toList();

    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(
        title: const Text('Connectors'),
        actions: [
          IconButton(
            tooltip: 'Add custom MCP URL',
            onPressed: _addCustom,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const Text(
            'Connect remote MCP servers (like Grok connectors). '
            'Verified remote URLs open for OAuth where required. '
            'JagX built-in tools work without extra keys.',
            style: TextStyle(color: Jx.muted, height: 1.45, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _q = v),
            style: const TextStyle(color: Jx.text),
            decoration: const InputDecoration(
              hintText: 'Search 100+ connectors…',
              prefixIcon: Icon(Icons.search, color: Jx.dim),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip('All'),
                ...McpCatalog.categories.map(_chip),
              ],
            ),
          ),
          if (connectedItems.isNotEmpty || customs.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Connected',
                style: TextStyle(
                    color: Jx.dim, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...connectedItems.map((e) => _tile(e, connected: true)),
            ...customs.map((e) => _customTile(e.key, e.value)),
          ],
          const SizedBox(height: 20),
          Text(
            'Available (${available.length})',
            style: const TextStyle(
                color: Jx.dim, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...available.map((e) => _tile(e, connected: false)),
        ],
      ),
    );
  }

  Widget _chip(String c) {
    final on = _cat == c;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(c, style: TextStyle(fontSize: 12, color: on ? Colors.black : Jx.muted)),
        selected: on,
        selectedColor: Colors.white,
        backgroundColor: Jx.card,
        onSelected: (_) => setState(() => _cat = c),
      ),
    );
  }

  Widget _tile(McpItem e, {required bool connected}) {
    final badge = e.remote
        ? 'Remote MCP'
        : (e.id.startsWith('jagx_') ? 'JagX built-in' : 'Needs setup');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Jx.card,
        borderRadius: BorderRadius.circular(14),
        border: e.priority
            ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Row(
          children: [
            Expanded(
              child: Text(e.name,
                  style: const TextStyle(
                      color: Jx.text, fontWeight: FontWeight.w600)),
            ),
            if (e.priority)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text('★',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(e.blurb,
                style: const TextStyle(color: Jx.muted, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '$badge · ${e.category}'
              '${e.url != null ? ' · ${e.auth}' : ''}',
              style: const TextStyle(color: Jx.dim, fontSize: 11),
            ),
          ],
        ),
        trailing: connected
            ? IconButton(
                icon: const Icon(Icons.link_off, color: Jx.muted),
                onPressed: () => _disconnect(e.id),
              )
            : TextButton(
                onPressed: () => _connect(e),
                child: const Text('Connect',
                    style: TextStyle(color: Color(0xFFD4AF37))),
              ),
        onLongPress: e.url != null
            ? () {
                Clipboard.setData(ClipboardData(text: e.url!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('MCP URL copied')),
                );
              }
            : null,
      ),
    );
  }

  Widget _customTile(String id, Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Jx.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(m['name']?.toString() ?? 'Custom',
            style: const TextStyle(
                color: Jx.text, fontWeight: FontWeight.w600)),
        subtitle: Text(m['url']?.toString() ?? '',
            style: const TextStyle(color: Jx.dim, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.link_off, color: Jx.muted),
          onPressed: () => _disconnect(id),
        ),
      ),
    );
  }
}
