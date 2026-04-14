import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

/// Real Firebase init for Android and iOS.
Future<void> init() async {
  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp();
  }
}
