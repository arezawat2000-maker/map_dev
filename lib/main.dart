import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'user/user_app.dart';

/// MAP.DEV user app entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MapDevUserApp());
}
