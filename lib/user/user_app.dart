import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'auth_gate.dart';

class MapDevUserApp extends StatelessWidget {
  const MapDevUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAP.DEV',
      debugShowCheckedModeBanner: false,
      theme: MapDevTheme.dark(),
      home: const AuthGate(),
    );
  }
}
