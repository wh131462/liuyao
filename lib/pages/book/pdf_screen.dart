import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liuyao/utils/logger.dart';
import 'package:logger/logger.dart';
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

class _OutlineItemState {
  bool isExpanded;

  _OutlineItemState({this.isExpanded = false});
}

class _PDFScreenState extends State<PDFScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  int? _totalPages;
  int _currentPage = 0;
  ScrollMode _scrollMode = ScrollMode.singleVertical;
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
  bool? _userSetDarkMode;
  late AnimationController _transitionController;
  late Animation<double> _transitionAnimation;
  final Map<String, _OutlineItemState> _outlineStates = {};

  Color get _backgroundColor =>
      _isDarkMode ? const Color(0xFF333333) : Colors.white;

  Color get _textColor => _isDarkMode ? Colors.white : Colors.black;

  bool get _isDarkMode {
    if (_userSetDarkMode != null) {
      return _userSetDarkMode!;
    }
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _hasInitialJump = false;
    _isLoading = true;
    _error = null;
    _documentDetails = null;
    _userSetDarkMode = false;
    _brightness = 1.0;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
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
    _loadDarkModeSetting();
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
          _userSetDarkMode = savedDarkMode;
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
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Row(
            children: [
              Icon(
                Icons.switch_access_shortcut,
                color: _textColor.withOpacity(0.85),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '跳转页面',
                style: TextStyle(
                  color: _textColor.withOpacity(0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '页码范围',
                style: TextStyle(
                  color: _textColor.withOpacity(0.45),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? const Color(0xFF2F2F2F)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 16,
                      color: _textColor.withOpacity(0.45),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '1 - $_totalPages',
                      style: TextStyle(
                        color: _textColor.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '目标页码',
                style: TextStyle(
                  color: _textColor.withOpacity(0.45),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '请输入页码',
                  hintStyle: TextStyle(
                    color: _textColor.withOpacity(0.25),
                    fontSize: 14,
                  ),
                  errorText: errorText,
                  errorStyle: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: _isDarkMode
                      ? const Color(0xFF2F2F2F)
                      : const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color:
                          _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color:
                          _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: _textColor.withOpacity(0.85),
                  fontSize: 14,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    _totalPages.toString().length,
                  ),
                ],
                onChanged: (value) {
                  final page = int.tryParse(value);
                  setState(() {
                    if (value.isEmpty) {
                      errorText = null;
                    } else if (page == null) {
                      errorText = '请输入有效数字';
                    } else if (page < 1 || page > _totalPages!) {
                      errorText = '页码超出范围';
                    } else {
                      errorText = null;
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: _textColor.withOpacity(0.45),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null && page >= 1 && page <= _totalPages!) {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('确定'),
            ),
            const SizedBox(width: 8),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Row(
          children: [
            Icon(
              Icons.bookmark_add,
              color: _textColor.withOpacity(0.85),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '添加书签',
              style: TextStyle(
                color: _textColor.withOpacity(0.85),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前页码显示
            Text(
              '当前页码',
              style: TextStyle(
                color: _textColor.withOpacity(0.45),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isDarkMode
                    ? const Color(0xFF2F2F2F)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: _textColor.withOpacity(0.45),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '第 ${_currentPage + 1} 页',
                    style: TextStyle(
                      color: _textColor.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 书签标题输入
            Row(
              children: [
                Text(
                  '书签标题',
                  style: TextStyle(
                    color: _textColor.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
                Text(
                  ' (可选)',
                  style: TextStyle(
                    color: _textColor.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '第 ${_currentPage + 1} 页',
                hintStyle: TextStyle(
                  color: _textColor.withOpacity(0.25),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: _isDarkMode
                    ? const Color(0xFF2F2F2F)
                    : const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
              ),
              style: TextStyle(
                color: _textColor.withOpacity(0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: _textColor.withOpacity(0.45),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              setState(() {
                _bookmarks.add(_currentPage);
                // 如果标题为空，使用页码作为默认标题
                _bookmarkTitles[_currentPage] =
                    title.isEmpty ? '第 ${_currentPage + 1} 页' : title;
                ReadingProgress.saveBookmarks(
                  widget.path,
                  _bookmarks,
                  _bookmarkTitles,
                );
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('确定'),
          ),
          const SizedBox(width: 8),
        ],
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
          alignment: Alignment.centerLeft,
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => ReadingSettingsPanel(
          currentScrollMode: _scrollMode,
          currentBrightness: _brightness,
          onScrollModeChanged: _handleScrollModeChanged,
          onBrightnessChanged: (value) {
            setModalState(() {
              _updateBrightness(value);
            });
          },
          isDarkMode: _isDarkMode,
          textColor: _textColor,
        ),
      ),
    );
  }

  void _showOutlinePanel() {
    if (_documentDetails == null) return;

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
          alignment: Alignment.centerLeft,
          insetPadding: EdgeInsets.zero,
          backgroundColor: _backgroundColor,
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.85,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  color: _isDarkMode
                      ? const Color(0xFF333333)
                      : Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
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
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      _buildOutlineList(_documentDetails!.document.bookmarks),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineList(PdfBookmarkBase outlines) {
    if (_documentDetails == null ||
        _documentDetails!.document.bookmarks.count == 0) {
      return Center(
        child: Text(
          '暂无目录',
          style: TextStyle(
            color: _textColor.withOpacity(0.5),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _documentDetails!.document.bookmarks.count,
      itemBuilder: (context, index) {
        try {
          final outline = _documentDetails!.document.bookmarks[index];
          return _buildOutlineItem(outline, 0);
        } catch (e) {
          print('Error building outline item: $e');
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOutlineItem(PdfBookmark bookmark, int level) {
    final String key = '${bookmark.title}_$level';
    _outlineStates.putIfAbsent(key, () => _OutlineItemState());
    final hasChildren = bookmark.count > 0;

    return StatefulBuilder(
      builder: (context, setItemState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                try {
                  if (bookmark != null) {
                    _pdfViewerController.jumpToBookmark(bookmark);
                    Navigator.pop(context);
                  }
                } catch (e) {
                  print('Error navigating to bookmark: $e');
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  right: 16.0,
                ),
                child: Row(
                  children: [
                    // 展开/收起按钮区域
                    if (hasChildren)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setItemState(() {
                              _outlineStates[key]!.isExpanded =
                                  !_outlineStates[key]!.isExpanded;
                            });
                            setState(() {}); // 确保父级 Widget 也更新
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            padding: EdgeInsets.only(left: 16.0 * level),
                            alignment: Alignment.center,
                            child: AnimatedRotation(
                              turns: _outlineStates[key]!.isExpanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.chevron_right,
                                color: _textColor.withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0 * level),
                        ),
                      ),
                    // 标题区域
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          bookmark.title,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: level == 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 子目录
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: _outlineStates[key]!.isExpanded ? null : 0,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Column(
                children: [
                  if (hasChildren)
                    for (var i = 0; i < bookmark.count; i++)
                      _buildOutlineItem(bookmark[i], level + 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pdfViewerController.previousPage();
    }
  }

  void _goToNextPage() {
    if (_totalPages != null && _currentPage < _totalPages! - 1) {
      _pdfViewerController.nextPage();
    }
  }

  void _handleDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _isLoading = false;
      _documentDetails = details;
      _totalPages = details.document.pages.count;
      _bookmarkList = details.document.bookmarks;
    });

    if (!_hasInitialJump && _currentPage > 0) {
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

  void _handlePageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber - 1;
    });
    ReadingProgress.saveProgress(widget.path, _currentPage);
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

  Future<void> _loadDarkModeSetting() async {
    try {
      final savedDarkMode = await ReadingSettings.getDarkMode();
      if (mounted) {
        setState(() {
          _userSetDarkMode = savedDarkMode;
        });
      }
    } catch (e) {
      print('Error loading dark mode setting: $e');
    }
  }

  Future<void> _toggleDarkMode() async {
    setState(() {
      _userSetDarkMode = !_isDarkMode;
    });
    await ReadingSettings.setDarkMode(_userSetDarkMode!);
  }

  void _handleScrollModeChanged(ScrollMode mode) async {
    if (_scrollMode == mode) return;

    // 开始过渡动画
    await _transitionController.forward();

    await ReadingSettings.setScrollMode(mode);
    setState(() {
      _scrollMode = mode;
      final currentPage = _currentPage;
      _pdfViewerController.dispose();
      _pdfViewerController = PdfViewerController();

      Future.delayed(Duration.zero, () {
        if (mounted) {
          _pdfViewerController.jumpToPage(currentPage + 1);
          // 结束过渡动画
          _transitionController.reverse();
        }
      });
    });
  }

  // 创建一个叠加层来控制亮度
  Widget _buildBrightnessOverlay() {
    // 确保亮度值在 0.0 到 1.0 之间
    final adjustedBrightness = _brightness.clamp(0.0, 1.0);

    // 计算不透明度：亮度越高，不透明度越低
    final opacity = _isDarkMode
        ? (1.0 - adjustedBrightness).clamp(0.0, 0.8) // 暗色模式下最大减少 80% 亮度
        : (1.0 - adjustedBrightness).clamp(0.0, 0.5); // 亮色模式下最大减少 50% 亮度

    return IgnorePointer(
      child: Container(
        color: Colors.black.withOpacity(opacity),
      ),
    );
  }

  // 更新亮度
  void _updateBrightness(double value) async {
    // 确保亮度值在有效范围内
    final normalizedValue = value.clamp(0.0, 1.0);

    setState(() {
      _brightness = normalizedValue;
    });

    // 更新系统亮度
    try {
      await _screenBrightness?.setScreenBrightness(normalizedValue);
    } catch (e) {
      print('Error setting brightness: $e');
    }

    // 保存设置
    await ReadingSettings.setBrightness(normalizedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                // 顶部信息条 (当控制栏隐藏时显示)
                if (!_showControls) 
                  _buildMinimalInfoBar(),
                
                // PDF 查看器
                Expanded(
                  child: GestureDetector(
                    onTapDown: _handleTapDown,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    child: widget.path.startsWith('assets/')
                        ? SfPdfViewer.asset(
                            widget.path,
                            controller: _pdfViewerController,
                            key: ValueKey('${widget.path}_${_scrollMode.name}'),
                            onDocumentLoaded: _handleDocumentLoaded,
                            onDocumentLoadFailed: _handleDocumentLoadFailed,
                            onPageChanged: _handlePageChanged,
                            scrollDirection:
                                _scrollMode == ScrollMode.singleHorizontal ||
                                        _scrollMode == ScrollMode.continuousHorizontal
                                    ? PdfScrollDirection.horizontal
                                    : PdfScrollDirection.vertical,
                            pageLayoutMode:
                                _scrollMode == ScrollMode.singleHorizontal ||
                                        _scrollMode == ScrollMode.singleVertical
                                    ? PdfPageLayoutMode.single
                                    : PdfPageLayoutMode.continuous,
                            enableDoubleTapZooming: true,
                            enableTextSelection: false,
                            canShowScrollHead: false,
                            canShowPaginationDialog: false,
                            pageSpacing: 0,
                            initialZoomLevel: _zoomLevel,
                            interactionMode: PdfInteractionMode.pan,
                          )
                        : SfPdfViewer.file(
                            File(widget.path),
                            controller: _pdfViewerController,
                            key: ValueKey('${widget.path}_${_scrollMode.name}'),
                            onDocumentLoaded: _handleDocumentLoaded,
                            onDocumentLoadFailed: _handleDocumentLoadFailed,
                            onPageChanged: _handlePageChanged,
                            scrollDirection:
                                _scrollMode == ScrollMode.singleHorizontal ||
                                        _scrollMode == ScrollMode.continuousHorizontal
                                    ? PdfScrollDirection.horizontal
                                    : PdfScrollDirection.vertical,
                            pageLayoutMode:
                                _scrollMode == ScrollMode.singleHorizontal ||
                                        _scrollMode == ScrollMode.singleVertical
                                    ? PdfPageLayoutMode.single
                                    : PdfPageLayoutMode.continuous,
                            enableDoubleTapZooming: true,
                            enableTextSelection: false,
                            canShowScrollHead: false,
                            canShowPaginationDialog: false,
                            pageSpacing: 0,
                            initialZoomLevel: _zoomLevel,
                            interactionMode: PdfInteractionMode.pan,
                          ),
                  ),
                ),
              ],
            ),

            // 亮度调节叠加层
            _buildBrightnessOverlay(),

            // 控制栏
            if (_showControls) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalInfoBar() {
    final currentBookmark = _getCurrentChapterTitle();
    
    return Container(
      height: 48 + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: _isDarkMode 
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _isDarkMode 
                ? Colors.white.withOpacity(0.12)
                : Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 章节信息
              Expanded(
                child: Text(
                  currentBookmark ?? '第 ${_currentPage + 1} 页',
                  style: TextStyle(
                    color: _isDarkMode
                        ? Colors.white.withOpacity(0.85)
                        : Colors.black.withOpacity(0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // 进度和时间
              Text(
                '${((_currentPage + 1) / (_totalPages ?? 1) * 100).toStringAsFixed(1)}% · ${DateFormat('HH:mm').format(_currentTime)}',
                style: TextStyle(
                  color: _isDarkMode
                      ? Colors.white.withOpacity(0.45)
                      : Colors.black.withOpacity(0.45),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getCurrentChapterTitle() {
    if (_documentDetails == null ||
        _documentDetails!.document.bookmarks.count == 0) {
      return null;
    }

    String? currentTitle;
    PdfPage? closestPage;
    void searchBookmarks(PdfBookmark bookmark) {
      final destination = bookmark.destination;
      if (destination != null) {
        final bookmarkPage = destination.page;
        closestPage = bookmarkPage;
        currentTitle = bookmark.title;
      }

      // 搜索子书签
      for (var i = 0; i < bookmark.count; i++) {
        searchBookmarks(bookmark[i]);
      }
    }

    // 遍历所有顶级书签
    for (var i = 0; i < _documentDetails!.document.bookmarks.count; i++) {
      searchBookmarks(_documentDetails!.document.bookmarks[i]);
    }

    return currentTitle;
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _screenBrightness?.resetScreenBrightness();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _userSetDarkMode = null;
    _animationController.dispose();
    _transitionController.dispose();
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
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_totalPages != null)
                              GestureDetector(
                                onTap: _showJumpToPageDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 页码
                                      Text(
                                        '${_currentPage + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        ' / $_totalPages',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13,
                                        ),
                                      ),
                                      // 分隔符
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        width: 1,
                                        height: 12,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      // 进度百分比
                                      Text(
                                        '${((_currentPage + 1) / (_totalPages ?? 1) * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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
                    ],
                  ),
                )),
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
                    icon: const Icon(Icons.bookmarks, color: Colors.white),
                    onPressed: _showBookmarksDialog,
                    tooltip: '书签管理',
                  ),
                  IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.white,
                    ),
                    onPressed: _toggleDarkMode,
                    tooltip: '夜间模式',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: _showSettingsPanel,
                    tooltip: '阅读设置',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth / 3) {
      _goToPreviousPage();
    } else if (tapX > 2 * screenWidth / 3) {
      _goToNextPage();
    } else {
      _toggleControls();
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _touchStartPosition = details.localFocalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      setState(() {
        _zoomLevel = (_zoomLevel * details.scale).clamp(1.0, 3.0);
        _pdfViewerController.zoomLevel = _zoomLevel;
      });
    }
  }
}
