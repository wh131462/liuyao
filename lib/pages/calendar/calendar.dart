import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:liuyao_flutter/utils/logger.dart';
import 'package:lunar/lunar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../store/schemas.dart';
import '../../store/store.dart';
import '../arrange/item.card.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  late TabController? _tabController;
  late ScrollController _scrollController; // 用于控制GridView滚动
  final int _currentYear = DateTime.now().year; // 当前的年份

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    // 当切换到年视图时滚动到当前年份
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentYear();
    });
    _tabController?.addListener(() {
      if (_tabController?.indexIsChanging == false) {
        // Tab 切换后执行的逻辑
        if (_tabController?.index == 0) {
          // 当切换到年视图时滚动到当前年份
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentYear();
          });
        } else if (_tabController?.index == 1) {
          // 切换到月视图的逻辑
          print('切换到月视图');
        } else if (_tabController?.index == 2) {
          // 切换到周视图的逻辑
          print('切换到周视图');
        }
      }
    });
    initializeDateFormatting('zh_CN');
  }

  @override
  Widget build(BuildContext context) {
    final storeService = context.watch<StoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('求问日历'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '年'),
            Tab(text: '月'),
            Tab(text: '周'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Year view
          _buildYearView(context, storeService),
          // Month view
          _buildMonthView(context, storeService),
          // Week view
          _buildWeekView(context, storeService),
        ],
      ),
    );
  }

  void _scrollToCurrentYear() {
    int yearOffset = (_currentYear - 1970) ~/ 3;
    double offset = yearOffset * 66.0; // 计算滚动偏移量 (每个格子大约60像素)
    logger.info("当前年份:$_currentYear,当前offset:$offset");
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildYearView(BuildContext context, StoreService storeService) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 每行显示4个年份
        mainAxisSpacing: 10.0, // 主轴方向间距
        crossAxisSpacing: 10.0, // 交叉轴方向间距
        childAspectRatio: 2, // 宽高比
      ),
      itemCount: null, // 设置为null表示无限制
      itemBuilder: (context, index) {
        int year = 1970 + index; // 从当前年份的10年前开始显示
        DateTime yearStart = DateTime(year);
        DateTime yearEnd = DateTime(year + 1);
        int dataCount = storeService
            .query<HistoryItem>(
                "timestamp >= ${yearStart.millisecondsSinceEpoch} AND timestamp < ${yearEnd.millisecondsSinceEpoch}")
            .length;
        return GestureDetector(
            onTap: () {
              setState(() {
                _focusedDay = DateTime(year, 1, 1);
              });
              _tabController?.animateTo(1); // 切换到月视图
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '$year',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (dataCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$dataCount', // 显示数据量或空
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
              ],
            ));
      },
    );
  }

  Widget _buildMonthView(BuildContext context, StoreService storeService) {
    return TableCalendar(
      locale: "zh-CN",
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        // 隐藏格式切换按钮
        titleCentered: true,
        formatButtonShowsNext: false,
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMMM(locale).format(date),
        // 将标题格式化为 "yyyy年MM月"
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
      ),
      firstDay: DateTime.utc(1970, 1, 1),
      lastDay: DateTime.utc(_focusedDay.year + 100, 12, 31),
      focusedDay: _focusedDay,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
      },
      calendarFormat: CalendarFormat.month,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DayDetailPage(date: selectedDay),
          ),
        );
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: _calendarBuilders(storeService, _focusedDay),
    );
  }

  Widget _buildWeekView(BuildContext context, StoreService storeService) {
    return TableCalendar(
      locale: "zh-CN",
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        // 隐藏格式切换按钮
        titleCentered: true,
        formatButtonShowsNext: false,
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMMM(locale).format(date),
        // 将标题格式化为 "yyyy年MM月"
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
      ),
      firstDay: DateTime.utc(1970, 1, 1),
      lastDay: DateTime.utc(_focusedDay.year + 100, 12, 31),
      focusedDay: _focusedDay,
      availableCalendarFormats: const {
        CalendarFormat.week: '',
      },
      calendarFormat: CalendarFormat.week,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DayDetailPage(date: selectedDay),
          ),
        );
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: _calendarBuilders(storeService, _focusedDay),
    );
  }

  CalendarBuilders _calendarBuilders(
      StoreService storeService, DateTime _focusedDay) {
    // 构建函数
    builder(context, DateTime day, DateTime focusedDay) {
      Lunar lunarDate = Lunar.fromDate(day);
      Solar solarDate = Solar.fromDate(day);
      bool isToday = "${day.year}${day.month}${day.day}" ==
          "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}";
      // 检查是否是节假日
      bool isHoliday = lunarDate.getFestivals().isNotEmpty ||
          solarDate.getFestivals().isNotEmpty;
      bool isLunarStart = lunarDate.getDayInChinese() == "初一"; // 判断是否是每月的开始
      String lunarFestival = lunarDate.getFestivals().join();
      String solarFestival = solarDate.getFestivals().join();
      String holiday = isHoliday
          ? (lunarFestival.isNotEmpty ? lunarFestival : solarFestival)
          : "";
      // 计算当天的数据量（示例）
      int dataCount = storeService
          .query<HistoryItem>(
              "timestamp >= ${day.millisecondsSinceEpoch} AND timestamp < ${day.millisecondsSinceEpoch + 86400000}")
          .length;
      bool hasQuestion = dataCount > 0;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isToday
                        ? Colors.blueAccent // 今天的日期颜色
                        : (day.month == _focusedDay.month
                            ? Colors.black87
                            : Colors.grey),
                  ),
                ),
                SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isHoliday
                        ? holiday
                        : isLunarStart
                            ? lunarDate.getMonthInChinese() + "月"
                            : lunarDate.getDayInChinese(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isHoliday
                          ? Colors.teal
                          : (isToday
                              ? Colors.blueAccent // 今天的日期颜色
                              : (day.month == _focusedDay.month
                                  ? Colors.black87
                                  : Colors.grey)),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (hasQuestion)
            Positioned(
              right: 2,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  // 节假日和普通数据标记的颜色区分
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${dataCount > 0 ? dataCount : ''}', // 显示数据量或空
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return CalendarBuilders(
      defaultBuilder: builder,
      outsideBuilder: builder,
      todayBuilder: builder,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 释放ScrollController资源
    super.dispose();
  }
}

class DayDetailPage extends StatefulWidget {
  final DateTime date;

  DayDetailPage({required this.date});

  @override
  _DayDetailPageState createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  late StoreService storeService;
  late List<HistoryItem> todayQuestions;

  @override
  void initState() {
    super.initState();
    storeService = context.read<StoreService>();

    DateTime startOfDay =
        DateTime(widget.date.year, widget.date.month, widget.date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(
        widget.date.year, widget.date.month, widget.date.day, 23, 59, 59);

    todayQuestions = storeService.query<HistoryItem>(
        "timestamp >= ${startOfDay.millisecondsSinceEpoch} AND timestamp <= ${endOfDay.millisecondsSinceEpoch}");
  }

  @override
  Widget build(BuildContext context) {
    Lunar lunar = Lunar.fromDate(widget.date);
    Solar solar = Solar.fromDate(widget.date);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${DateFormat('yyyy-MM-dd').format(widget.date)} (${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}) [星期${lunar.getWeekInChinese()}]',
          style: TextStyle(
              color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateInfo(solar, lunar),
            SizedBox(height: 16),
            _buildQuestionsList(todayQuestions),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(Solar solar, Lunar lunar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '节日信息:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '节日: ${solar.getFestivals().isEmpty ? "无" : solar.getFestivals().join(", ")}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '传统节日: ${lunar.getFestivals().isEmpty ? "无" : lunar.getFestivals().join(", ")}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '黄历信息:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '干支纪年: ${lunar.getYearInGanZhi()}年 ${lunar.getMonthInGanZhi()}月 ${lunar.getDayInGanZhi()}日',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '纳音:${lunar.getYearNaYin()} ${lunar.getMonthNaYin()} ${lunar.getDayNaYin()}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '彭祖: ${lunar.getPengZuGan()} ${lunar.getPengZuZhi()}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '财神: ${lunar.getDayPositionCai()}(${lunar.getDayPositionCaiDesc()})  福神: ${lunar.getDayPositionFu()}(${lunar.getDayPositionFuDesc()})  喜神: ${lunar.getDayPositionXi()}(${lunar.getDayPositionXiDesc()})',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '吉神: ${lunar.getDayJiShen().join(',')}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '凶神: ${lunar.getDayXiongSha().join(',')}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '宜: ${lunar.getDayYi().isEmpty ? "无" : lunar.getDayYi().join(", ")}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '忌: ${lunar.getDayJi().isEmpty ? "无" : lunar.getDayJi().join(", ")}',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildQuestionsList(List<HistoryItem> questions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日求问过的问题:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        questions.isEmpty
            ? Text('当日无求问记录')
            : Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final item = questions[index];
                    return HistoryItemCard(
                      item: item,
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('确认删除'),
                              content: Text('你确定要删除这个条目吗？'),
                              actions: [
                                TextButton(
                                  child: Text('取消'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 关闭弹窗
                                  },
                                ),
                                TextButton(
                                  child: Text('删除'),
                                  onPressed: () {
                                    storeService.delete<HistoryItem>(item);
                                    Navigator.of(context).pop(); // 关闭弹窗
                                    setState(() {
                                      questions.remove(item); // 从列表中移除该项
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
      ],
    );
  }
}
