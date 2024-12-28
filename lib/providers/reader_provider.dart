import 'package:flutter/material.dart';

class ReaderConfig {
  double fontSize;
  double lineHeight;
  Color backgroundColor;
  Color textColor;
  String fontFamily;
  bool enableDarkMode;

  ReaderConfig({
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.fontFamily = 'System',
    this.enableDarkMode = false,
  });
}

class ReaderProvider extends ChangeNotifier {
  ReaderConfig _config = ReaderConfig();

  ReaderConfig get config => _config;

  void updateFontSize(double size) {
    _config.fontSize = size;
    notifyListeners();
  }

  void updateLineHeight(double height) {
    _config.lineHeight = height;
    notifyListeners();
  }

  void updateBackgroundColor(Color color) {
    _config.backgroundColor = color;
    notifyListeners();
  }

  void updateTextColor(Color color) {
    _config.textColor = color;
    notifyListeners();
  }

  void updateFontFamily(String family) {
    _config.fontFamily = family;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _config.enableDarkMode = value;
    if (value) {
      _config.backgroundColor = Colors.black87;
      _config.textColor = Colors.white;
    } else {
      _config.backgroundColor = Colors.white;
      _config.textColor = Colors.black87;
    }
    notifyListeners();
  }
} 