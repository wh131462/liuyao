import 'package:hive_flutter/hive_flutter.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();
  
  late final Box _configBox;
  
  Future<void> init() async {
    await Hive.initFlutter();
    _configBox = await Hive.openBox('app_config');
  }
  
  // 用户配置相关
  Future<void> saveUserConfig(Map<String, dynamic> config) async {
    await _configBox.put('user_config', config);
  }
  
  Map<String, dynamic>? getUserConfig() {
    return _configBox.get('user_config');
  }
  
  // API 配置相关
  Future<void> saveApiEndpoint(String endpoint) async {
    await _configBox.put('api_endpoint', endpoint);
  }
  
  String? getApiEndpoint() {
    return _configBox.get('api_endpoint');
  }
  
  // 主题配置
  Future<void> saveThemeMode(String mode) async {
    await _configBox.put('theme_mode', mode);
  }
  
  String getThemeMode() {
    return _configBox.get('theme_mode', defaultValue: 'system');
  }
  
  // 阅读器配置
  Future<void> saveReaderConfig(Map<String, dynamic> config) async {
    await _configBox.put('reader_config', config);
  }
  
  Map<String, dynamic>? getReaderConfig() {
    return _configBox.get('reader_config');
  }
  
  Future<void> savePrimaryColor(int color) async {
    await _configBox.put('primary_color', color);
  }
  
  int? getPrimaryColor() {
    return _configBox.get('primary_color');
  }
} 