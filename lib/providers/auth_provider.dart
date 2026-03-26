import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    final name = prefs.getString('userName');
    final email = prefs.getString('userEmail');

    if (id != null && name != null && email != null) {
      _user = {
        'id': id,
        'name': name,
        'email': email,
      };
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      // Backend returns { ok: true, user: { id: 1, name: "...", email: "..." } }
      if (response['ok'] == true && response['user'] != null) {
        _user = response['user'];
        await _saveUser(_user!);
        notifyListeners();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      final response = await ApiService.signup(name, email, password);
      if (response['ok'] == true && response['user'] != null) {
        _user = response['user'];
        await _saveUser(_user!);
        notifyListeners();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    notifyListeners();
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user['id'] as int);
    await prefs.setString('userName', user['name'] as String);
    await prefs.setString('userEmail', user['email'] as String);
  }
}
