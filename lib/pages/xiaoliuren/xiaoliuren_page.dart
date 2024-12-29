import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liuyao/components/video_player.dart';
import 'package:liuyao/components/page_scaffold.dart';
import 'package:liuyao/constants/liuren.const.dart';
import 'package:lunar/lunar.dart';

import '../../utils/logger.dart';

class XiaoLiuRenPage extends StatefulWidget {
  const XiaoLiuRenPage({Key? key}) : super(key: key);

  @override
  State<XiaoLiuRenPage> createState() => _XiaoLiuRen();
}

class _XiaoLiuRen extends State<XiaoLiuRenPage> {
  // 用于输入的三个数字
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  final TextEditingController _num3Controller = TextEditingController();

  // 控制是否显示错误提示
  bool _isNum1Valid = true;
  bool _isNum2Valid = true;
  bool _isNum3Valid = true;
  String lunarInfo = "";

  // 记录选中的宫位索引，用于高亮
  List<XiaoLiuRen> _selectedXiaoLiuRen = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    setLunarInfo();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setLunarInfo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _num1Controller.dispose();
    _num2Controller.dispose();
    _num3Controller.dispose();
    super.dispose();
  }

  void setLunarInfo() {
    setState(() {
      Lunar lunar = Lunar.fromDate(DateTime.now());
      Lunar nextDayLunar =
      Lunar.fromDate(DateTime.now().add(const Duration(seconds: 24 * 60 * 60)));
      lunarInfo =
      "${lunar.getYearInGanZhi()}年 ${lunar.getMonthInGanZhi()}月 ${lunar
          .getHour() == 23 ? nextDayLunar.getDayInGanZhi() : lunar
          .getDayInGanZhi()}日 ${lunar.getTimeInGanZhi()}时 (${lunar.getHour()
          .toString()
          .padLeft(2, '0')}:${lunar.getMinute().toString().padLeft(
          2, '0')}:${lunar.getSecond().toString().padLeft(2, '0')})";
    });
  }

  // 获取农历时间数字
  List<int> getNumByLunar() {
    Lunar lunar = Lunar.fromDate(DateTime.now());
    Lunar nextDayLunar =
    Lunar.fromDate(DateTime.now().add(Duration(seconds: 24 * 60 * 60)));
    return [
      LunarUtil.MONTH.indexOf(lunar.getMonthInChinese()),
      lunar.getHour() != 23
          ? LunarUtil.DAY.indexOf(lunar.getDayInChinese())
          : LunarUtil.DAY.indexOf(nextDayLunar.getDayInChinese()),
      lunar.getTimeZhiIndex() + 1
    ];
  }

  void _onTime() {
    List<int> numList = getNumByLunar();
    setState(() {
      _num1Controller.text = "${numList[0]}";
      _num2Controller.text = "${numList[1]}";
      _num3Controller.text = "${numList[2]}";
    });
  }

  // 排盘按钮点击事件
  void _onPaiPan() {
    _isNum1Valid = _num1Controller.text.isNotEmpty;
    _isNum2Valid = _num2Controller.text.isNotEmpty;
    _isNum3Valid = _num3Controller.text.isNotEmpty;
    if (_isNum1Valid && _isNum2Valid && _isNum3Valid) {
      var numList = [
        int.parse(_num1Controller.text),
        int.parse(_num2Controller.text),
        int.parse(_num3Controller.text)
      ];
      var cur = XiaoLiuRen.getFirst();
      List<XiaoLiuRen> list = [];
      for (int step in numList) {
        cur = XiaoLiuRen.getXiaoLiuRenByStep(cur, step);
        logger.info("$cur $step");
        list.add(cur);
      }
      setState(() {
        _selectedXiaoLiuRen = list;
        logger.debug(list);
      });
    }
  }

  void _onReset() {
    setState(() {
      _num1Controller.clear();
      _num2Controller.clear();
      _num3Controller.clear();
      _isNum1Valid = true;
      _isNum2Valid = true;
      _isNum3Valid = true;
      _selectedXiaoLiuRen = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '小六壬',
      canBack: true,
      actions: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  title: const Center(
                    child: Text(
                      "请看视频",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: const VideoPlayerWidget(
                      videoUrl: "assets/videos/xiaoliuren.mp4",
                      isLocal: true,
                      autoPlay: true,
                      showControls: true,
                    ),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('确定', style: TextStyle(fontSize: 16)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.help_outline, color: Colors.black),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 干支信息展示
            TextButton(
              onPressed: _onTime,
              child: Text(
                lunarInfo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10),
            // 输入框和按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    _buildNumberInput(_num1Controller, _isNum1Valid),
                    if (_selectedXiaoLiuRen.length >= 3)
                      Text(_selectedXiaoLiuRen.first.name)
                  ],
                ),
                Column(
                  children: [
                    _buildNumberInput(_num2Controller, _isNum2Valid),
                    if (_selectedXiaoLiuRen.length >= 3)
                      Text(_selectedXiaoLiuRen[1].name)
                  ],
                ),
                Column(
                  children: [
                    _buildNumberInput(_num3Controller, _isNum3Valid),
                    if (_selectedXiaoLiuRen.length >= 3)
                      Text(_selectedXiaoLiuRen.last.name)
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _onPaiPan,
                      child: Text("排盘"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.teal, // 按钮颜色
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onReset,
                      child: Text("重置"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.teal, // 按钮颜色
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),

            // 九宫格展示
            Expanded(
              child: GridView.count(
                crossAxisCount: 3, // 每行3个宫位
                crossAxisSpacing: 10.0, // 网格项之间的水平间距
                mainAxisSpacing: 10.0, // 网格项之间的垂直间距
                children: _buildGongweiItems(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建数字输入框
  Widget _buildNumberInput(TextEditingController controller, bool isValid) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: '数字',
          errorText: isValid ? null : '卦数',
        ),
      ),
    );
  }

  // 构建九宫格中的宫位项
  List<Widget> _buildGongweiItems() {
    List<XiaoLiuRen> allGongwei = [
      XiaoLiuRen.liulian,
      XiaoLiuRen.suxi,
      XiaoLiuRen.bingfu,
      XiaoLiuRen.daan,
      XiaoLiuRen.kongwang,
      XiaoLiuRen.chikou,
      XiaoLiuRen.taohua,
      XiaoLiuRen.xiaoji,
      XiaoLiuRen.tiande,
    ];

    return List.generate(allGongwei.length, (index) {
      if (_selectedXiaoLiuRen.length >= 3) {
        bool isSelected = _selectedXiaoLiuRen.contains(allGongwei[index]);
        int selectionIndex = _selectedXiaoLiuRen.indexOf(allGongwei[index]) + 1;
        return _buildGridItem(allGongwei[index], isSelected, selectionIndex);
      } else {
        return _buildGridItem(allGongwei[index], false, 0);
      }
    });
  }

  // 构建每个宫位的卡片展示，增加高亮效果
  Widget _buildGridItem(XiaoLiuRen xiang, bool isSelected, int selectionIndex) {
    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 圆角边框
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  title: Center(
                    child: Text(
                      "其他信息",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          // 添加上下间距
                          child: Text(
                            "方位: ${xiang.direction.name}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "属性: ${xiang.property}",
                            style: TextStyle(fontSize: 16, color: Colors
                                .grey[700]), // 改变颜色和字体大小
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "神灵: ${xiang.shen}",
                            style: TextStyle(fontSize: 16, color: Colors
                                .grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        // 增加按钮内边距
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 圆角按钮
                        ),
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(fontSize: 16), // 增加按钮字体大小
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // 关闭弹窗
                      },
                    ),
                  ],
                );
              });
        },
        child: Card(
          elevation: isSelected ? 10.0 : 4.0, // 选中的卡片增加阴影
          color: isSelected ? Colors.teal[100] : Colors.white, // 选中时背景颜色变化
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 设置圆角
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 垂直居中对齐
                    children: [
                      Text(
                        xiang.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.teal : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.0), // 控制不同文本之间的间距
                      Text(
                        xiang.direction.gua?.name ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        xiang.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // 选中的宫位在右上角显示序号
                if (isSelected)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.teal,
                      child: Text(
                        '$selectionIndex',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}

