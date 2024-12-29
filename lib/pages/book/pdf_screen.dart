import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../core/reading/reading_progress.dart';
import '../../core/reading/reading_settings.dart';
import '../../widgets/reading/reading_settings_panel.dart';
import '../../widgets/reading/reading_drawer.dart';
import '../../widgets/reading/outline_panel.dart';
import 'package:syncfusion_flutter_pdf/src/pdf/implementation/pdf_document/outlines/pdf_outline.dart';

class PDFScreen extends StatefulWidget {
  final String path;
  final String name;

  const PDFScreen({
    Key? key,
    required this.path,
    required this.name,
  }) : super(key: key);

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  int? _totalPages;
  int _currentPage = 0;
  ScrollMode _scrollMode = ScrollMode.vertical;
  double _brightness = 1.0;
  double _fontSize = 18.0;
  bool _showControls = true;
  List<int> _bookmarks = [];
  PdfDocumentLoadedDetails? _documentDetails;
  PdfViewerController _pdfViewerController = PdfViewerController();
  DateTime _currentTime = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _zoomLevel = 1.0;
  ScreenBrightness? _screenBrightness;
  bool _hasInitialJump = false;
  PdfBookmarkBase? _bookmarkList;
  Map<int, String> _bookmarkTitles = {};
  bool _isTouchHandled = false;
  Offset? _touchStartPosition;
  DateTime? _touchStartTime;
  bool _isDarkMode = false;

  Color get _backgroundColor =>
      _isDarkMode ? const Color(0xFF333333) : Colors.white;

