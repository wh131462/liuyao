import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class EPUBScreen extends StatefulWidget {
  final String path;
  final String name;

  const EPUBScreen({
    Key? key,
    required this.path,
    required this.name,
  }) : super(key: key);

  @override
  State<EPUBScreen> createState() => _EPUBScreenState();
}

class _EPUBScreenState extends State<EPUBScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEpub();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.name),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEpub,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载...'),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<String> _prepareEpubFile() async {
    final isAsset = widget.path.startsWith('assets/');
    if (!isAsset) {
      return widget.path;
    }

    // 如果是 asset 文件，需要先复制到本地
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basename(widget.path);
    final localPath = path.join(tempDir.path, fileName);

    // 检查文件是否已存在
    final file = File(localPath);
    if (!await file.exists()) {
      // 从 asset 复制文件
      final data = await rootBundle.load(widget.path);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes);
    }

    return localPath;
  }

  Future<void> _loadEpub() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filePath = await _prepareEpubFile();
      final file = File(filePath);
      if (!await file.exists()) {
        throw '文件不存在';
      }

      // 配置阅读器
      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "epub_reader",
        scrollDirection: EpubScrollDirection.HORIZONTAL,
        allowSharing: true,
        enableTts: false,
      );
      
      // 打开电子书
      if (!mounted) return;
      await VocsyEpub.openAsset(filePath);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}