import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _user = {
          'id': user.uid,
          'name': user.displayName ?? 'User',
          'email': user.email,
        };
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await ApiService.login(email, password);
    // authStateChanges will auto-trigger and update _user
  }

  Future<void> signup(String name, String email, String password) async {
    await ApiService.signup(name, email, password);
    // authStateChanges will auto-trigger and update _user
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // authStateChanges will auto-trigger and clear _user
  }
}
