import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/ai.dart';
import '../core/models.dart';
import '../core/theme.dart';

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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _send([String? override]) async {
    var text = (override ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;

    if (_model.comingSoon) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oracle is Coming soon'),
          backgroundColor: Jx.card,
        ),
      );
      return;
    }

    final tab = _tabs.index;
    if (tab == 1) text = 'Generate image or creative visual: $text';
    if (tab == 2) {
      text = 'Build this app or site with complete code: $text';
      _model = Models.byId('jagx-0.4');
    }

    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
      _loading = true;
      _streaming = '';
    });
    _scrollDown();

    final history = _messages
        .map((m) => {
              'role': m.user ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    final reply = await Ai.chat(modelId: _model.id, messages: history);

    // Fake stream for feel
    var built = '';
    const step = 12;
    for (var i = 0; i < reply.length; i += step) {
      built = reply.substring(0, (i + step).clamp(0, reply.length));
      setState(() => _streaming = built);
      await Future.delayed(const Duration(milliseconds: 12));
    }

    setState(() {
      _messages.add(_Msg(reply, false));
      _streaming = null;
      _loading = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
              trailing: m.badge != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Jx.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m.badge!,
                          style: const TextStyle(fontSize: 11, color: Jx.muted)),
                    )
                  : null,
              onTap: m.comingSoon
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Oracle is Coming soon'),
                          backgroundColor: Jx.card,
                        ),
                      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      drawer: _Drawer(
        onNew: () => setState(() {
          _messages.clear();
          _streaming = null;
        }),
      ),
      appBar: AppBar(
        titleSpacing: 0,
        title: TabBar(
          controller: _tabs,
          indicatorColor: Jx.accent,
          labelColor: Jx.text,
          unselectedLabelColor: Jx.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'Ask'),
            Tab(text: 'Imagine'),
            Tab(text: 'Build'),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: _pickModel,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Jx.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Jx.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _model.badge ?? _model.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Jx.text,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Jx.muted),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _streaming == null
                ? _Empty(onTap: _send, tab: _tabs.index)
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
                    IconButton(
                      icon: const Icon(Icons.add, color: Jx.muted),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Jx.text),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: _tabs.index == 0
                              ? 'Ask anything'
                              : _tabs.index == 1
                                  ? 'Describe an image...'
                                  : 'Describe the app to build...',
                          hintStyle: const TextStyle(color: Jx.dim),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickModel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Jx.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _model.badge ?? 'Fast',
                          style: const TextStyle(fontSize: 11, color: Jx.muted),
                        ),
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
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: msg.user ? Jx.card : Jx.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Jx.border),
        ),
        child: Text(
          msg.text,
          style: const TextStyle(color: Jx.text, fontSize: 15, height: 1.45),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onTap, required this.tab});
  final void Function(String) onTap;
  final int tab;

  List<String> get _tips {
    if (tab == 1) {
      return [
        'Lagos skyline at night',
        'Premium dark dashboard UI',
        'Logo for a Nigerian fintech',
      ];
    }
    if (tab == 2) {
      return [
        'JAMB prep Flutter app',
        'Simple e-commerce site',
        'Portfolio website',
      ];
    }
    return [
      'Draft a CV for a Flutter developer in Nigeria',
      'Explain SaaS pricing in Naira',
      'Write a fintech pitch outline',
      'Code a Riverpod counter',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        const Center(
          child: Text(
            'J',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Jx.dim,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            tab == 1
                ? 'Imagine anything.'
                : tab == 2
                    ? 'Build apps and sites.'
                    : 'Ask JagX AI anything.',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Jx.text,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'JagX 0.3 · 0.4 · Forge · Bot',
            style: TextStyle(color: Jx.dim, fontSize: 13),
          ),
        ),
        const SizedBox(height: 28),
        ..._tips.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onTap(t),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Jx.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Jx.border),
                ),
                child: Text(t, style: const TextStyle(color: Jx.muted)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({required this.onNew});
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    String email = 'JagX User';
    try {
      email = Supabase.instance.client.auth.currentUser?.email ?? email;
    } catch (_) {}

    return Drawer(
      backgroundColor: Jx.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Jx.accent,
                child: Text(
                  email[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(email,
                  style: const TextStyle(color: Jx.text, fontSize: 14),
                  overflow: TextOverflow.ellipsis),
              subtitle: const Text('JagX AI',
                  style: TextStyle(color: Jx.muted, fontSize: 12)),
            ),
            const Divider(color: Jx.border),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Jx.muted),
              title: const Text('New chat', style: TextStyle(color: Jx.text)),
              onTap: () {
                onNew();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined, color: Jx.muted),
              title: const Text('JagX Bot', style: TextStyle(color: Jx.text)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Jx.border,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('New',
                    style: TextStyle(fontSize: 10, color: Jx.muted)),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
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
          ],
        ),
      ),
    );
  }
}
