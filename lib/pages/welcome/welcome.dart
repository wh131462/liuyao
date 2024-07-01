export "./welcome.dart";
import 'package:flutter/material.dart';
import 'package:liuyao_flutter/pages/gua/gua.dart';
import 'package:liuyao_flutter/pages/my/my.dart';
import 'package:liuyao_flutter/pages/welcome/custom-page.dart';

import '../arrange/arrange.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  // 定义Tab控制器
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
    final List<CustomPage> pages = [
      CustomPage("排盘", ArrangePage()),
      CustomPage("六十四卦", GuaPage()),
      CustomPage("我的", MyPage())
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          alignment: Alignment.center,
          child: Text(pages[_currentIndex].title),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: pages.map((o) => o.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '排盘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: '六十四卦',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '我的',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index, duration:const Duration(milliseconds: 300), curve: Curves.easeInOut);
          });
        },
      ),
    );
  }
}
