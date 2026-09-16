import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/ai.dart';
import '../core/models.dart';
import '../core/profile.dart';
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
  String? _hello;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
    _loadHello();
  }

  Future<void> _loadHello() async {
    final n = await Profile.name();
    setState(() {
      _hello = n == null || n.isEmpty
          ? '${Profile.greeting()}.'
          : '${Profile.greeting()}, $n.';
    });
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
      _toast('Oracle is Coming soon');
      return;
    }

    final isImagine = _tabs.index == 1;

    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
      _loading = true;
      _streaming = isImagine ? null : '';
    });
    _scrollDown();

    if (isImagine) {
      final url = await Ai.imagine(text);
      setState(() {
        _messages.add(_Msg(
          url != null
              ? 'Here’s what I imagined.'
              : 'Couldn’t generate that image right now. Try again or rephrase.',
          false,
          imageUrl: url,
        ));
        _loading = false;
      });
      _scrollDown();
      return;
    }

    final history = _messages
        .where((m) => m.imageUrl == null)
        .map((m) => {
              'role': m.user ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    final reply = await Ai.chat(modelId: _model.id, messages: history);

    var built = '';
    const step = 14;
    for (var i = 0; i < reply.length; i += step) {
      built = reply.substring(0, (i + step).clamp(0, reply.length));
      setState(() => _streaming = built);
      await Future.delayed(const Duration(milliseconds: 10));
    }

    setState(() {
      _messages.add(_Msg(reply, false));
      _streaming = null;
      _loading = false;
    });
    _scrollDown();
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

  void _plusMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Jx.card,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Jx.muted),
              title: const Text('Imagine', style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                _tabs.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Jx.muted),
              title: const Text('Connectors', style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                context.push('/connectors');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Jx.muted),
              title: const Text('Code help', style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                _controller.text = 'Help me write code for: ';
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Jx.muted),
              title: const Text('Attach (soon)', style: TextStyle(color: Jx.dim)),
              onTap: () {
                Navigator.pop(context);
                _toast('File attach coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagine = _tabs.index == 1;

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
          ],
        ),
        actions: [
          if (!imagine)
            GestureDetector(
              onTap: _pickModel,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Jx.muted),
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
                ? _Empty(
                    onTap: _send,
                    imagine: imagine,
                    hello: _hello,
                  )
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: [
                      ..._messages.map((m) => _Bubble(m)),
                      if (_streaming != null)
                        _Bubble(_Msg(_streaming!, false), streaming: true),
                      if (_loading && imagine)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Jx.accent,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
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
                      onPressed: _plusMenu,
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
                          hintText: imagine
                              ? 'Describe an image…'
                              : 'Ask anything',
                          hintStyle: const TextStyle(color: Jx.dim),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (!imagine)
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
                            style: const TextStyle(
                                fontSize: 11, color: Jx.muted),
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
  _Msg(this.text, this.user, {this.imageUrl});
  final String text;
  final bool user;
  final String? imageUrl;
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
          color: msg.user ? Jx.card : Jx.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Jx.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  msg.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Jx.card,
                    child: const Center(
                      child: Text('Image unavailable',
                          style: TextStyle(color: Jx.muted)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SelectableText(
              msg.text,
              style: const TextStyle(
                  color: Jx.text, fontSize: 15, height: 1.45),
            ),
            if (!msg.user && !streaming)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Jx.dim),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: msg.text));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.onTap,
    required this.imagine,
    this.hello,
  });
  final void Function(String) onTap;
  final bool imagine;
  final String? hello;

  List<String> get _tips {
    if (imagine) {
      return [
        'A cinematic Lagos skyline at golden hour',
        'Minimal dark fintech app UI mockup',
        'Afrofuturist portrait, soft studio light',
        'Product shot of a sleek black phone',
      ];
    }
    return [
      'Draft a CV for a Flutter developer in Nigeria',
      'Explain SaaS pricing in Naira',
      'Write a fintech pitch outline',
      'Code a Riverpod counter with dark theme',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        if (!imagine && hello != null) ...[
          Text(
            hello!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Jx.muted,
            ),
          ),
          const SizedBox(height: 12),
        ],
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
            imagine ? 'What will you imagine?' : 'How can JagX help?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Jx.text,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            imagine
                ? 'Describe a scene, product, or style'
                : 'JagX 0.3 · 0.4 · Forge · Bot',
            style: const TextStyle(color: Jx.dim, fontSize: 13),
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
        child: ListView(
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
            _item(Icons.edit_outlined, 'New chat', () {
              onNew();
              Navigator.pop(context);
            }),
            _item(Icons.smart_toy_outlined, 'JagX Bot', () {
              Navigator.pop(context);
            }),
            _item(Icons.link, 'Connectors', () {
              Navigator.pop(context);
              context.push('/connectors');
            }),
            _item(Icons.image_outlined, 'Imagine', () {
              Navigator.pop(context);
            }),
            _item(Icons.code, 'Coding', () {
              Navigator.pop(context);
            }),
            _item(Icons.trending_up, 'Finance & markets', () {
              Navigator.pop(context);
            }),
            _item(Icons.business, 'Company builder', () {
              Navigator.pop(context);
            }),
            _item(Icons.translate, 'Translate / Pidgin', () {
              Navigator.pop(context);
            }),
            _item(Icons.school_outlined, 'Study & exams', () {
              Navigator.pop(context);
            }),
            _item(Icons.description_outlined, 'Docs & CV', () {
              Navigator.pop(context);
            }),
            _item(Icons.mic_none, 'Voice (soon)', () {
              Navigator.pop(context);
            }),
            _item(Icons.history, 'Chat history', () {
              Navigator.pop(context);
            }),
            _item(Icons.workspace_premium_outlined, 'Premium', () {
              Navigator.pop(context);
            }),
            _item(Icons.settings_outlined, 'Settings', () {
              Navigator.pop(context);
              context.push('/settings');
            }),
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

  Widget _item(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Jx.muted),
      title: Text(title, style: const TextStyle(color: Jx.text)),
      onTap: onTap,
    );
  }
}
