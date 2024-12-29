import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReadingProgress {
  static const String _keyPrefix = 'reading_progress_';
  static const String _bookmarkPrefix = 'bookmarks_';
  
  static Future<void> saveProgress(String bookPath, int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyPrefix$bookPath', page);
  }

  static Future<int> getProgress(String bookPath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyPrefix$bookPath') ?? 0;
  }

  static Future<void> saveBookmarks(String path, List<int> bookmarks, [Map<int, String>? titles]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${path}_bookmarks', jsonEncode(bookmarks));
    if (titles != null) {
      await prefs.setString('${path}_bookmark_titles', jsonEncode(titles));
    }
  }

  static Future<List<int>> getBookmarks(String bookPath) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? bookmarkStrings = prefs.getStringList('$_bookmarkPrefix$bookPath');
    if (bookmarkStrings == null) return [];
    return bookmarkStrings.map((e) => int.parse(e)).toList()..sort();
  }

  static Future<Map<int, String>> getBookmarkTitles(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final String? titlesJson = prefs.getString('${path}_bookmark_titles');
    if (titlesJson != null) {
      final Map<String, dynamic> data = jsonDecode(titlesJson);
      return data.map((key, value) => MapEntry(int.parse(key), value as String));
    }
    return {};
  }
} 