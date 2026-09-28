import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ai.dart';
import '../core/auth.dart';
import '../core/export_doc.dart';
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
  XFile? _pendingImage;
  PlatformFile? _pendingFile;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
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
      _displayName =
          (n != null && n.isNotEmpty) ? n : (dn ?? 'JagX User');
      _hello = n == null || n.isEmpty ? null : '${Profile.greeting()}, $n';
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

  Future<void> _attach() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Jx.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_outlined, color: Jx.text),
              title: const Text('Photo',
                  style: TextStyle(color: Jx.text)),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await ImagePicker()
                    .pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (img != null) {
                  setState(() {
                    _pendingImage = img;
                    _pendingFile = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Jx.text),
              title: const Text('Camera', style: TextStyle(color: Jx.text)),
              onTap: () async {
                Navigator.pop(ctx);
                final img = await ImagePicker()
                    .pickImage(source: ImageSource.camera, imageQuality: 85);
                if (img != null) {
                  setState(() {
                    _pendingImage = img;
                    _pendingFile = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Jx.text),
              title: const Text('File', style: TextStyle(color: Jx.text)),
              onTap: () async {
                Navigator.pop(ctx);
                final res = await FilePicker.platform.pickFiles();
                if (res != null && res.files.isNotEmpty) {
                  setState(() {
                    _pendingFile = res.files.first;
                    _pendingImage = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send([String? override]) async {
    final text = (override ?? _controller.text).trim();
    final hasAttach = _pendingImage != null || _pendingFile != null;
    if ((text.isEmpty && !hasAttach) || _loading) return;
    if (_model.comingSoon) {
      _toast('Oracle is Coming soon');
      return;
    }

    final isBuild = _tabs.index == 1;
    var userLine = text;
    if (_pendingImage != null) {
      userLine = text.isEmpty
          ? '[Image: ${_pendingImage!.name}]'
          : '$text\n[Image: ${_pendingImage!.name}]';
    } else if (_pendingFile != null) {
      userLine = text.isEmpty
          ? '[File: ${_pendingFile!.name}]'
          : '$text\n[File: ${_pendingFile!.name}]';
    }

    // Nudge for long-form exportable content
    var promptText = userLine;
    if (_wantsBook(text)) {
      promptText =
          '$userLine\n\nWrite the full content in plain text, chapter by chapter if needed. No markdown bold stars.';
    }

    setState(() {
      _messages.add(_Msg(userLine, true,
          imagePath: _pendingImage?.path, fileName: _pendingFile?.name));
      _controller.clear();
      _pendingImage = null;
      _pendingFile = null;
      _loading = true;
      _streaming = '';
    });
    _scrollDown();

    final history = <Map<String, String>>[
      for (final m in _messages)
        if (m != _messages.last)
          {'role': m.user ? 'user' : 'assistant', 'content': m.text},
      {'role': 'user', 'content': promptText},
    ];

    final modelId = isBuild ? 'forge' : _model.id;
    final reply = await Ai.chat(modelId: modelId, messages: history);

    var built = '';
    const step = 28;
    for (var i = 0; i < reply.length; i += step) {
      built = reply.substring(0, (i + step).clamp(0, reply.length));
      setState(() => _streaming = built);
      await Future.delayed(const Duration(milliseconds: 2));
    }

    setState(() {
      _messages.add(_Msg(reply, false));
      _streaming = null;
      _loading = false;
    });
    await _saveHistory();
    _scrollDown();
  }

  bool _wantsBook(String text) {
    final t = text.toLowerCase();
    return t.contains('story') ||
        t.contains('book') ||
        t.contains('chapter') ||
        t.contains('pdf') ||
        t.contains('essay') ||
        t.contains('novel');
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
          children: Models.list.map((m) {
            return ListTile(
              title: Text(m.name,
                  style: TextStyle(
                    color: m.comingSoon ? Jx.dim : Jx.text,
                    fontWeight: FontWeight.w600,
                  )),
              subtitle: Text(m.subtitle,
                  style: const TextStyle(color: Jx.muted, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                if (m.comingSoon) {
                  _toast('Oracle is Coming soon');
                } else {
                  setState(() => _model = m);
                }
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
      _pendingImage = null;
      _pendingFile = null;
    });
    final p = await SharedPreferences.getInstance();
    await p.remove('jx_chat_history');
  }

  Future<void> _exportPdf(_Msg m) async {
    try {
      _toast('Building PDF…');
      await ExportDoc.sharePdf(
        title: 'JagX export',
        body: m.text,
      );
    } catch (e) {
      _toast('Could not export PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBuild = _tabs.index == 1;
    final chip = _model.badge ?? 'Fast';

    return Scaffold(
      backgroundColor: Jx.bg,
      drawer: Drawer(
        backgroundColor: Jx.surface,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Jx.cardHover,
                  child: Text(
                    _displayName.isNotEmpty
                        ? _displayName[0].toUpperCase()
                        : 'J',
                    style: const TextStyle(color: Jx.text),
                  ),
                ),
                title: Text(_displayName,
                    style: const TextStyle(
                        color: Jx.text, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, color: Jx.dim),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/settings');
                },
              ),
              const Divider(color: Jx.border),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Jx.muted),
                title:
                    const Text('New chat', style: TextStyle(color: Jx.text)),
                onTap: () {
                  Navigator.pop(context);
                  _newChat();
                },
              ),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined, color: Jx.muted),
                title:
                    const Text('JagX Bot', style: TextStyle(color: Jx.text)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/bot');
                },
              ),
              ListTile(
                leading: const Icon(Icons.hub_outlined, color: Jx.muted),
                title:
                    const Text('Connectors', style: TextStyle(color: Jx.text)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/connectors');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Jx.muted),
                title:
                    const Text('Settings', style: TextStyle(color: Jx.text)),
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
          indicatorColor: Jx.text,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Jx.text,
          unselectedLabelColor: Jx.dim,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                ? EmptyChat(mode: isBuild ? 2 : 0, hello: _hello)
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: [
                      ..._messages.map((m) => _Bubble(
                            m,
                            onExport: m.user || m.text.length < 80
                                ? null
                                : () => _exportPdf(m),
                          )),
                      if (_streaming != null)
                        _Bubble(_Msg(_streaming!, false), streaming: true),
                      if (_loading && _streaming == null)
                        const Padding(
                          padding: EdgeInsets.only(left: 8, top: 8),
                          child: JagxMark(size: 26, color: Color(0xFF6A6A6A)),
                        ),
                    ],
                  ),
          ),
          if (_pendingImage != null || _pendingFile != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  if (_pendingImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_pendingImage!.path),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _pendingImage = null),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black87,
                              child: Icon(Icons.close,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_pendingFile != null)
                    Chip(
                      backgroundColor: Jx.card,
                      label: Text(_pendingFile!.name,
                          style: const TextStyle(
                              color: Jx.text, fontSize: 12)),
                      onDeleted: () =>
                          setState(() => _pendingFile = null),
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
                ),
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Jx.text, fontSize: 15),
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: isBuild
                            ? 'Describe what to build…'
                            : 'Ask anything',
                        hintStyle: const TextStyle(color: Jx.dim),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _attach,
                          icon: const Icon(Icons.add, color: Jx.muted),
                        ),
                        GestureDetector(
                          onTap: _pickModel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Jx.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(chip,
                                    style: const TextStyle(
                                        fontSize: 12, color: Jx.muted)),
                                const Icon(Icons.arrow_drop_down,
                                    size: 16, color: Jx.dim),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Material(
                          color: Jx.text,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _loading ? null : () => _send(),
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color: _loading ? Jx.dim : Colors.black,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
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
  _Msg(this.text, this.user, {this.imagePath, this.fileName});
  final String text;
  final bool user;
  final String? imagePath;
  final String? fileName;
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.msg, {this.streaming = false, this.onExport});
  final _Msg msg;
  final bool streaming;
  final VoidCallback? onExport;

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
            if (msg.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(msg.imagePath!),
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (msg.text.isNotEmpty)
              SelectableText(
                msg.text,
                style:
                    const TextStyle(color: Jx.text, fontSize: 15, height: 1.5),
              ),
            if (!msg.user && !streaming)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onExport != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Save PDF',
                      icon: const Icon(Icons.picture_as_pdf_outlined,
                          size: 16, color: Jx.dim),
                      onPressed: onExport,
                    ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.copy, size: 15, color: Jx.dim),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: msg.text)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
