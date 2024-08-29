import 'package:flutter/material.dart';
import 'package:liuyao/pages/license/license.dart';
import 'package:liuyao/pages/login/login.dart';
import 'package:liuyao/pages/spinning/spinning.dart';
import 'package:liuyao/pages/userinfo/userinfo.dart';
import 'package:liuyao/store/store.dart';
import 'package:liuyao/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart' as realm;
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  double _avatarPosition = 190;
  bool _isLoggedIn = false;
  String _username = '未登录';
  String _userId = "";
  late StoreService storeService;
  late SharedPreferences prefs;

  Future<SharedPreferences> _init() async {
    storeService = context.watch<StoreService>();
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _username = prefs.getString('username') ?? '未登录';
      _userId = prefs.getString('userId') ?? '';

      logger.info("获取到信息$_isLoggedIn, $_userId, $_username");
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清除登录信息
    setState(() {
      _isLoggedIn = false;
      _username = '未登录';
      _userId = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<SharedPreferences>(
        future: _init(), // 传入异步操作
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // 当数据获取完成时，渲染页面内容
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                _buildSettingsList(),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _avatarPosition,
      pinned: true,
      backgroundColor: Colors.blue,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 55, bottom: 15),
        collapseMode: CollapseMode.parallax,
        background: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset("assets/images/wall.jpg", fit: BoxFit.cover),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  ClipOval(
                    child: Image.asset(
                      "assets/images/head_pic.png",
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isLoggedIn)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage(
                                    storeService: storeService,
                                    prefs: prefs,
                                  )),
                        ).then((_) => _checkLoginStatus());
                      },
                      child:
                          Text('点击登录', style: TextStyle(color: Colors.white)),
                    ),
                  if (_isLoggedIn)
                    TextButton(
                      onPressed: _logout,
                      child: Text('注销', style: TextStyle(color: Colors.white)),
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
              switch (_settings[index]) {
                case "我的信息":
                  if (!_isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(
                                storeService: storeService,
                                prefs: prefs,
                              )),
                    ).then((_) => _checkLoginStatus());
                  } else {
                    var userId = realm.Uuid.fromString(_userId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInfoPage(
                                storeService: storeService,
                                userId: userId,
                              )),
                    ).then((_) => _checkLoginStatus());
                  }
                  break;
                case "卦象转盘":
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpinningWheelPage(),
                      ));
                  break;
                case "备份设置":
                  break;
                case "关于软件":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyLicensePage()),
                  );
                  break;
              }
            },
          );
        },
        childCount: _settings.length,
      ),
    );
  }

  final List<String> _settings = [
    '我的信息',
    "卦象转盘",
    //  '备份设置',
    '关于软件'
  ];
}
