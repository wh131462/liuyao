import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';
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
  bool _isLoading = false;
  final _scrollController = ScrollController();
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => _loadHistory());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadMoreHistory();
      }
    }
  }

  Future<void> _loadHistory() async {
    if (_isLoading) {
      print('Already loading, skipping...');
      return;
    }

    print('Starting to load history...');
    setState(() => _isLoading = true);

    try {
      final storeService = context.read<StoreService>();
      print('Fetching history items for page $_currentPage');
      final items = await storeService.getHistoryItems(
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      print('Loaded ${items.length} items');
      if (mounted) {
        setState(() {
          _historyItems = items;
          _hasMore = items.length >= _pageSize;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading history: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载历史记录失败: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final storeService = context.read<StoreService>();
      final items = await storeService.getHistoryItems(
        page: _currentPage + 1,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _historyItems.addAll(items);
          _currentPage++;
          _hasMore = items.length >= _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading more history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载更多记录失败: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showHistoryDetail(HistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => HistoryDetailSheet(item: item),
    );
  }

  Widget _buildListItem(HistoryItem item, int index) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete_outline, color: Colors.red),
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text('确认删除'),
              content: const Text('确定要删除这条记录吗？'),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('删除'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ) ?? false;
        }
        return false;
      },
      onDismissed: (direction) async {
        final storeService = context.read<StoreService>();
        await storeService.delete<HistoryItem>(item);
        setState(() {
          _historyItems.removeAt(index);
        });
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showHistoryDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(item.timestamp)
                          .toString()
                          .substring(0, 16),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.originAnswer,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                if (item.tags?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: item.tagList.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '历史记录',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: HistorySearchDelegate(_historyItems),
            );
          },
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: Stack(
          children: [
            if (_historyItems.isEmpty && !_isLoading)
              const Center(
                child: Text('暂无历史记录'),
              )
            else
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollEndNotification &&
                      scrollInfo.metrics.extentAfter == 0 &&
                      !_isLoading &&
                      _hasMore) {
                    _loadMoreHistory();
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) => _buildListItem(_historyItems[index], index),
                ),
              ),
            if (_isLoading)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 