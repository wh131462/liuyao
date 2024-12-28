import 'package:flutter/material.dart';
import '../../models/history_item.dart';
import 'package:intl/intl.dart';

class HistoryDetailSheet extends StatelessWidget {
  final HistoryItem item;
  final ScrollController? scrollController;

  const HistoryDetailSheet({
    Key? key,
    required this.item,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '问题详情',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSection('问题', item.question),
                    _buildSection('卦象', item.originAnswer),
                    if (item.analysis != null)
                      _buildSection('分析', item.analysis!),
                    if (item.conclusion != null)
                      _buildSection('结论', item.conclusion!),
                    if (item.note != null && item.note!.isNotEmpty)
                      _buildSection('笔记', item.note!),
                    if (item.tags != null && item.tags!.isNotEmpty)
                      _buildTagsSection(context),
                    const SizedBox(height: 16),
                    Text(
                      '创建时间：${_formatDateTime(item.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(content),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标签',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: item.tagList.map((tag) => Chip(
            label: Text(tag),
          )).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
} 