import 'package:flutter/material.dart';
import 'package:liuyao/pages/register/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../store/schemas.dart';
import '../../store/store.dart';

class LoginPage extends StatefulWidget {
  final StoreService storeService;

  LoginPage({required this.storeService});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
  }

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final user = widget.storeService
        .query<UserInfo>("username == '$username' AND passwd == '$password'");

    if (user.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('登录成功')));
      widget.storeService.setLocal('isLoggedIn', true);
      widget.storeService.setLocal('username', user.first.username??"");
      widget.storeService.setLocal('userId', user.first.id.toString());
      Navigator.pop(context); // 注册成功后返回登录页面
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('用户名或密码错误')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '用户名'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '密码'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('登录'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(storeService: widget.storeService,)),
                );
              },
              child: Text('没有账号？注册'),
            ),
          ],
        ),
      ),
    );
  }
}
