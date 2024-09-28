import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
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
  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  Map<int, File> fileMap = {};

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

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
              fromAsset(bookList[index].path, bookList[index].name)
                  .then((file) {
                setState(() {
                  fileMap[index] = file;
                });
              });
              return TextButton(
                child: Text(bookList[index].name),
                onPressed: () {
                  if (fileMap[index]!.path.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        bookList[index].path.endsWith("pdf") ? PDFScreen(
                            path: fileMap[index]!.path,
                            name: bookList[index].name) :
                        EPUBScreen(path: fileMap[index]!.path,
                            name: bookList[index].name),
                      ),
                    );
                  }
                },
              );
            }));
  }
}


