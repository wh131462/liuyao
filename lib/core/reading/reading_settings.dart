import 'package:shared_preferences/shared_preferences.dart';

enum ScrollMode {
  singleHorizontal('单页横向'), // 单页横向翻页
  singleVertical('单页纵向'),   // 单页纵向翻页
  continuousHorizontal('连续横向'), // 连续横向滚动
  continuousVertical('连续纵向');  // 连续纵向滚动

  final String label;
  const ScrollMode(this.label);
}

class ReadingSettings {
  static const String _keyPrefix = 'reading_settings_';
  
  // 阅读设置键
  static const String _brightnessKey = '${_keyPrefix}brightness';
  static const String _fontSizeKey = '${_keyPrefix}fontSize';
  static const String _scrollModeKey = '${_keyPrefix}scrollMode';
  static const String _defaultScrollModeKey = '${_keyPrefix}defaultScrollMode';
  static const String _zoomLevelKey = '${_keyPrefix}zoomLevel';
  static const String _darkModeKey = 'reading_dark_mode';
  
  // 默认值
  static const double defaultBrightness = 1.0;
  static const double defaultFontSize = 18.0;
  static const ScrollMode defaultScrollMode = ScrollMode.singleVertical;
  static const double defaultZoomLevel = 1.0;

  // 获取亮度
  static Future<double> getBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_brightnessKey) ?? defaultBrightness;
  }

  // 设置亮度
  static Future<void> setBrightness(double brightness) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_brightnessKey, brightness);
  }

  // 获取字体大小
  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? defaultFontSize;
  }

  // 设置字体大小
  static Future<void> setFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }

  // 获取滚动模式
  static Future<ScrollMode> getScrollMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_scrollModeKey);
    return index != null ? ScrollMode.values[index] : defaultScrollMode;
  }

  // 设置滚动模式
  static Future<void> setScrollMode(ScrollMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scrollModeKey, mode.index);
  }

  // 获取默认滚动模式
  static Future<ScrollMode> getDefaultScrollMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_defaultScrollModeKey);
    return index != null ? ScrollMode.values[index] : defaultScrollMode;
  }

  // 设置默认滚动模式
  static Future<void> setDefaultScrollMode(ScrollMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultScrollModeKey, mode.index);
  }

  static Future<double> getZoomLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_zoomLevelKey) ?? defaultZoomLevel;
  }

  static Future<void> setZoomLevel(double zoomLevel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_zoomLevelKey, zoomLevel);
  }

  // 获取暗黑模式设置
  static Future<bool?> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    // 返回 null 表示使用系统设置
    if (!prefs.containsKey(_darkModeKey)) {
      return null;
    }
    return prefs.getBool(_darkModeKey);
  }

  // 保存暗黑模式设置
  static Future<void> setDarkMode(bool? isDark) async {
    final prefs = await SharedPreferences.getInstance();
    if (isDark == null) {
      // 如果设置为 null，表示跟随系统
      await prefs.remove(_darkModeKey);
    } else {
      await prefs.setBool(_darkModeKey, isDark);
    }
  }
} 