  Color get _textColor => _isDarkMode ? Colors.white : Colors.black;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _hasInitialJump = false;
    _isLoading = true;
    _error = null;
    _documentDetails = null;
    _isDarkMode = false;
    _brightness = 1.0;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_showControls) {
      _animationController.value = 1.0;
    }

    _loadSettings();
    _startTimeUpdates();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    _initBrightness();
    _loadBookmarkTitles();
  }

  Future<void> _loadSettings() async {
    try {
      final savedPage = await ReadingProgress.getProgress(widget.path);
      final savedBookmarks = await ReadingProgress.getBookmarks(widget.path);
      final savedScrollMode = await ReadingSettings.getScrollMode();
      final savedBrightness = await ReadingSettings.getBrightness();
      final savedFontSize = await ReadingSettings.getFontSize();
      final savedDarkMode = await ReadingSettings.getDarkMode();

      if (mounted) {
        setState(() {
          _currentPage = savedPage;
          _bookmarks = savedBookmarks;
          _scrollMode = savedScrollMode;
          _brightness = savedBrightness;
          _fontSize = savedFontSize;
          _isDarkMode = savedDarkMode;
          if (_scrollMode == ScrollMode.horizontal ||
              _scrollMode == ScrollMode.vertical) {
          } else {}
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  void _startTimeUpdates() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _startTimeUpdates();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showJumpToPageDialog() {
    if (_totalPages == null) return;

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('跳转到页面'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '请输入页码 (1-$_totalPages)',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages!) {
                _pdfViewerController.jumpToPage(page);
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark() {
    if (_bookmarks.contains(_currentPage)) {
      setState(() {
        _bookmarks.remove(_currentPage);
        ReadingProgress.saveBookmarks(widget.path, _bookmarks);
      });
    } else {
      _showAddBookmarkDialog();
    }
  }

  void _showAddBookmarkDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: _isDarkMode ? const Color(0xFF333333) : Colors.white,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: _textColor,
                displayColor: _textColor,
              ),
        ),
        child: AlertDialog(
          title: Text('添加书签', style: TextStyle(color: _textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('第 ${_currentPage + 1} 页',
                  style: TextStyle(color: _textColor)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: '书签标题',
                  hintText: '请输入书签标题',
                  labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: _textColor.withOpacity(0.3)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _textColor),
                  ),
                ),
                style: TextStyle(color: _textColor),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(color: _textColor)),
            ),
            TextButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    _bookmarks.add(_currentPage);
                    _bookmarkTitles[_currentPage] = title;
                    ReadingProgress.saveBookmarks(
                      widget.path,
                      _bookmarks,
                      _bookmarkTitles,
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: Text('确定', style: TextStyle(color: _textColor)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarksDialog() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext dialogContext) => Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: _backgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: _textColor,
                displayColor: _textColor,
              ),
        ),
        child: Dialog(
          alignment: Alignment.centerRight,
          insetPadding: EdgeInsets.zero,
          backgroundColor: _backgroundColor,
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.85,
            height: double.infinity,
            child: ReadingDrawer(
              type: DrawerType.bookmarks,
              title: '书签管理',
              controller: _pdfViewerController,
              documentDetails: _documentDetails!,
              bookmarks: _bookmarks,
              bookmarkTitles: _bookmarkTitles,
              isDarkMode: _isDarkMode,
              onDeleteBookmark: (index) {
                setState(() {
                  final pageNumber = _bookmarks[index];
                  _bookmarks.removeAt(index);
                  _bookmarkTitles.remove(pageNumber);
                  ReadingProgress.saveBookmarks(
                    widget.path,
                    _bookmarks,
                    _bookmarkTitles,
                  );
                });
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: _backgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: _textColor,
                displayColor: _textColor,
              ),
          chipTheme: Theme.of(context).chipTheme.copyWith(
                backgroundColor: _isDarkMode ? Colors.grey[800] : null,
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(color: _textColor),
              ),
          sliderTheme: Theme.of(context).sliderTheme.copyWith(
                activeTrackColor: Theme.of(context).primaryColor,
                thumbColor: Theme.of(context).primaryColor,
                inactiveTrackColor:
                    _isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ReadingSettingsPanel(
              currentScrollMode: _scrollMode,
              currentBrightness: _brightness,
              isDarkMode: _isDarkMode,
              textColor: _textColor,
              onScrollModeChanged: (mode) async {
                setState(() => _scrollMode = mode);
                setModalState(() {});
                await ReadingSettings.setScrollMode(mode);

                final currentPageNumber = _currentPage + 1;
                Future.microtask(() {
                  if (mounted) {
                    _pdfViewerController.jumpToPage(currentPageNumber);
                  }
                });
              },
              onBrightnessChanged: (value) async {
                setState(() => _brightness = value);
                setModalState(() {});
                await _screenBrightness?.setScreenBrightness(value);
                await ReadingSettings.setBrightness(value);
              },
            );
          },
        ),
      ),
    );
  }

  void _showOutlinePanel() {
    if (_documentDetails == null) return;

    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: _backgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: _textColor,
                displayColor: _textColor,
              ),
        ),
        child: Dialog(
          alignment: Alignment.centerLeft,
          insetPadding: EdgeInsets.zero,
          backgroundColor: _backgroundColor,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            child: OutlinePanel(
              controller: _pdfViewerController,
              bookmarks: _bookmarkList,
              onClose: () => Navigator.pop(context),
              isDarkMode: _isDarkMode,
            ),
          ),
        ),
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pdfViewerController.jumpToPage(_currentPage);
    }
  }

  void _goToNextPage() {
    if (_totalPages != null && _currentPage < _totalPages! - 1) {
      _pdfViewerController.jumpToPage(_currentPage + 2);
    }
  }

  void _handleDocumentLoaded(PdfDocumentLoadedDetails details) {
    if (!mounted || _documentDetails != null) return;

    setState(() {
      _documentDetails = details;
      _totalPages = details.document.pages.count;
      _bookmarkList = details.document.bookmarks;
      _isLoading = false;
      print('Bookmarks loaded: ${_bookmarkList?.count}');
    });

    if (_currentPage > 0 && !_hasInitialJump) {
      _hasInitialJump = true;
      _pdfViewerController.jumpToPage(_currentPage + 1);
    }
  }

  void _handleDocumentLoadFailed(details) {
    if (mounted) {
      setState(() {
        _error = details.error;
        _isLoading = false;
      });
    }
  }

  void _handlePageChanged(details) {
    if (mounted && details.newPageNumber - 1 != _currentPage) {
      setState(() {
        _currentPage = details.newPageNumber - 1;
      });
      ReadingProgress.saveProgress(widget.path, _currentPage);
    }
  }

  void _showPageJumpDialog() {
    final controller =
        TextEditingController(text: (_currentPage + 1).toString());

    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: _backgroundColor,
        ),
        child: AlertDialog(
          title: Text('跳转到页面', style: TextStyle(color: _textColor)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '页码',
              labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _textColor.withOpacity(0.3)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _textColor),
              ),
            ),
            style: TextStyle(color: _textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(color: _textColor)),
            ),
            TextButton(
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null && page > 0 && page <= _totalPages!) {
                  _pdfViewerController.jumpToPage(page);
                }
                Navigator.pop(context);
              },
              child: Text('确定', style: TextStyle(color: _textColor)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadBookmarkTitles() async {
    final titles = await ReadingProgress.getBookmarkTitles(widget.path);
    setState(() {
      _bookmarkTitles = titles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          SfPdfViewer.file(
            File(widget.path),
            controller: _pdfViewerController,
            key: ValueKey(widget.path),
            onDocumentLoaded: _handleDocumentLoaded,
            onDocumentLoadFailed: _handleDocumentLoadFailed,
            onPageChanged: _handlePageChanged,
            scrollDirection: _scrollMode == ScrollMode.horizontal ||
                    _scrollMode == ScrollMode.horizontalScroll
                ? PdfScrollDirection.horizontal
                : PdfScrollDirection.vertical,
            enableDoubleTapZooming: false,
            enableTextSelection: false,
            canShowScrollHead: false,
            pageLayoutMode: PdfPageLayoutMode.single,
            canShowPaginationDialog: false,
            pageSpacing: 0,
            initialZoomLevel: 1.0,
            interactionMode: PdfInteractionMode.pan,
          ),
          // 控制栏
          _buildControls(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _screenBrightness?.resetScreenBrightness();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Future<void> _initBrightness() async {
    try {
      _screenBrightness = ScreenBrightness();
      final savedBrightness = await ReadingSettings.getBrightness();
      setState(() => _brightness = savedBrightness);
      await _screenBrightness?.setScreenBrightness(savedBrightness);
    } catch (e) {
      print('Error initializing brightness: $e');
    }
  }

  Widget _buildControls() {
    return Column(
      children: [
        // 顶部控制栏
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: _isDarkMode
                ? const Color(0xFF333333)
                : Theme.of(context).primaryColor,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '返回',
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_totalPages != null)
                          GestureDetector(
                            onTap: () => _showPageJumpDialog(),
                            child: Text(
                              '${_currentPage + 1}/$_totalPages',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _bookmarks.contains(_currentPage)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: _toggleBookmark,
                    tooltip: '添加书签',
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmarks, color: Colors.white),
                    onPressed: _showBookmarksDialog,
                    tooltip: '书签管理',
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        // 底部控制栏
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: _isDarkMode
                ? const Color(0xFF333333)
                : Theme.of(context).primaryColor,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: _showOutlinePanel,
                    tooltip: '目录',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: _showSettingsPanel,
                    tooltip: '阅读设置',
                  ),
                  IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      setState(() {
                        _isDarkMode = !_isDarkMode;
                      });
                      await ReadingSettings.setDarkMode(_isDarkMode);
                    },
                    tooltip: '夜间模式',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
