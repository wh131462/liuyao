import 'dart:io';
import '../constants/book.list.dart';
import '../utils/book_cover_extractor.dart';
import '../core/file/file_manager.dart';

class Book {
  final String? path;
  final String name;
  final double size;  // 文件大小（MB）
  final DateTime? lastRead;  // 最后阅读时间
  final double progress;  // 阅读进度 (0.0 - 1.0)

  Book({
    this.path,
    required this.name,
    this.size = 0.0,
    this.lastRead,
    this.progress = 0.0,
  });

  // 从 BookDicItem 创建 Book 对象
  factory Book.fromBookDicItem(BookDicItem item) {
    return Book(
      path: item.path,
      name: item.name,
      size: 0.0,  // 转换为 MB
    );
  }

  // 从 Map 创建 Book 对象
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      path: map['path'] as String?,
      name: map['name'] as String,
      size: (map['size'] as num?)?.toDouble() ?? 0.0,
      lastRead: map['lastRead'] != null 
          ? DateTime.parse(map['lastRead'] as String) 
          : null,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'name': name,
      'size': size,
      'lastRead': lastRead?.toIso8601String(),
      'progress': progress,
    };
  }
} 