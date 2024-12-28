import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/history_item.dart';
import '../../store/store.dart';
import 'item.card.dart';

class ArrangeHistory extends StatefulWidget {
  @override
  _ArrangeHistoryState createState() => _ArrangeHistoryState();
}

class _ArrangeHistoryState extends State<ArrangeHistory> {
  List<HistoryItem> historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryItems();
  }

  Future<void> _loadHistoryItems() async {
    try {
      final storeService = context.read<StoreService>();
      final items = await storeService.getAllHistoryItems();
      setState(() {
        historyItems = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载历史记录失败: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('历史记录'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : historyItems.isEmpty
              ? Center(child: Text('暂无历史记录'))
              : ListView.builder(
                  itemCount: historyItems.length,
                  itemBuilder: (context, index) {
                    final item = historyItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: HistoryItemCard(
                        item: item,
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('确认删除'),
                                content: Text('你确定要删除这个条目吗？'),
                                actions: [
                                  TextButton(
                                    child: Text('取消'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('删除'),
                                    onPressed: () async {
                                      final storeService = context.read<StoreService>();
                                      await storeService.delete<HistoryItem>(item);
                                      Navigator.of(context).pop();
                                      await _loadHistoryItems(); // 重新加载数据
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
