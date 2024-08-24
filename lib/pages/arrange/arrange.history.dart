import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:provider/provider.dart';
import '../../store/schemas.dart';
import '../../store/store.dart';

class ArrangeHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storeService = context.watch<StoreService>();
    final List<HistoryItem> historyItems = storeService.getAll<HistoryItem>();

    return Scaffold(
      appBar: AppBar(
        title: Text('历史记录'),
      ),
      body: historyItems.isEmpty
          ? Center(child: Text('暂无历史记录'))
          : ListView.builder(
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return HistoryItemCard(item: item);
        },
      ),
    );
  }
}

class HistoryItemCard extends StatelessWidget {
  final HistoryItem item;

  HistoryItemCard({required this.item});

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  // 假设有一个方法可以根据 originAnswer 获取卦象的名称
  String _getHexagramName(String originAnswer) {
    // 这里需要根据你的实际逻辑来实现获取卦象名称的方法
    return "卦象名称"; // 示例返回值，需替换为实际逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '问题: ${item.question}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '结果本卦: ${_getHexagramName(item.originAnswer)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '时间: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(item.timestamp))}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
