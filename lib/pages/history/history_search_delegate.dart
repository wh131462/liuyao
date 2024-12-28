import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/history_item.dart';

class HistorySearchDelegate extends SearchDelegate<HistoryItem> {
  final List<HistoryItem> historyItems;

  HistorySearchDelegate(this.historyItems);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, HistoryItem(
          id: '',
          question: '',
          originAnswer: '',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('输入关键词搜索历史记录'),
      );
    }

    final results = historyItems.where((item) {
      final questionMatch = item.question.toLowerCase().contains(query.toLowerCase());
      final answerMatch = item.originAnswer.toLowerCase().contains(query.toLowerCase());
      final noteMatch = item.note?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final analysisMatch = item.analysis?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final conclusionMatch = item.conclusion?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final tagsMatch = item.tags?.toLowerCase().contains(query.toLowerCase()) ?? false;
      
      return questionMatch || answerMatch || noteMatch || 
             analysisMatch || conclusionMatch || tagsMatch;
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('没有找到匹配的记录'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item.question),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.originAnswer,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.tags != null && item.tags!.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: item.tagList.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
            ],
          ),
          trailing: Text(
            _formatDate(item.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {
            close(context, item);
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
} 