import 'package:uuid/uuid.dart';
import '../models/history_item.dart';
import '../services/database_service.dart';

class HistoryService {
  final DatabaseService _db;

  HistoryService(this._db);

  // 添加历史记录
  Future<HistoryItem> addHistory({
    required String question,
    required String answer,
    String? note,
    String? analysis,
    String? conclusion,
    String? tags,
  }) async {
    final item = HistoryItem(
      id: const Uuid().v4(),
      question: question,
      originAnswer: answer,
      note: note,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      analysis: analysis,
      conclusion: conclusion,
      tags: tags,
    );

    await _db.insertHistory(item);
    return item;
  }

  // 获取所有历史记录
  Future<List<HistoryItem>> getAllHistory() {
    return _db.getAllHistory();
  }

  // 获取单条记录
  Future<HistoryItem?> getHistoryById(String id) {
    return _db.getHistoryById(id);
  }

  // 更新记录
  Future<void> updateHistory(HistoryItem item) async {
    await _db.updateHistory(item);
  }

  // 删除记录
  Future<void> deleteHistory(String id) async {
    await _db.deleteHistory(id);
  }

  // 搜索历史记录
  Future<List<HistoryItem>> searchHistory(String keyword) async {
    final allHistory = await getAllHistory();
    return allHistory.where((item) =>
      item.question.contains(keyword) ||
      item.originAnswer.contains(keyword) ||
      (item.note?.contains(keyword) ?? false) ||
      (item.analysis?.contains(keyword) ?? false) ||
      (item.conclusion?.contains(keyword) ?? false) ||
      (item.tags?.contains(keyword) ?? false)
    ).toList();
  }

  // 按标签查询
  Future<List<HistoryItem>> getHistoryByTag(String tag) async {
    final allHistory = await getAllHistory();
    return allHistory.where((item) =>
      item.tagList.contains(tag)
    ).toList();
  }

  // 按时间范围查询
  Future<List<HistoryItem>> getHistoryByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allHistory = await getAllHistory();
    return allHistory.where((item) =>
      item.createdAt.isAfter(start) &&
      item.createdAt.isBefore(end)
    ).toList();
  }
} 