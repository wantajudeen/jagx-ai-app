import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _code = TextEditingController();
  String _status = 'Free';
  String? _msg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _status = p.getString('jx_tier') ?? 'Free');
  }

  Future<void> _activate() async {
    final c = _code.text.trim().toUpperCase();
    if (c.isEmpty) {
      setState(() => _msg = 'Enter a code');
      return;
    }

    String? tierName;
    int? days;
    switch (c) {
      case 'JAGX-PREMIUM-30':
        tierName = 'Premium';
        days = 30;
        break;
      case 'JAGX-PLUS-30':
        tierName = 'Premium+';
        days = 30;
        break;
      case 'JAGX-PLUS-365':
      case 'FOUNDER-YEAR':
        tierName = 'Premium+';
        days = 365;
        break;
      default:
        setState(() => _msg = 'Invalid code');
        return;
    }

    final p = await SharedPreferences.getInstance();
    final exp = DateTime.now().add(Duration(days: days));
    await p.setString('jx_tier', tierName);
    await p.setInt('jx_tier_exp', exp.millisecondsSinceEpoch);
    setState(() {
      _status = tierName!;
      _msg = 'Activated $tierName for $days days';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Current plan: $_status',
              style: const TextStyle(
                  color: Jx.text, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _plan('Premium', [
            'Longer chats',
            'Build apps & sites help',
            'Priority responses',
          ]),
          const SizedBox(height: 12),
          _plan('Premium+', [
            'Everything in Premium',
            'Full JagX Bot tools',
            'Connectors unlocked',
            'Best models unrestricted',
          ]),
          const SizedBox(height: 24),
          const Text('Redeem code',
              style: TextStyle(color: Jx.muted, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _code,
            style: const TextStyle(color: Jx.text),
            decoration: InputDecoration(
              hintText: 'JAGX-…',
              hintStyle: const TextStyle(color: Jx.dim),
              filled: true,
              fillColor: Jx.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_msg != null) ...[
            const SizedBox(height: 8),
            Text(_msg!, style: const TextStyle(color: Jx.muted)),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _activate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Jx.accent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  Widget _plan(String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Jx.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Jx.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Jx.text, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('· $p', style: const TextStyle(color: Jx.muted)),
              )),
        ],
      ),
    );
  }
}
