export "./welcome.dart";
import 'package:flutter/material.dart';
import 'package:liuyao_flutter/pages/welcome/components/custom-bar.dart';
import 'package:liuyao_flutter/pages/welcome/pages.const.dart';
import 'package:liuyao_flutter/styles/iconfont.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // 定义page控制器
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化Tab控制器
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    // 释放Tab控制器资源
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: getPages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(IconFont.arrange, size: 16.0, color: Colors.grey),
            activeIcon:
                Icon(IconFont.arrange, size: 16.0, color: Colors.blueAccent),
            label: '排盘',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconFont.read, size: 18.0, color: Colors.grey),
            activeIcon:
                Icon(IconFont.read, size: 18.0, color: Colors.blueAccent),
            label: '六十四卦',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconFont.my, size: 16.0, color: Colors.grey),
            activeIcon: Icon(IconFont.my, size: 16.0, color: Colors.blueAccent),
            label: '我的',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          });
        },
      ),
    );
  }
}
