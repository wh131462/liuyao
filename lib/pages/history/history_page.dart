import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/history_item.dart';
import '../../store/store.dart';
import 'history_detail_sheet.dart';
import 'history_search_delegate.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final storeService = context.read<StoreService>();
      final items = await storeService.getAllHistoryItems();
      setState(() {
        _historyItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载历史记录失败: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _showHistoryDetail(HistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryDetailSheet(item: item),
    );
  }

  Future<void> _handleSearch() async {
    final selected = await showSearch(
      context: context,
      delegate: HistorySearchDelegate(_historyItems),
    );
    
    if (selected != null && selected.id.isNotEmpty) {
      if (mounted) {
        _showHistoryDetail(selected);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('暂无历史记录'),
            TextButton(
              onPressed: _loadHistory,
              child: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _handleSearch,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView.builder(
          itemCount: _historyItems.length,
          itemBuilder: (context, index) {
            final item = _historyItems[index];
            return ListTile(
              title: Text(item.question),
              subtitle: Text(
                item.originAnswer,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('确认删除'),
                      content: const Text('确定要删除这条记录吗？'),
                      actions: [
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child: const Text('删除'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final storeService = context.read<StoreService>();
                    await storeService.delete<HistoryItem>(item);
                    await _loadHistory();
                  }
                },
              ),
              onTap: () => _showHistoryDetail(item),
            );
          },
        ),
      ),
    );
  }
} 