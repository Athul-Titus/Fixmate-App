import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// ApiService - reads ALL data from bundled local JSON asset.
/// Firebase Auth is handled separately via auth_provider.
/// No Firestore or firebase_auth imports here → works on Windows too.
class ApiService {
  static List<dynamic>? _cache;

  static Future<List<dynamic>> _getData() async {
    _cache ??= jsonDecode(
      await rootBundle.loadString('assets/data/fixmate_data.json'),
    ) as List<dynamic>;
    return _cache!;
  }

  // ── Brands ──────────────────────────────────────────────────────────────
  static Future<List<String>> getBrands() async {
    final data = await _getData();
    final brands = data
        .map((e) => (e['brand'] as String?)?.trim() ?? '')
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return brands;
  }

  // ── Appliances for a brand ───────────────────────────────────────────────
  static Future<List<String>> getAppliances(String brand) async {
    final data = await _getData();
    final appliances = data
        .where((e) => (e['brand'] as String?)?.trim() == brand)
        .map((e) => (e['appliance'] as String?)?.trim() ?? '')
        .where((a) => a.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return appliances;
  }

  // ── Issues for brand + appliance ────────────────────────────────────────
  static Future<List<String>> getIssues(String brand, String appliance) async {
    final data = await _getData();
    final issues = data
        .where((e) =>
            (e['brand'] as String?)?.trim() == brand &&
            (e['appliance'] as String?)?.trim() == appliance)
        .map((e) =>
            (e['issue_title'] as String?)?.trim() ??
            (e['issue'] as String?)?.trim() ??
            '')
        .where((i) => i.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return issues;
  }

  // ── Solution for brand + appliance + issue ──────────────────────────────
  static Future<Map<String, dynamic>> getSolution(
      String brand, String appliance, String issue) async {
    final data = await _getData();

    final match = data.firstWhere(
      (e) =>
          (e['brand'] as String?)?.trim() == brand &&
          (e['appliance'] as String?)?.trim() == appliance &&
          ((e['issue_title'] as String?)?.trim() == issue ||
              (e['issue'] as String?)?.trim() == issue),
      orElse: () => null,
    );

    if (match != null) {
      final fix = (match['solution'] as String?)?.trim() ??
          (match['fix'] as String?)?.trim() ??
          'No solution found.';
      return {
        'fix': fix,
        'quickTips': [
          'Try restarting the appliance first.',
          'Ensure power supply is stable.',
          'Keep the model/serial number ready when calling a technician.',
        ],
      };
    }

    return {
      'fix': 'No solution found for this issue. Please contact a certified technician.',
      'quickTips': [],
    };
  }

  // ── Search across all data ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> search(String query,
      {int page = 1, int limit = 20}) async {
    if (query.isEmpty) return {'results': []};

    final data = await _getData();
    final q = query.toLowerCase();

    final results = data.where((e) {
      final brand = (e['brand'] as String? ?? '').toLowerCase();
      final appliance = (e['appliance'] as String? ?? '').toLowerCase();
      final issue = ((e['issue_title'] as String?) ??
              (e['issue'] as String?) ??
              '')
          .toLowerCase();
      final solution = ((e['solution'] as String?) ??
              (e['fix'] as String?) ??
              '')
          .toLowerCase();
      return brand.contains(q) ||
          appliance.contains(q) ||
          issue.contains(q) ||
          solution.contains(q);
    }).map((e) {
      final issueTitle = (e['issue_title'] as String?)?.trim() ??
          (e['issue'] as String?)?.trim() ??
          '';
      final fix = (e['solution'] as String?)?.trim() ??
          (e['fix'] as String?)?.trim() ??
          '';
      return {
        'brand': e['brand'],
        'appliance': e['appliance'],
        'title': issueTitle,
        'snippet': fix.length > 120 ? '${fix.substring(0, 120)}...' : fix,
      };
    }).toList();

    final pageResults = results.skip((page - 1) * limit).take(limit).toList();

    return {
      'results': pageResults,
      'total': results.length,
      'pages': (results.length / limit).ceil(),
      'current_page': page,
    };
  }

  // ── Auth (delegates to firebase_auth via auth_provider) ─────────────────
  // login / signup are called via platform-conditional auth_provider_mobile.dart
  // These stubs allow auth_provider_stub.dart to compile cleanly on desktop.
  static Future<void> login(String email, String password) async {
    // Actual implementation in auth_provider_mobile.dart
  }

  static Future<void> signup(String name, String email, String password) async {
    // Actual implementation in auth_provider_mobile.dart
  }
}
