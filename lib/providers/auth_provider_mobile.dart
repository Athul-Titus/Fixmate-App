import 'package:firebase_auth/firebase_auth.dart';

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
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, password: password);
  } on FirebaseAuthException catch (e) {
    throw Exception(_mapFirebaseError(e.code));
  }
}

Future<void> signup(String name, String email, String password) async {
  try {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, password: password);
    await cred.user?.updateDisplayName(name);
  } on FirebaseAuthException catch (e) {
    throw Exception(_mapFirebaseError(e.code));
  }
}

Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
}

String _mapFirebaseError(String code) {
  switch (code) {
    case 'user-not-found': return 'No account found with this email.';
    case 'wrong-password': return 'Incorrect password. Please try again.';
    case 'invalid-email': return 'The email address is not valid.';
    case 'email-already-in-use': return 'An account with this email already exists.';
    case 'weak-password': return 'Password must be at least 6 characters.';
    case 'network-request-failed': return 'Network error. Check your connection.';
    case 'too-many-requests': return 'Too many attempts. Please try again later.';
    case 'invalid-credential': return 'Incorrect email or password.';
    default: return 'Authentication failed. Please try again.';
  }
}
