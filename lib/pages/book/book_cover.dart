import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/book.dart';

class BookCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;

  const BookCover({
    Key? key,
    required this.book,
    this.width = 120,
    this.height = 160,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureBuilder<String?>(
              future: book.getCoverUrl(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final coverUrl = snapshot.data!;
                  if (coverUrl.startsWith('assets/')) {
                    return Image.asset(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
                    );
                  } else if (coverUrl.startsWith('/')) {
                    return Image.file(
                      File(coverUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
                    );
                  } else {
                    return Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
                    );
                  }
                }
                return _buildDefaultCover();
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getFileTypeColor(book.path),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getFileType(book.path),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getFileType(String? path) {
    if (path == null) return '';
    if (path.toLowerCase().endsWith('.pdf')) return 'PDF';
    if (path.toLowerCase().endsWith('.epub')) return 'EPUB';
    return path.split('.').last.toUpperCase();
  }

  Color _getFileTypeColor(String? path) {
    if (path == null) return Colors.grey;
    if (path.toLowerCase().endsWith('.pdf')) {
      return Colors.red.shade700;
    }
    if (path.toLowerCase().endsWith('.epub')) {
      return Colors.blue.shade700;
    }
    return Colors.grey;
  }
} 