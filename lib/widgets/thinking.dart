import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Grok-style "Thinking · 12s" indicator.
class ThinkingLabel extends StatefulWidget {
  const ThinkingLabel({super.key});

  @override
  State<ThinkingLabel> createState() => _ThinkingLabelState();
}

class _ThinkingLabelState extends State<ThinkingLabel> {
  final _start = DateTime.now();
  Timer? _t;
  int _secs = 0;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secs = DateTime.now().difference(_start).inSeconds);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _secs ~/ 60;
    final s = _secs % 60;
    final label = m > 0 ? 'Thinking · ${m}m ${s}s' : 'Thinking · ${s}s';
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Jx.dim,
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Jx.muted, fontSize: 13)),
        ],
      ),
    );
  }
}
