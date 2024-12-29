import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/src/pdf/implementation/pdf_document/outlines/pdf_outline.dart';
import 'package:syncfusion_flutter_pdf/src/pdf/implementation/pages/pdf_page.dart';
import 'package:syncfusion_flutter_pdf/src/pdf/implementation/pages/pdf_section.dart';

class OutlinePanel extends StatelessWidget {
  final PdfViewerController controller;
  final PdfBookmarkBase? bookmarks;
  final VoidCallback onClose;
  final bool isDarkMode;

  const OutlinePanel({
    Key? key,
    required this.controller,
    this.bookmarks,
    required this.onClose,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      color: isDarkMode ? const Color(0xFF333333) : Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Text(
                  '目录',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: bookmarks == null || bookmarks!.count == 0
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无目录', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _buildBookmarkList(bookmarks!),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList(PdfBookmarkBase bookmarks) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bookmarks.count,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _buildBookmarkTile(bookmark);
      },
    );
  }

  Widget _buildBookmarkTile(PdfBookmarkBase bookmark) {
    return ListTile(
      title: Text(_getBookmarkTitle(bookmark)),
      onTap: () {
        if (bookmark is PdfBookmark) {
          controller.jumpToBookmark(bookmark);
          onClose();
        }
      },
      subtitle: bookmark.count > 0 ? _buildBookmarkList(bookmark) : null,
    );
  }

  String _getBookmarkTitle(PdfBookmarkBase bookmark) {
    try {
      return bookmark.toString();
    } catch (e) {
      print('Error getting bookmark title: $e');
      return '未知标题';
    }
  }

  int? _getBookmarkPageNumber(PdfBookmarkBase bookmark) {
    try {
      if (bookmark is PdfBookmark) {}
      return null;
    } catch (e) {
      print('Error getting bookmark page number: $e');
      return null;
    }
  }
}
