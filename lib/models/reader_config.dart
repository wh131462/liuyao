import 'dart:ui';
class ReaderConfig {
  double fontSize;
  double lineHeight;
  Color backgroundColor;
  Color textColor;
  String fontFamily;
  bool enableDarkMode;

  ReaderConfig({
    this.fontSize = 18.0,
    this.lineHeight = 1.5,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.textColor = const Color(0xFF333333),
    this.fontFamily = 'System',
    this.enableDarkMode = false,
  });

  Map<String, dynamic> toJson() => {
    'fontSize': fontSize,
    'lineHeight': lineHeight,
    'backgroundColor': backgroundColor.value,
    'textColor': textColor.value,
    'fontFamily': fontFamily,
    'enableDarkMode': enableDarkMode,
  };

  factory ReaderConfig.fromJson(Map<String, dynamic> json) {
    return ReaderConfig(
      fontSize: json['fontSize'] ?? 18.0,
      lineHeight: json['lineHeight'] ?? 1.5,
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFF5F5F5),
      textColor: Color(json['textColor'] ?? 0xFF333333),
      fontFamily: json['fontFamily'] ?? 'System',
      enableDarkMode: json['enableDarkMode'] ?? false,
    );
  }
} 