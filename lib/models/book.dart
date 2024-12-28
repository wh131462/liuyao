import '../constants/book.list.dart';
import '../utils/book_cover_extractor.dart';
import '../core/file/file_manager.dart';

class Book {
  final String id;
  final String title;
  final String? coverUrl;
  final String? author;
  final String? description;
  final String? path;
  final String? name;
  final DateTime addedDate;
  String? _extractedCoverPath;

  Book({
    required this.id,
    required this.title,
    this.coverUrl,
    this.author,
    this.description,
    this.path,
    this.name,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  factory Book.fromBookDicItem(BookDicItem item) {
    return Book(
      id: item.path,
      title: item.name,
      path: FileManager.getBookPath(item.path),
      name: item.name,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String?,
      author: json['author'] as String?,
      description: json['description'] as String?,
      path: json['path'] as String?,
      name: json['name'] as String?,
      addedDate: json['addedDate'] != null 
          ? DateTime.parse(json['addedDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverUrl': coverUrl,
      'author': author,
      'description': description,
      'path': path,
      'name': name,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  Future<String?> getCoverUrl() async {
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return coverUrl;
    }
    
    // 如果已经提取过封面，直接返回
    if (_extractedCoverPath != null) {
      return _extractedCoverPath;
    }

    // 尝试从文件中提取封面
    if (path != null && path!.isNotEmpty) {
      _extractedCoverPath = await BookCoverExtractor.extractCover(path!);
      return _extractedCoverPath;
    }

    return null;
  }
} 