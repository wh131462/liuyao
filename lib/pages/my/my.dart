import 'package:flutter/material.dart';
import 'package:liuyao_flutter/pages/license/license.dart';
import 'package:liuyao_flutter/pages/welcome/components/custom-bar.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 定义一个变量来控制头像的显示位置
  double _avatarPosition = 190; // 初始头像位置与AppBar顶部的距离

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [_buildSliverAppBar(),_buildSettingsList(),],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _avatarPosition,
      leading: null,
      pinned: true,
      snap: false,
      backgroundColor: Colors.blue,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 55, bottom: 15),
        collapseMode: CollapseMode.parallax,
        background: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/wall.jpg",
              fit: BoxFit.cover,
            ),
            // 头像组件
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30), // 可以根据需要调整间隔大小
                  // 头像图片
                  ClipOval(
                    child: Image.asset(
                      "assets/images/head_pic.png",
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  ),
                  // 账号信息，距离头像底部的间隔
                  const SizedBox(height: 10), // 可以根据需要调整间隔大小
                  // 账号文本
                  const Text(
                    'uid: 000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSettingsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return ListTile(
            title: Text(_settings[index]),
            onTap: () {
              // 处理设置项点击事件
              if (_settings[index] == "关于软件") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const MyLicensePage()), // NewPage 是你要跳转到的页面
                );
              }
              print('点击了设置项: ${_settings[index]}');
            },
          );
        },
        childCount: _settings.length,
      ),
    );
  }

  // 设置项列表
  final List<String> _settings = ['我的信息', '备份设置', '关于软件'];
}
