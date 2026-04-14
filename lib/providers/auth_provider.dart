import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Conditionally import Firebase Auth only on mobile platforms
import 'auth_provider_stub.dart'
    if (dart.library.io) 'auth_provider_mobile.dart' as platform_auth;

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  void _init() {
    platform_auth.listenAuthState(
      onUser: (u) {
        _user = u;
        _isLoading = false;
        notifyListeners();
      },
      onSignedOut: () {
        _user = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> login(String email, String password) async {
    await platform_auth.login(email, password);
  }

  Future<void> signup(String name, String email, String password) async {
    await platform_auth.signup(name, email, password);
  }

  Future<void> logout() async {
    await platform_auth.logout();
  }

  // Desktop-only: set user manually for UI preview
  void setDesktopUser() {
    _user = {'id': 'preview', 'name': 'Preview User', 'email': 'preview@fixmate.app'};
    _isLoading = false;
    notifyListeners();
  }
}
