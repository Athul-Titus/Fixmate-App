import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Replace this with the actual deployed backend URL
  static const String baseUrl = 'https://fixmate-app-ykux.onrender.com/api';

  static Future<List<String>> getBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/brands'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load brands');
  }

  static Future<List<String>> getAppliances(String brand) async {
    final response = await http.get(Uri.parse('$baseUrl/appliances?brand=${Uri.encodeComponent(brand)}'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load appliances');
  }

  static Future<List<String>> getIssues(String brand, String appliance) async {
    final response = await http.get(Uri.parse('$baseUrl/issues?brand=${Uri.encodeComponent(brand)}&appliance=${Uri.encodeComponent(appliance)}'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load issues');
  }

  static Future<Map<String, dynamic>> getSolution(String brand, String appliance, String issue) async {
    final response = await http.post(
      Uri.parse('$baseUrl/solution'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'brand': brand,
        'appliance': appliance,
        'issue': issue,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load solution');
  }

  static Future<Map<String, dynamic>> search(String query, {int page = 1, int limit = 20}) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}&page=$page&limit=$limit'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to perform search');
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Signup failed');
    }
  }
}
