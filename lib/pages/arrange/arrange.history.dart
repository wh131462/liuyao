import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/schemas.dart';
import '../../store/store.dart';
import 'item.card.dart';

class ArrangeHistory extends StatefulWidget {
  @override
  _ArrangeHistoryState createState() => _ArrangeHistoryState();
}

class _ArrangeHistoryState extends State<ArrangeHistory> {
  late List<HistoryItem> historyItems;

  @override
  void initState() {
    super.initState();
    final storeService = context.read<StoreService>();
    historyItems = storeService.getAll<HistoryItem>();
  }

  @override
  Widget build(BuildContext context) {
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
                            Navigator.of(context).pop(); // 关闭弹窗
                          },
                        ),
                        TextButton(
                          child: Text('删除'),
                          onPressed: () {
                            final storeService = context.read<StoreService>();
                            storeService.delete<HistoryItem>(item);
                            Navigator.of(context).pop(); // 关闭弹窗
                            setState(() {
                              historyItems.remove(item); // 从列表中移除该项
                            });
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
