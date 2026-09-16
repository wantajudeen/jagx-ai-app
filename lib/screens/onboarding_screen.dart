import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/profile.dart';
import '../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  DateTime _dob = DateTime(2000, 1, 1);
  bool _picked = false;
  String? _error;
  bool _loading = false;

  void _showScrollDob() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Jx.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        DateTime temp = _dob;
        return SafeArea(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: Jx.muted)),
                      ),
                      const Text('Date of birth',
                          style: TextStyle(
                              color: Jx.text, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _dob = temp;
                            _picked = true;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Done',
                            style: TextStyle(color: Jx.accent)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.dark,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: Jx.text,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _dob,
                      minimumDate: DateTime(1950),
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (d) => temp = d,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter your name');
      return;
    }
    if (!_picked) {
      setState(() => _error = 'Select date of birth');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final dobStr =
        '${_dob.year}-${_dob.month.toString().padLeft(2, '0')}-${_dob.day.toString().padLeft(2, '0')}';
    await Profile.save(name: _name.text, dob: dobStr);
    if (mounted) context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to JagX',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Jx.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Name and date of birth so we can greet you properly.',
                style: TextStyle(color: Jx.muted, height: 1.4),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _name,
                style: const TextStyle(color: Jx.text),
                decoration: InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Taju',
                  labelStyle: const TextStyle(color: Jx.muted),
                  filled: true,
                  fillColor: Jx.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _showScrollDob,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Jx.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Jx.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          !_picked
                              ? 'Date of birth (scroll to choose)'
                              : '${_dob.day}/${_dob.month}/${_dob.year}',
                          style: TextStyle(
                            color: !_picked ? Jx.muted : Jx.text,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(Icons.unfold_more, color: Jx.dim),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(color: Colors.redAccent)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Jx.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Continue',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
