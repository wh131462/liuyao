import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/book.list.dart';
import 'epub_screen.dart';
import 'pdf_screen.dart';

class BookList extends StatefulWidget {
  @override
  _BookList createState() {
    return _BookList();
  }
}

class _BookList extends State<BookList> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(
            '古籍阅读',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [],
          backgroundColor: Colors.indigo, // 修改AppBar背景颜色
        ),
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: bookList.length,
            itemBuilder: (context, index) {
              return TextButton(
                child: Text(bookList[index].name),
                onPressed: () {
                  if (bookList[index].path.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        bookList[index].path.endsWith("pdf") ? PDFScreen(
                            path: bookList[index].path,
                            name: bookList[index].name) :
                        EPUBScreen(path: bookList[index].path,
                            name: bookList[index].name),
                      ),
                    );
                  }
                },
              );
            }));
  }
}


