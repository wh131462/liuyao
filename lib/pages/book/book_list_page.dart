import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';
import '../../constants/book.list.dart';
import '../../models/book.dart';
import 'book_cover.dart';
import 'epub_screen.dart';
import 'pdf_screen.dart';

class BookListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      canBack: true,
      title: '书籍列表',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showImportDialog(context),
        ),
      ],
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
          return SizedBox(
            height: 240,
            child: BookCover(
              book: book,
              onTap: () => _openBook(context, book),
            ),
          );
        },
        itemCount: bookList.length,
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
                // _importFromUrl(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("开发中,敬请期待~")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('从本地文件导入'),
              onTap: () {
                Navigator.pop(context);
                // _importFromFile(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("开发中,敬请期待~")),
                );
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
    if (book.path == null || book.path!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开文件：路径为空')),
      );
      return;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => book.path!.endsWith("pdf") 
              ? PDFScreen(path: book.path!, name: book.name)
              : EPUBScreen(path: book.path!, name: book.name),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开文件失败：$e')),
      );
    }
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return ListTile(
      onTap: () {
        if (book.path == null) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => book.path!.toLowerCase().endsWith('.pdf')
              ? PDFScreen(path: book.path!, name: book.name)
              : EPUBScreen(path: book.path!, name: book.name),
          ),
        );
      },
      // ... 其他代码保持不变
    );
  }
} 