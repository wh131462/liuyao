import 'package:flutter/material.dart';
import '../../constants/book.list.dart';
import '../../models/book.dart';
import 'book_cover.dart';
import 'epub_screen.dart';
import 'pdf_screen.dart';

class BookListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书籍列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showImportDialog(context),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final bookDicItem = bookList[index];
          final book = Book.fromBookDicItem(bookDicItem);
          return InkWell(
            onTap: () => _openBook(context, book),
            child: Column(
              children: [
                BookCover(
                  book: book,
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: bookList.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImportDialog(context),
        child: const Icon(Icons.add),
        tooltip: '导入新书',
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('从网址导入'),
              onTap: () {
                Navigator.pop(context);
                _importFromUrl(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('从本地文件导入'),
              onTap: () {
                Navigator.pop(context);
                _importFromFile(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _importFromUrl(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('从网址导入'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: '请输入书籍链接',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (url) {
            // TODO: 处理URL导入逻辑
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 处理URL导入逻辑
              Navigator.pop(context);
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromFile(BuildContext context) async {
    // TODO: 实现文件导入逻辑
  }

  void _openBook(BuildContext context, Book book) {
    if (book.path != null && book.path!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => book.path!.endsWith("pdf") 
              ? PDFScreen(path: book.path!, name: book.name ?? book.title)
              : EPUBScreen(path: book.path!, name: book.name ?? book.title),
        ),
      );
    }
  }
} 