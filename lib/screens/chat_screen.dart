import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ai.dart';
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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
    _loadHello();
    _loadHistory();
  }

  Future<void> _loadHello() async {
    final n = await Profile.name();
    setState(() {
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
    final data = _messages
        .map((m) => {'text': m.text, 'user': m.user})
        .toList();
    await p.setString('jx_chat_history', jsonEncode(data));
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

    final isBuild = _tabs.index == 1;

    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
      _loading = true;
      _streaming = '';
    });
    _scrollDown();

    if (_wantsImage(text) && !isBuild) {
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

    var modelId = _model.id;
    if (isBuild) modelId = 'forge';

    final reply = await Ai.chat(modelId: modelId, messages: history);

    var built = '';
    const step = 16;
    for (var i = 0; i < reply.length; i += step) {
      built = reply.substring(0, (i + step).clamp(0, reply.length));
      setState(() => _streaming = built);
      await Future.delayed(const Duration(milliseconds: 6));
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
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: Models.list.map((m) {
            return ListTile(
              title: Text(m.name,
                  style: TextStyle(
                    color: m.comingSoon ? Jx.dim : Jx.text,
                    fontWeight: FontWeight.w600,
                  )),
              subtitle: Text(m.subtitle,
                  style: const TextStyle(color: Jx.muted, fontSize: 12)),
              onTap: m.comingSoon
                  ? () {
                      Navigator.pop(context);
                      _toast('Oracle is Coming soon');
                    }
                  : () {
                      setState(() => _model = m);
                      Navigator.pop(context);
                    },
            );
          }).toList(),
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

  @override
  Widget build(BuildContext context) {
    final mode = _tabs.index;
    final chip = _model.badge ?? _model.name;

    return Scaffold(
      backgroundColor: Jx.bg,
      drawer: Drawer(
        backgroundColor: Jx.surface,
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text('JagX AI',
                    style: TextStyle(
                        color: Jx.text, fontWeight: FontWeight.w700)),
                subtitle: Text('JagX & JRILICENSE',
                    style: TextStyle(color: Jx.muted)),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Jx.muted),
                title: const Text('New chat', style: TextStyle(color: Jx.text)),
                onTap: () {
                  Navigator.pop(context);
                  _newChat();
                },
              ),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined, color: Jx.muted),
                title: const Text('JagX Bot', style: TextStyle(color: Jx.text)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/bot');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Jx.muted),
                title: const Text('Settings', style: TextStyle(color: Jx.text)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/settings');
                },
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
          labelColor: Jx.text,
          unselectedLabelColor: Jx.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'Ask'),
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
                    mode: mode == 1 ? 2 : 0,
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
                    ],
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Jx.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Jx.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Jx.text),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: mode == 1
                              ? 'Describe what to build…'
                              : 'Ask anything…',
                          hintStyle: const TextStyle(color: Jx.dim),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickModel,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(chip,
                            style: const TextStyle(
                                fontSize: 12, color: Jx.muted)),
                      ),
                    ),
                    IconButton(
                      onPressed: _loading ? null : () => _send(),
                      icon: Icon(
                        Icons.arrow_upward_rounded,
                        color: _loading ? Jx.dim : Jx.accent,
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        decoration: BoxDecoration(
          color: msg.user ? Jx.userBubble : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              msg.text,
              style: const TextStyle(color: Jx.text, fontSize: 15, height: 1.45),
            ),
            if (!msg.user && !streaming)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Jx.dim),
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
