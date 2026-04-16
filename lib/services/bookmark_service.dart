import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages bookmarked solutions (user manually saves them).
class BookmarkService {
  static const _key = 'bookmarks';

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

  static Future<bool> isBookmarked(
      String brand, String appliance, String issue) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.any((e) {
      final d = jsonDecode(e) as Map<String, dynamic>;
      return d['brand'] == brand &&
          d['appliance'] == appliance &&
          d['issue'] == issue;
    });
  }

  static Future<bool> toggleBookmark({
    required String brand,
    required String appliance,
    required String issue,
    required String solution,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final exists = raw.any((e) {
      final d = jsonDecode(e) as Map<String, dynamic>;
      return d['brand'] == brand &&
          d['appliance'] == appliance &&
          d['issue'] == issue;
    });

    if (exists) {
      raw.removeWhere((e) {
        final d = jsonDecode(e) as Map<String, dynamic>;
        return d['brand'] == brand &&
            d['appliance'] == appliance &&
            d['issue'] == issue;
      });
      await prefs.setStringList(_key, raw);
      return false; // removed
    } else {
      raw.add(jsonEncode({
        'brand': brand,
        'appliance': appliance,
        'issue': issue,
        'solution': solution,
        'savedAt': DateTime.now().toIso8601String(),
      }));
      await prefs.setStringList(_key, raw);
      return true; // added
    }
  }

  static Future<void> removeBookmark(
      String brand, String appliance, String issue) async {
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

  static Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
