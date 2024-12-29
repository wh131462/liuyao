import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_item.dart';
import '../models/user_info.dart';

class DatabaseService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'liuyao.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS history(
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
        
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users(
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS history(
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
        }
      },
    );
  }

  // 基础数据库操作
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // 历史记录相关操作
  Future<String> insertHistory(HistoryItem item) async {
    await insert('history', item.toMap());
    return item.id;
  }

  Future<int> updateHistory(HistoryItem item) async {
    return await update(
      'history',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteHistory(String id) async {
    return await delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<HistoryItem>> getAllHistory() async {
    final List<Map<String, dynamic>> maps = await query('history');
    return List.generate(maps.length, (i) {
      return HistoryItem.fromMap(maps[i]);
    });
  }

  // 用户相关操作
  Future<String> insertUserInfo(UserInfo userInfo) async {
    await insert('users', userInfo.toMap());
    return userInfo.id;
  }

  Future<int> updateUserInfo(UserInfo userInfo) async {
    return await update(
      'users',
      userInfo.toMap(),
      where: 'id = ?',
      whereArgs: [userInfo.id],
    );
  }

  Future<UserInfo?> getUserInfo(String id) async {
    final List<Map<String, dynamic>> maps = await query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserInfo.fromMap(maps.first);
  }

  Future<UserInfo?> getUserByUsername(String username) async {
    final List<Map<String, dynamic>> maps = await query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserInfo.fromMap(maps.first);
  }

  Future<void> deleteUserInfo(String userId) async {
    await delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<HistoryItem?> getHistoryById(String id) async {
    final List<Map<String, dynamic>> maps = await query(
      'history',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return HistoryItem.fromMap(maps.first);
  }
} 