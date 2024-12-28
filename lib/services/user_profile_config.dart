import 'package:shared_preferences/shared_preferences.dart';

class UserProfileConfig {
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyTheme = 'theme';

  final SharedPreferences _prefs;

  UserProfileConfig(this._prefs);

  String? get username => _prefs.getString(_keyUsername);
  String? get email => _prefs.getString(_keyEmail);
  String? get theme => _prefs.getString(_keyTheme);

  Future<void> setUsername(String value) async {
    await _prefs.setString(_keyUsername, value);
  }

  Future<void> setEmail(String value) async {
    await _prefs.setString(_keyEmail, value);
  }

  Future<void> setTheme(String value) async {
    await _prefs.setString(_keyTheme, value);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}