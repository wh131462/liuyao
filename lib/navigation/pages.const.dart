import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liuyao/pages/arrange/arrange.dart';
import 'package:liuyao/pages/hexagrams/hexagrams.dart';
import 'package:liuyao/pages/my/my.dart';
import 'package:liuyao/styles/iconfont.dart';

class CustomPage {
  String title;
  Widget content;
  final Icon? leftIcon;
  final VoidCallback? onLeftIconPressed;
  final Icon? rightIcon;
  final VoidCallback? onRightIconPressed;

  CustomPage(this.title, this.content, this.leftIcon, this.onLeftIconPressed,
      this.rightIcon, this.onRightIconPressed);
}

List<CustomPage> pages = [
  CustomPage("排盘", ArrangePage(), null, null, null, null),
  CustomPage(
      "六十四卦",
      HexagramsPage(),
      null,
      null,
      const Icon(
        IconFont.help,
        size: 16.0,
        color: Colors.grey,
      ),
      () {}),
  CustomPage("我的", MyPage(), null, null, null, null)
];

/// 获取页面
List<Widget> getPages() {
  return pages.map((o) => o.content).toList();
}
