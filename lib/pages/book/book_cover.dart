import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/book.dart';
import 'package:intl/intl.dart';

class BookCover extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCover({
    Key? key,
    required this.book,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPdf = book.path?.toLowerCase().endsWith('.pdf') ?? false;
    
    final Color baseColor = isPdf 
        ? (isDark ? const Color(0xFF1A4B7C) : const Color(0xFFE3F2FD))
        : (isDark ? const Color(0xFF4B1A44) : const Color(0xFFF3E5F5));

    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Card(
      elevation: 4,
      color: baseColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件类型标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPdf 
                      ? (isDark ? Colors.blue[900] : Colors.blue[100])
                      : (isDark ? Colors.purple[900] : Colors.purple[100]),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPdf ? 'PDF' : 'EPUB',
                  style: TextStyle(
                    color: isPdf 
                        ? (isDark ? Colors.blue[100] : Colors.blue[900])
                        : (isDark ? Colors.purple[100] : Colors.purple[900]),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 书名
              Expanded(
                child: Text(
                  book.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // 底部信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${book.size.toStringAsFixed(1)}MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '上次阅读: ${_formatDate(book.lastRead)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                  
                  if (book.progress > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: book.progress,
                      backgroundColor: isDark ? Colors.black12 : Colors.white54,
                      valueColor: AlwaysStoppedAnimation(
                        isPdf 
                            ? (isDark ? Colors.blue[300] : Colors.blue)
                            : (isDark ? Colors.purple[300] : Colors.purple),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未读';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
} 