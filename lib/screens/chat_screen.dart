import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ai.dart';
import '../core/auth.dart';
import '../core/models.dart';
import '../core/profile.dart';
import '../core/theme.dart';
import '../widgets/empty_chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late TabController _tabs;
  JagxModel _model = Models.fast;
  final List<_Msg> _messages = [];
  bool _loading = false;
  String? _streaming;
  String? _hello;
  String _displayName = 'JagX User';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
    _loadMeta();
    _loadHistory();
  }

  Future<void> _loadMeta() async {
    final n = await Profile.name();
    final dn = await Auth.displayName();
    setState(() {
      _displayName = (n != null && n.isNotEmpty)
          ? n
          : (dn ?? 'JagX User');
      _hello = n == null || n.isEmpty
          ? '${Profile.greeting()}.'
          : '${Profile.greeting()}, $n.';
    });
  }

  Future<void> _loadHistory() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('jx_chat_history');
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      setState(() {
        _messages
          ..clear()
          ..addAll(list.map((e) => _Msg(
                e['text'] as String? ?? '',
                e['user'] as bool? ?? false,
              )));
      });
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'jx_chat_history',
      jsonEncode(
          _messages.map((m) => {'text': m.text, 'user': m.user}).toList()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _send([String? override]) async {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;
    if (_model.comingSoon) {
      _toast('Oracle is Coming soon');
      return;
    }

    final tab = _tabs.index; // 0 ask, 1 imagine, 2 build

    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
      _loading = true;
      _streaming = '';
    });
    _scrollDown();

    if (tab == 1 || _wantsImage(text)) {
      final url = await Ai.imagine(text);
      setState(() {
        _messages.add(_Msg('Image ready:\n$url', false));
        _streaming = null;
        _loading = false;
      });
      await _saveHistory();
      _scrollDown();
      return;
    }

    final history = _messages
        .map((m) => {
              'role': m.user ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    final modelId = tab == 2 ? 'forge' : _model.id;
    final reply = await Ai.chat(modelId: modelId, messages: history);

    var built = '';
    const step = 24;
    for (var i = 0; i < reply.length; i += step) {
      built = reply.substring(0, (i + step).clamp(0, reply.length));
      setState(() => _streaming = built);
      await Future.delayed(const Duration(milliseconds: 3));
    }

    setState(() {
      _messages.add(_Msg(reply, false));
      _streaming = null;
      _loading = false;
    });
    await _saveHistory();
    _scrollDown();
  }

  bool _wantsImage(String text) {
    final t = text.toLowerCase();
    return t.contains('imagine') ||
        t.contains('generate image') ||
        t.contains('draw ') ||
        t.contains('create an image');
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Jx.card),
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _pickModel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Jx.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text('Model',
                  style: TextStyle(
                      color: Jx.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
            ...Models.list.map((m) {
              final selected = m.id == _model.id;
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: selected ? Jx.cardHover : null,
                title: Text(m.name,
                    style: TextStyle(
                      color: m.comingSoon ? Jx.dim : Jx.text,
                      fontWeight: FontWeight.w600,
                    )),
                subtitle: Text(m.subtitle,
                    style: const TextStyle(color: Jx.muted, fontSize: 12)),
                trailing: selected
                    ? const Icon(Icons.check, color: Jx.accent)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (m.comingSoon) {
                    _toast('Oracle is Coming soon');
                  } else {
                    setState(() => _model = m);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _newChat() async {
    setState(() {
      _messages.clear();
      _streaming = null;
    });
    final p = await SharedPreferences.getInstance();
    await p.remove('jx_chat_history');
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    String? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Jx.muted, size: 22),
      title: Row(
        children: [
          Text(title, style: const TextStyle(color: Jx.text, fontSize: 15)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Jx.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      color: Jx.accentSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = _tabs.index;
    final chip = _model.badge ?? 'Fast';

    return Scaffold(
      backgroundColor: Jx.bg,
      drawer: Drawer(
        backgroundColor: Jx.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Jx.accent,
                      child: Text(
                        _displayName.isNotEmpty
                            ? _displayName[0].toUpperCase()
                            : 'J',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Jx.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Jx.dim),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/settings');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _drawerTile(
                      icon: Icons.bolt_outlined,
                      title: 'Automations',
                      onTap: () {
                        Navigator.pop(context);
                        _toast('Automations coming soon');
                      },
                    ),
                    _drawerTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'Library',
                      onTap: () {
                        Navigator.pop(context);
                        _toast('Saved chats stay on this device');
                      },
                    ),
                    _drawerTile(
                      icon: Icons.folder_outlined,
                      title: 'Projects',
                      onTap: () {
                        Navigator.pop(context);
                        _tabs.animateTo(2);
                      },
                    ),
                    _drawerTile(
                      icon: Icons.smart_toy_outlined,
                      title: 'JagX Bot',
                      badge: 'Agents',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/bot');
                      },
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Material(
                        color: Jx.accent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/premium');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'JagX Premium · Ask, Build, Bot',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Quick links',
                          style: TextStyle(
                              color: Jx.dim,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                    _drawerTile(
                      icon: Icons.hub_outlined,
                      title: 'Connectors',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/connectors');
                      },
                    ),
                    _drawerTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/settings');
                      },
                    ),
                    _drawerTile(
                      icon: Icons.edit_outlined,
                      title: 'New chat',
                      onTap: () {
                        Navigator.pop(context);
                        _newChat();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Jx.muted),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/settings');
                      },
                      icon: const Icon(Icons.settings_outlined, color: Jx.muted),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _newChat,
                      icon: const Icon(Icons.edit_outlined, color: Jx.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Jx.bg,
        titleSpacing: 0,
        title: TabBar(
          controller: _tabs,
          indicatorColor: Jx.accent,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Jx.text,
          unselectedLabelColor: Jx.muted,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'Ask'),
            Tab(text: 'Imagine'),
            Tab(text: 'Build'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Jx.muted),
            onPressed: _newChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _streaming == null
                ? EmptyChat(
                    mode: tab,
                    hello: _hello,
                    onPrompt: (s) {
                      _controller.text = s;
                      _send();
                    },
                  )
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: [
                      ..._messages.map((m) => _Bubble(m)),
                      if (_streaming != null)
                        _Bubble(_Msg(_streaming!, false), streaming: true),
                      if (_loading && _streaming == null)
                        const Padding(
                          padding: EdgeInsets.only(left: 8, top: 8),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Jx.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Jx.card,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Jx.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Jx.text, fontSize: 15),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: tab == 2
                              ? 'Describe what to build…'
                              : tab == 1
                                  ? 'Describe an image…'
                                  : 'Ask anything…',
                          hintStyle: const TextStyle(color: Jx.dim),
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickModel,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Jx.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Jx.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, size: 14, color: Jx.accent),
                            const SizedBox(width: 4),
                            Text(chip,
                                style: const TextStyle(
                                    fontSize: 12, color: Jx.muted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 6, bottom: 6),
                      child: Material(
                        color: _loading ? Jx.dim : Jx.accent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _loading ? null : () => _send(),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(Icons.arrow_upward_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  _Msg(this.text, this.user);
  final String text;
  final bool user;
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.msg, {this.streaming = false});
  final _Msg msg;
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        decoration: BoxDecoration(
          color: msg.user ? Jx.userBubble : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              msg.text,
              style: const TextStyle(color: Jx.text, fontSize: 15, height: 1.5),
            ),
            if (!msg.user && !streaming)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy, size: 15, color: Jx.dim),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: msg.text)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
