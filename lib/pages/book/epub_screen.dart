import 'package:flutter/material.dart';
import 'package:liuyao/utils/logger.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:liuyao/core/reading/reading_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class _EPUBScreenState extends State<EPUBScreen> with WidgetsBindingObserver{
  static const String _progressKeyPrefix = 'epub_progress_';
  bool _hasOpened = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
  }

  void _navigateToBookList() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/book',
          (route) => false,
    );
  }

  Future<void> _loadSettings() async {
    if (_hasOpened) return;

    final darkMode = await ReadingSettings.getDarkMode();
    final lastLocation = await _getLastLocation();

    // 配置阅读器
    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: widget.path,
      scrollDirection: EpubScrollDirection.VERTICAL,
      allowSharing: false,
      enableTts: false,
      nightMode: darkMode ?? false,
    );

    _openEpub(lastLocation);
  }

  Future<EpubLocator?> _getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString('$_progressKeyPrefix${widget.path}');
    if (locationJson == null) return null;

    try {
      final Map<String, dynamic> locationMap = json.decode(locationJson);
      return EpubLocator.fromJson(locationMap);
    } catch (e) {
      print('Error parsing saved location: $e');
      return null;
    }
  }

  Future<void> _saveLastLocation(String locationJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_progressKeyPrefix${widget.path}', locationJson);
  }

  Future<void> _openEpub([EpubLocator? lastLocation]) async {
    if (_hasOpened) return;
    _hasOpened = true;

    try {
      // 打开电子书
      if (widget.path.startsWith('assets/')) {
        await VocsyEpub.openAsset(
          widget.path,
          lastLocation: lastLocation,
        );
      } else {
        VocsyEpub.open(
          widget.path,
          lastLocation: lastLocation,
        );
      }

      // 监听阅读位置
      VocsyEpub.locatorStream.listen((locator) {
        if (locator != null) {
          _saveLastLocation(locator);
        }
      });

    } catch (e) {
      print('Error loading EPUB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        _navigateToBookList();
      }
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _navigateToBookList();
    }
  }

  @override
  void dispose() {
    _hasOpened = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Center(
          child: TextButton(onPressed: _navigateToBookList, child: Text('看到这个页面是不正常的,请点击关闭'))
        ),
      ),
    );
  }
}
