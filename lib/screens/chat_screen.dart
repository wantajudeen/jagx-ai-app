import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/agents.dart';
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
  Agent? _agent;
  final List<_Msg> _messages = [];
  bool _loading = false;
  String? _streaming;
  String? _hello;
  String? _attachedName;
  String? _attachedPath;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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
        _messages.clear();
        for (final e in list) {
          _messages.add(_Msg(
            e['text'] as String? ?? '',
            e['user'] as bool? ?? false,
            imageUrl: e['imageUrl'] as String?,
          ));
        }
      });
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    final p = await SharedPreferences.getInstance();
    final data = _messages
        .map((m) => {
              'text': m.text,
              'user': m.user,
              if (m.imageUrl != null) 'imageUrl': m.imageUrl,
            })
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

  Future<void> _pickFiles() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Jx.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Jx.muted),
              title: const Text('Photo library', style: TextStyle(color: Jx.text)),
              onTap: () async {
                Navigator.pop(context);
                final x = await ImagePicker()
                    .pickImage(source: ImageSource.gallery);
                if (x != null) {
                  setState(() {
                    _attachedPath = x.path;
                    _attachedName = x.name;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Jx.muted),
              title: const Text('Camera', style: TextStyle(color: Jx.text)),
              onTap: () async {
                Navigator.pop(context);
                final x =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (x != null) {
                  setState(() {
                    _attachedPath = x.path;
                    _attachedName = x.name;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined,
                  color: Jx.muted),
              title: const Text('Files', style: TextStyle(color: Jx.text)),
              onTap: () async {
                Navigator.pop(context);
                final r = await FilePicker.platform.pickFiles();
                if (r != null && r.files.single.path != null) {
                  setState(() {
                    _attachedPath = r.files.single.path;
                    _attachedName = r.files.single.name;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Jx.muted),
              title: const Text('Imagine', style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                _tabs.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Jx.muted),
              title:
                  const Text('Connect GitHub', style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                context.push('/github');
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
          ],
        ),
      ),
    );
  }

  Future<void> _send([String? override]) async {
    var text = (override ?? _controller.text).trim();
    if ((text.isEmpty && _attachedName == null) || _loading) return;

    if (_model.comingSoon) {
      _toast('Oracle is Coming soon');
      return;
    }

    final isImagine = _tabs.index == 1;
    final isBuild = _tabs.index == 2;

    if (_attachedName != null) {
      text = text.isEmpty
          ? 'I attached a file: $_attachedName. Help me with it.'
          : '$text\n\n[Attached: $_attachedName]';
    }

    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
      _attachedName = null;
      _attachedPath = null;
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
              : 'Couldn’t generate that image. Try again.',
          false,
          imageUrl: url,
        ));
        _loading = false;
      });
      await _saveHistory();
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

    var modelId = _model.id;
    if (isBuild) modelId = 'forge';

    final reply = await Ai.chat(
      modelId: modelId,
      messages: history,
      agentId: modelId == 'bot' ? _agent?.id : null,
    );

    var built = '';
    const step = 12;
    for (var i = 0; i < reply.length; i += step) {
      built = reply.substring(0, (i + step).clamp(0, reply.length));
      setState(() => _streaming = built);
      await Future.delayed(const Duration(milliseconds: 8));
    }

    setState(() {
      _messages.add(_Msg(reply, false));
      _streaming = null;
      _loading = false;
    });
    await _saveHistory();
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
                  ? Text(m.badge!,
                      style: const TextStyle(color: Jx.dim, fontSize: 11))
                  : null,
              onTap: m.comingSoon
                  ? () {
                      Navigator.pop(context);
                      _toast('Oracle is Coming soon');
                    }
                  : () {
                      setState(() {
                        _model = m;
                        if (m.id != 'bot') _agent = null;
                      });
                      Navigator.pop(context);
                      if (m.id == 'bot') _pickAgent();
                    },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _pickAgent() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Jx.card,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Choose agent',
                  style: TextStyle(
                      color: Jx.muted, fontWeight: FontWeight.w600)),
            ),
            ...Agents.list.map((a) {
              return ListTile(
                title: Text(a.name,
                    style: const TextStyle(
                        color: Jx.text, fontWeight: FontWeight.w600)),
                subtitle: Text(a.role,
                    style: const TextStyle(color: Jx.muted, fontSize: 12)),
                onTap: () {
                  setState(() => _agent = a);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = _tabs.index; // 0 ask 1 imagine 2 build
    final chip = _model.id == 'bot' && _agent != null
        ? _agent!.name
        : (_model.badge ?? _model.name);

    return Scaffold(
      backgroundColor: Jx.bg,
      drawer: _Drawer(
        onNew: () async {
          setState(() {
            _messages.clear();
            _streaming = null;
          });
          final p = await SharedPreferences.getInstance();
          await p.remove('jx_chat_history');
        },
      ),
      appBar: AppBar(
        backgroundColor: Jx.bg,
        titleSpacing: 0,
        title: TabBar(
          controller: _tabs,
          indicatorColor: Jx.accent,
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
            onPressed: () async {
              setState(() {
                _messages.clear();
                _streaming = null;
              });
              final p = await SharedPreferences.getInstance();
              await p.remove('jx_chat_history');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _streaming == null
                ? _Empty(
                    onTap: _send,
                    mode: mode,
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
                      if (_loading && mode == 1)
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
          if (_attachedName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Jx.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Jx.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16, color: Jx.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_attachedName!,
                          style:
                              const TextStyle(color: Jx.text, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Jx.dim),
                      onPressed: () => setState(() {
                        _attachedName = null;
                        _attachedPath = null;
                      }),
                    ),
                  ],
                ),
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
                      onPressed: _pickFiles,
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
                          hintText: mode == 1
                              ? 'Describe an image…'
                              : mode == 2
                                  ? 'Describe the app or site to build…'
                                  : 'Ask anything',
                          hintStyle: const TextStyle(color: Jx.dim),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (mode != 1)
                      GestureDetector(
                        onTap: _pickModel,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Jx.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt,
                                  size: 14, color: Jx.muted),
                              const SizedBox(width: 4),
                              Text(chip,
                                  style: const TextStyle(
                                      fontSize: 12, color: Jx.text)),
                              const Icon(Icons.keyboard_arrow_down,
                                  size: 14, color: Jx.dim),
                            ],
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

  Future<void> _shareImage(BuildContext context) async {
    final url = msg.imageUrl;
    if (url == null) return;
    try {
      final res = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/jagx_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(res.bodyBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Imagined with JagX AI');
    } catch (_) {}
  }

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
          color: msg.user ? Jx.card : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
              TextButton.icon(
                onPressed: () => _shareImage(context),
                icon: const Icon(Icons.download, size: 16, color: Jx.muted),
                label: const Text('Save / Share',
                    style: TextStyle(color: Jx.muted, fontSize: 12)),
              ),
            ],
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

class _Empty extends StatelessWidget {
  const _Empty({required this.onTap, required this.mode, this.hello});
  final void Function(String) onTap;
  final int mode;
  final String? hello;

  List<String> get _tips {
    if (mode == 1) {
      return [
        'Lagos skyline at golden hour',
        'Dark fintech app UI mockup',
        'Afrofuturist portrait',
      ];
    }
    if (mode == 2) {
      return [
        'Build a Flutter expense tracker',
        'Scaffold a landing page for a Naira fintech',
        'Plan a company from zero to MVP',
      ];
    }
    return [
      'Draft a CV for a Flutter developer in Nigeria',
      'Explain SaaS pricing in Naira',
      'Code a Riverpod counter with dark theme',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        // Grok-style center mark
        Center(
          child: CustomPaint(
            size: const Size(72, 72),
            painter: _JxMarkPainter(),
          ),
        ),
        const SizedBox(height: 20),
        if (hello != null)
          Text(
            hello!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Jx.muted),
          ),
        const SizedBox(height: 8),
        Text(
          mode == 1
              ? 'What will you imagine?'
              : mode == 2
                  ? 'What should we build?'
                  : 'How can JagX help?',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Jx.text),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _tips
              .map(
                (t) => ActionChip(
                  label: Text(t,
                      style: const TextStyle(color: Jx.muted, fontSize: 13)),
                  backgroundColor: Jx.card,
                  side: const BorderSide(color: Jx.border),
                  onPressed: () => onTap(t),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _JxMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width * 0.32, p);
    canvas.drawLine(
      Offset(c.dx - 8, c.dy - 14),
      Offset(c.dx + 16, c.dy + 18),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      backgroundColor: const Color(0xFF0A0A0A),
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Jx.accent,
                child: Text(email[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              title: Text(email,
                  style: const TextStyle(color: Jx.text, fontSize: 14),
                  overflow: TextOverflow.ellipsis),
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
              leading: const Icon(Icons.code, color: Jx.muted),
              title:
                  const Text('Connect GitHub', style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                context.push('/github');
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
              leading: const Icon(Icons.workspace_premium_outlined,
                  color: Jx.muted),
              title: const Text('Premium', style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                context.push('/premium');
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
            ListTile(
              leading:
                  const Icon(Icons.description_outlined, color: Jx.muted),
              title: const Text('Terms & Privacy',
                  style: TextStyle(color: Jx.text)),
              onTap: () {
                Navigator.pop(context);
                context.push('/terms');
              },
            ),
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
