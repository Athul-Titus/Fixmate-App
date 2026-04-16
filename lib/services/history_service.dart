import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages recently diagnosed solutions (auto-saved on every solution view).
class HistoryService {
  static const _key = 'diagnosis_history';
  static const _maxItems = 50;

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList(); // newest first
  }

  static Future<void> addEntry({
    required String brand,
    required String appliance,
    required String issue,
    required String solution,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final entry = jsonEncode({
      'brand': brand,
      'appliance': appliance,
      'issue': issue,
      'solution': solution,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Avoid exact duplicates (same brand+appliance+issue)
    raw.removeWhere((e) {
      final d = jsonDecode(e) as Map<String, dynamic>;
      return d['brand'] == brand &&
          d['appliance'] == appliance &&
          d['issue'] == issue;
    });

    raw.add(entry);

    // Keep only last _maxItems
    final trimmed = raw.length > _maxItems
        ? raw.sublist(raw.length - _maxItems)
        : raw;

    await prefs.setStringList(_key, trimmed);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> removeEntry(String brand, String appliance, String issue) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final d = jsonDecode(e) as Map<String, dynamic>;
      return d['brand'] == brand &&
          d['appliance'] == appliance &&
          d['issue'] == issue;
    });
    await prefs.setStringList(_key, raw);
  }
}
