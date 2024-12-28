import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

class FileManager {
  static String? _currentPath;
  
  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _currentPath = directory.path;
    
    // 确保所有必要目录存在
    await Future.wait([
      _createSubDir('books'),
      _createSubDir('avatars'),
      _createSubDir('covers'),
      _createSubDir('temp'),
    ]);
    
    // 复制资源文件到应用目录
    await _copyAssetBooks();
  }

  static Future<Directory> _createSubDir(String name) async {
    final dir = Directory(path.join(_currentPath!, name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
  
  static Future<void> _copyAssetBooks() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
    
    final bookPaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/book/'))
        .toList();
        
    for (final assetPath in bookPaths) {
      final fileName = path.basename(assetPath);
      final targetPath = path.join(_currentPath!, 'books', fileName);
      
      // 如果文件不存在，则复制
      if (!await File(targetPath).exists()) {
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List();
        await File(targetPath).writeAsBytes(bytes);
      }
    }
  }
  
  static String getBookPath(String assetPath) {
    final fileName = path.basename(assetPath);
    return path.join(_currentPath!, 'books', fileName);
  }

  static Future<File?> importFile(String sourcePath, String type) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return null;
      
      final fileName = path.basename(sourcePath);
      final targetDir = await _getTypeDirectory(type);
      final targetPath = path.join(targetDir.path, fileName);
      
      // 如果目标文件已存在，先删除
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      
      // 复制文件到目标目录
      return await file.copy(targetPath);
    } catch (e) {
      print('File import error: $e');
      return null;
    }
  }

  static Future<Directory> _getTypeDirectory(String type) async {
    switch (type.toLowerCase()) {
      case 'book':
        return await _createSubDir('books');
      case 'avatar':
        return await _createSubDir('avatars');
      case 'cover':
        return await _createSubDir('covers');
      default:
        return await _createSubDir('temp');
    }
  }

  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('File delete error: $e');
      return false;
    }
  }

  static Future<List<FileSystemEntity>> listFiles(String type) async {
    try {
      final dir = await _getTypeDirectory(type);
      return dir.listSync();
    } catch (e) {
      print('List files error: $e');
      return [];
    }
  }

  static String getFilePath(String fileName, String type) {
    return path.join(_currentPath!, type, fileName);
  }
} 