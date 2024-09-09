import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuren.const.dart';
import 'package:liuyao/utils/logger.dart';

class XiaoLiuRenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _XiaoLiuRen();
  }
}

class _XiaoLiuRen extends State<StatefulWidget> {
  @override
  void initState() {
    logger.info(XiaoLiuRen.getXiaoLiuRenByOrder());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('小六壬'),
          ),
          body: GridView.count(
            crossAxisCount: 3, // 每行3个宫位
            children: [
              _buildGridItem('留连'),
              _buildGridItem('速喜'),
              _buildGridItem('病符'),
              _buildGridItem('大安'),
              _buildGridItem('空亡'),
              _buildGridItem('赤口'),
              _buildGridItem('桃花'),
              _buildGridItem('小吉'),
              _buildGridItem('天德'),
            ],
          ),
      ),
    );
  }
  // 构建九宫格的每个Item
  Widget _buildGridItem(String title) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
