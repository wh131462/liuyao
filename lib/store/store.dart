import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_item.dart';
import '../models/user_info.dart';
import '../services/database_service.dart';

class StoreService {
  final DatabaseService _db;
  late Database _localDb;
  
  StoreService(this._db);

  // 初始化本地存储数据库
  Future<void> initializeLocal() async {
    String path = join(await getDatabasesPath(), 'local_storage.db');
    _localDb = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE local_storage(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // 获取本地存储的值
  Future<String?> getLocal(String key) async {
    try {
      final List<Map<String, dynamic>> maps = await _localDb.query(
        'local_storage',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [key],
      );
      if (maps.isNotEmpty) {
        return maps.first['value'] as String;
      }
      return null;
    } catch (e) {
      print('Error getting local storage value: $e');
      return null;
    }
  }

  // 设置本地存储的值
  Future<void> setLocal(String key, String value) async {
    try {
      await _localDb.insert(
        'local_storage',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error setting local storage value: $e');
    }
  }

  // 删除本地存储的值
  Future<void> removeLocal(String key) async {
    try {
      await _localDb.delete(
        'local_storage',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      print('Error removing local storage value: $e');
    }
  }

  // 获取所有历史记录
  Future<List<HistoryItem>> getAllHistory() async {
    return await _db.getAllHistory();
  }

  // 按时间范围查询历史记录
  Future<List<HistoryItem>> queryHistoryByTimeRange(DateTime start, DateTime end) async {
    final allHistory = await _db.getAllHistory();
    return allHistory.where((item) {
      return item.createdAt.isAfter(start) && 
             item.createdAt.isBefore(end);
    }).toList();
  }

  // 查询指定日期的历史记录
  Future<List<HistoryItem>> queryHistoryByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    return queryHistoryByTimeRange(startOfDay, endOfDay);
  }

  // 按年份查询历史记录
  Future<List<HistoryItem>> queryHistoryByYear(int year) async {
    final startOfYear = DateTime(year);
    final endOfYear = DateTime(year + 1);
    return queryHistoryByTimeRange(startOfYear, endOfYear);
  }

  // 按月份查询历史记录
  Future<List<HistoryItem>> queryHistoryByMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month);
    final endOfMonth = DateTime(year, month + 1);
    return queryHistoryByTimeRange(startOfMonth, endOfMonth);
  }

  Future<void> close() async {
    await _localDb.close();
    final database = await _db.database;
    await database.close();
  }

  // 获取所有记录
  List<HistoryItem> getAll<T>() {
    if (T == HistoryItem) {
      // 由于 getAllHistory 是异步的，我们需要先获取数据
      List<HistoryItem> items = [];
      _db.getAllHistory().then((value) {
        items = value;
      });
      return items;
    }
    throw UnimplementedError('getAll not implemented for type $T');
  }

  // 删除记录
  Future<void> delete<T>(T item) async {
    if (T == HistoryItem && item is HistoryItem) {
      await _db.deleteHistory(item.id);
      return;
    }
    throw UnimplementedError('delete not implemented for type $T');
  }

  // 修改 ArrangeHistory 以使用异步方法
  Future<List<HistoryItem>> getAllHistoryItems() async {
    return await _db.getAllHistory();
  }

  // 添加新的历史记录
  Future<String> insertHistory(HistoryItem item) async {
    return await _db.insertHistory(item);
  }

  // 获取用户信息
  Future<UserInfo?> getUserInfo(String userId) async {
    return await _db.getUserInfo(userId);
  }

  // 更新用户信息
  Future<int> updateUserInfo(UserInfo userInfo) async {
    return await _db.updateUserInfo(userInfo);
  }

  // 插入新用户信息
  Future<String> insertUserInfo(UserInfo userInfo) async {
    return await _db.insertUserInfo(userInfo);
  }

  // 获取当前用户信息
  Future<UserInfo?> getCurrentUser() async {
    final userId = await getLocal('current_user_id');
    if (userId == null) return null;
    return await getUserInfo(userId);
  }

  // 设置当前用户
  Future<void> setCurrentUser(String userId) async {
    await setLocal('current_user_id', userId);
  }

  // 清除当前用户
  Future<void> clearCurrentUser() async {
    await removeLocal('current_user_id');
  }
}
