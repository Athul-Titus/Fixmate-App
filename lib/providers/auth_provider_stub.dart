/// Stub auth for Windows/desktop — no Firebase, no auth, always unauthenticated.

void listenAuthState({
  required void Function(Map<String, dynamic>) onUser,
  required void Function() onSignedOut,
}) {
  // On desktop, just fire signed-out immediately
  Future.microtask(onSignedOut);
}

Future<void> login(String email, String password) async {
  throw Exception('Authentication is not available on desktop preview.');
}

Future<void> signup(String name, String email, String password) async {
  throw Exception('Authentication is not available on desktop preview.');
}

Future<void> logout() async {}
