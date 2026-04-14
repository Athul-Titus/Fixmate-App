import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

/// Real Firebase auth listener for Android/iOS.
void listenAuthState({
  required void Function(Map<String, dynamic>) onUser,
  required void Function() onSignedOut,
}) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      onUser({
        'id': user.uid,
        'name': user.displayName ?? 'User',
        'email': user.email,
      });
    } else {
      onSignedOut();
    }
  });
}

Future<void> login(String email, String password) async {
  await ApiService.login(email, password);
}

Future<void> signup(String name, String email, String password) async {
  await ApiService.signup(name, email, password);
}

Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
}
