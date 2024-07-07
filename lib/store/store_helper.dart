import 'dart:io';

import 'package:liuyao_flutter/utils/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static var _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    final path = await getDatabasePath();
    final db = openDatabase(path, onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    }, version: 1);
    logger.info("创建数据库成功！");
    return db;
  }

  /// 获取数据库地址
  Future<String> getDatabasePath() async {
    // 获取应用的文档目录路径
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    // 构建数据库文件的完整路径
    return join(documentsDirectory.path, 'liuyao.db');
  }
}
