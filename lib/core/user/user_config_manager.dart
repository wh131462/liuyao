import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

class UserConfigManager {
  static final UserConfigManager _instance = UserConfigManager._internal();
  factory UserConfigManager() => _instance;
  UserConfigManager._internal();
  
  final _localConfig = AppConfig();
  final _apiClient = ApiClient();
  
  Future<bool> _checkNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  Future<void> syncUserConfig() async {
    if (!await _checkNetworkConnection()) return;
    
    try {
      // 从服务器获取最新配置
      final response = await _apiClient.get('/user/config');
      if (response.statusCode == 200) {
        final serverConfig = response.data as Map<String, dynamic>;
        await _localConfig.saveUserConfig(serverConfig);
      }
    } catch (e) {
      print('Sync config error: $e');
    }
  }
  
  Future<void> saveUserConfig(Map<String, dynamic> config) async {
    // 保存到本地
    await _localConfig.saveUserConfig(config);
    
    // 尝试同步到服务器
    await _syncToServer(config);
  }
  
  Future<void> _syncToServer(Map<String, dynamic> config) async {
    if (!await _checkNetworkConnection()) return;
    
    try {
      await _apiClient.post('/user/config', data: config);
    } catch (e) {
      print('Sync to server error: $e');
    }
  }
  
  Map<String, dynamic>? getUserConfig() {
    return _localConfig.getUserConfig();
  }
} 