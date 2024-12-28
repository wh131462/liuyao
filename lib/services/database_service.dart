import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_item.dart';
import '../models/user_info.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'liuyao.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // 创建历史记录表
    await db.execute('''
      CREATE TABLE history_items(
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        origin_answer TEXT NOT NULL,
        note TEXT,
        timestamp INTEGER NOT NULL,
        analysis TEXT,
        conclusion TEXT,
        tags TEXT
      )
    ''');

    // 创建用户信息表
    await db.execute('''
      CREATE TABLE user_info(
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        passwd TEXT,
        name TEXT,
        email TEXT,
        phone TEXT,
        avatar_path TEXT,
        memo TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  // 历史记录相关方法
  Future<String> insertHistory(HistoryItem item) async {
    final db = await database;
    await db.insert('history_items', item.toMap());
    return item.id;
  }

  Future<List<HistoryItem>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('history_items');
    return List.generate(maps.length, (i) => HistoryItem.fromMap(maps[i]));
  }

  Future<HistoryItem?> getHistoryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return HistoryItem.fromMap(maps.first);
  }

  Future<int> updateHistory(HistoryItem item) async {
    final db = await database;
    return await db.update(
      'history_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteHistory(String id) async {
    final db = await database;
    return await db.delete(
      'history_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 用户信息相关方法
  Future<String> insertUserInfo(UserInfo info) async {
    final db = await database;
    await db.insert('user_info', info.toMap());
    return info.id;
  }

  Future<int> updateUserInfo(UserInfo info) async {
    final db = await database;
    return await db.update(
      'user_info',
      info.toMap(),
      where: 'id = ?',
      whereArgs: [info.id],
    );
  }

  Future<UserInfo?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_info',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return UserInfo.fromMap(maps.first);
  }

  Future<UserInfo?> getUserInfo(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_info',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return UserInfo.fromMap(maps.first);
  }

  Future<void> deleteUserInfo(String userId) async {
    final db = await database;
    await db.delete(
      'user_info',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 确保用户表存在
  Future<void> _createUserInfoTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_info (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        passwd TEXT,
        name TEXT,
        email TEXT,
        phone TEXT,
        avatar_path TEXT,
        memo TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
} 