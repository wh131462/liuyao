import 'package:flutter/foundation.dart';
import '../models/user_profile_config.dart';
import '../core/user/user_config_manager.dart';
import '../core/file/file_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../utils/image_helper.dart';

class UserProfileProvider with ChangeNotifier {
  final _configManager = UserConfigManager();
  final _fileManager = FileManager();
  UserProfileConfig _profile = UserProfileConfig();
  
  UserProfileConfig get profile => _profile;
  
  Future<void> loadProfile() async {
    final config = _configManager.getUserConfig();
    if (config != null) {
      _profile = UserProfileConfig.fromJson(config);
      notifyListeners();
    }
  }
  
  Future<void> updateAvatar() async {
    final file = await ImageHelper.pickAndCropImage(
      source: ImageSource.gallery,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 512,
      maxHeight: 512,
      quality: 100,
    );
    
    if (file != null) {
      final savedFile = await FileManager.importFile(file.path, 'avatar');
      if (savedFile != null) {
        _profile.avatarPath = savedFile.path;
        await _saveProfile();
      }
    }
  }
  
  Future<void> updateCover() async {
    final file = await ImageHelper.pickAndCropImage(
      source: ImageSource.gallery,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      maxWidth: 1920,
      maxHeight: 1080,
      quality: 85,
    );
    
    if (file != null) {
      final savedFile = await FileManager.importFile(file.path, 'cover');
      if (savedFile != null) {
        _profile.coverPath = savedFile.path;
        await _saveProfile();
      }
    }
  }
  
  Future<void> updateProfile({
    String? nickname,
    String? signature,
  }) async {
    if (nickname != null) _profile.nickname = nickname;
    if (signature != null) _profile.signature = signature;
    await _saveProfile();
  }
  
  Future<void> _saveProfile() async {
    await _configManager.saveUserConfig(_profile.toJson());
    notifyListeners();
  }
} 