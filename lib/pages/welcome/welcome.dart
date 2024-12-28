import 'package:flutter/material.dart';
import '../../styles/iconfont.dart';
import '../tools/tools_page.dart';
import '../arrange/arrange.dart';
import '../hexagrams/hexagrams_page.dart';
import '../my/my.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ArrangePage(), // 使用排盘页面作为首页
    const ToolsPage(), // 工具页
    HexagramsPage(), // 原有的六十四卦页面
    const MyPage(), // 我的页面
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconFont.arrange),
            activeIcon: Icon(IconFont.arrange),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: '工具',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconFont.read),
            activeIcon: Icon(IconFont.read),
            label: '六十四卦',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
