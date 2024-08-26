import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:liuyao_flutter/pages/arrange/arrange.detail.dart';
import 'package:liuyao_flutter/utils/logger.dart';
import 'package:lunar/lunar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../store/schemas.dart';
import '../../store/store.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  late TabController? _tabController;
  late ScrollController _scrollController; // 用于控制GridView滚动
  final int _currentYear = DateTime
      .now()
      .year; // 当前的年份


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
        return GestureDetector(
          onTap: () {
            setState(() {
              _focusedDay = DateTime(year, 1, 1);
            });
            _tabController?.animateTo(1); // 切换到月视图
          },
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '$year',
              style: TextStyle(
                color: Colors.black87, // 文字颜色
                fontSize: 16, // 文字大小
              ),
            ),
          ),
        );
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
      firstDay: DateTime.utc(_focusedDay.year, 1, 1),
      lastDay: DateTime.utc(_focusedDay.year, 12, 31),
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

  CalendarBuilders _calendarBuilders(StoreService storeService,
      DateTime _focusedDay) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        Lunar lunarDate = Lunar.fromDate(day);
        bool isToday = day.isAtSameMomentAs(DateTime.now());
        // 检查是否是节假日
        bool isHoliday = lunarDate
            .getFestivals()
            .isNotEmpty;
        bool isLunarStart = lunarDate.getDayInChinese() == "初一"; // 判断是否是每月的开始
        // 计算当天的数据量（示例）
        int dataCount = storeService
            .query<HistoryItem>(
            "timestamp >= ${day.millisecondsSinceEpoch} AND timestamp < ${day
                .millisecondsSinceEpoch + 86400000}")
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
                  Text(
                    isLunarStart
                        ? lunarDate.getMonthInChinese() + "月"
                        : lunarDate.getDayInChinese(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday
                          ? Colors.blueAccent // 今天的日期颜色
                          : (day.month == _focusedDay.month
                          ? Colors.black87
                          : Colors.grey),
                    ),
                  ),
                  // 节假日
                  // Text(
                  //   '${lunarDate.getFestivals().join(',')}',
                  //   style: TextStyle(
                  //     fontSize: 10,
                  //     color: Colors.green,
                  //   ),
                  // ),

                ],
              ),
            ),
            if(hasQuestion)
              Positioned(
                right: 6,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    // 节假日和普通数据标记的颜色区分
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${dataCount > 0 ? dataCount : ''}', // 显示数据量或空
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      todayBuilder: (context, day, focusedDay) {
        Lunar lunarDate = Lunar.fromDate(day);
        bool isToday = day.isAtSameMomentAs(DateTime.now());
        // 检查是否是节假日
        bool isHoliday = lunarDate
            .getFestivals()
            .isNotEmpty;
        bool isLunarStart = lunarDate.getDayInChinese() == "初一"; // 判断是否是每月的开始
        // 计算当天的数据量（示例）
        int dataCount = storeService
            .query<HistoryItem>(
            "timestamp >= ${day.millisecondsSinceEpoch} AND timestamp < ${day
                .millisecondsSinceEpoch + 86400000}")
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
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isLunarStart
                        ? lunarDate.getMonthInChinese() + "月"
                        : lunarDate.getDayInChinese(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            if(hasQuestion)
              Positioned(
                right: 8,
                top: -8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    // 节假日和普通数据标记的颜色区分
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${dataCount > 0 ? dataCount : ''}', // 显示数据量或空
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _scrollController.dispose(); // 释放ScrollController资源
    super.dispose();
  }
}

class DayDetailPage extends StatelessWidget {
  final DateTime date;

  DayDetailPage({required this.date});

  @override
  Widget build(BuildContext context) {
    final storeService = context.watch<StoreService>();

    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<HistoryItem> todayQuestions = storeService.query<HistoryItem>(
        "timestamp >= ${startOfDay.millisecondsSinceEpoch} AND timestamp <= ${endOfDay.millisecondsSinceEpoch}");

    Lunar lunar = Lunar.fromDate(date);
    Solar solar = Solar.fromDate(date);
    return Scaffold(
      appBar: AppBar(
        title: Text('详细信息'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateInfo(lunar),
            SizedBox(height: 16),
            _buildFestivalsInfo(lunar,solar),
            SizedBox(height: 16),
            _buildQuestionsList(todayQuestions, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(Lunar lunar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '公历日期: ${DateFormat('yyyy-MM-dd').format(date)}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '阴历日期: ${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}',
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildFestivalsInfo(Lunar lunar,Solar solar) {
    return Text(
      '节日: ${solar.getFestivals().isEmpty ? "无" : solar.getFestivals().join(", ")}\n传统节日: ${lunar.getFestivals().isEmpty ? "无" : lunar.getFestivals().join(", ")}',
      style: TextStyle(fontSize: 20),
    );
  }

  Widget _buildQuestionsList(List<HistoryItem> questions, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日求问过的问题:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        questions.isEmpty
            ? Text('今日无求问记录')
            : ListView.builder(
          shrinkWrap: true,
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final item = questions[index];
            final time = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
            return ListTile(
              title: Text(item.question??"未描述问题"),
              subtitle: Text('时间: ${time.hour}:${time.minute}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArrangeDetailPage(question: item.question,answer: item.originAnswer),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
