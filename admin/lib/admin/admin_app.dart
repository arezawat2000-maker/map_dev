import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'auth_gate.dart';

export '../widgets/admin_request_card.dart' show AdminRequestCard;

class MapDevAdminApp extends StatelessWidget {
  const MapDevAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAP.DEV Admin',
      debugShowCheckedModeBanner: false,
      theme: MapDevTheme.dark(),
      home: const AuthGate(),
    );
  }
}
