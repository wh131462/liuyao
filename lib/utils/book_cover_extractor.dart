import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as path;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'dart:typed_data';

class BookCoverExtractor {
  static Future<String?> extractCover(String filePath) async {
    final extension = path.extension(filePath).toLowerCase();
    
    try {
      if (extension == '.pdf') {
        return await _extractPdfCover(filePath);
      } else if (extension == '.epub') {
        return await _extractEpubCover(filePath);
      }
    } catch (e) {
      print('Error extracting cover: $e');
    }
    return null;
  }

  static Future<String?> _extractPdfCover(String pdfPath) async {
    pdf_render.PdfDocument? doc;
    try {
      // 创建临时目录来保存封面图片
      final tempDir = await getTemporaryDirectory();
      final coverPath = path.join(tempDir.path, 'covers', path.basename(pdfPath) + '_cover.jpg');
      
      // 确保目录存在
      await Directory(path.dirname(coverPath)).create(recursive: true);

      // 如果封面已经存在，直接返回
      if (await File(coverPath).exists()) {
        return coverPath;
      }

      // 使用 pdf_render 加载 PDF
      doc = await pdf_render.PdfDocument.openFile(pdfPath);
      final page = await doc.getPage(1);
      
      // 渲染页面为图片
      final pageImage = await page.render(
        width: page.width.toInt(),
        height: page.height.toInt(),
      );
      
      if (pageImage != null) {
        // 直接保存图片数据
        await File(coverPath).writeAsBytes(pageImage.pixels);
        return coverPath;
      }
      
      return null;
    } catch (e) {
      print('Error extracting PDF cover: $e');
      return null;
    } finally {
      // 确保在完成后释放资源
      doc?.dispose();
    }
  }

  static Future<String?> _extractEpubCover(String epubPath) async {
    try {
      // 创建临时目录来保存封面图片
      final tempDir = await getTemporaryDirectory();
      final coverPath = path.join(tempDir.path, 'covers', path.basename(epubPath) + '_cover.jpg');
      
      // 确保目录存在
      await Directory(path.dirname(coverPath)).create(recursive: true);

      // 如果封面已经存在，直接返回
      if (await File(coverPath).exists()) {
        return coverPath;
      }

      final bytes = await File(epubPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // 尝试常见的封面文件路径
      final possibleCoverPaths = [
        'OEBPS/Images/cover.jpg',
        'OEBPS/images/cover.jpg',
        'OPS/images/cover.jpg',
        'cover.jpg',
      ];

      for (final coverFilePath in possibleCoverPaths) {
        final coverFile = archive.findFile(coverFilePath);
        if (coverFile != null) {
          // 保存封面图片
          await File(coverPath).writeAsBytes(coverFile.content as List<int>);
          return coverPath;
        }
      }
    } catch (e) {
      print('Error extracting EPUB cover: $e');
    }
    return null;
  }
} 