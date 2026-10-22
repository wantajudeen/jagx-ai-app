import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';

class JagxApp extends ConsumerWidget {
  const JagxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'JagX AI',
      debugShowCheckedModeBanner: false,
      theme: JagxTheme.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
