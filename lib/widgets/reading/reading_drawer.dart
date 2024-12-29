import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

enum DrawerType {
  outline,
  bookmarks,
}

class ReadingDrawer extends StatelessWidget {
  final DrawerType type;
  final String title;
  final PdfViewerController controller;
  final PdfDocumentLoadedDetails documentDetails;
  final List<int> bookmarks;
  final Function(int)? onDeleteBookmark;
  final Map<int, String>? bookmarkTitles;
  final bool isDarkMode;

  const ReadingDrawer({
    Key? key,
    required this.type,
    required this.title,
    required this.controller,
    required this.documentDetails,
    required this.bookmarks,
    this.onDeleteBookmark,
    this.bookmarkTitles,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode ? const Color(0xFF333333) : Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: type == DrawerType.outline
                ? _buildOutline(context)
                : _buildBookmarks(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOutline(BuildContext context) {
    final document = documentDetails.document;

    try {
      if (document.pages.count > 0) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: document.pages.count,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('第 ${index + 1} 页',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              onTap: () {
                controller.jumpToPage(index + 1);
                Navigator.pop(context);
              },
            );
          },
        );
      }
    } catch (e) {
      print('Error loading document structure: $e');
    }

    return const Center(
      child: Text('无法加载文档结构', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildBookmarks(BuildContext context) {
    if (bookmarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无书签', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final pageNumber = bookmarks[index];
        final bookmarkTitle =
            bookmarkTitles?[pageNumber] ?? '第 ${pageNumber + 1} 页';

        return ListTile(
          title: Text(bookmarkTitle,
              style:
                  TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          subtitle: Text('第 ${pageNumber + 1} 页',
              style: TextStyle(color: Colors.grey)),
          onTap: () {
            controller.jumpToPage(pageNumber + 1);
            Navigator.pop(context);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDeleteBookmark?.call(index),
          ),
        );
      },
    );
  }
}
