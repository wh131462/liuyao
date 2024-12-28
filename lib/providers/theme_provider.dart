import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'primary_color';
  
  Color _primaryColor = Colors.blue;
  ThemeMode _themeMode = ThemeMode.system;
  final _prefs = SharedPreferences.getInstance();

  ThemeProvider() {
    _loadSettings();
  }

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    final savedThemeMode = prefs.getString(_themeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }

    final savedColor = prefs.getInt(_colorKey);
    if (savedColor != null) {
      _primaryColor = Color(savedColor);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await _prefs;
    await prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await _prefs;
    await prefs.setInt(_colorKey, color.value);
    notifyListeners();
  }

  // 切换暗黑模式
  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // 使用系统主题
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
} 