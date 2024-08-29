import 'package:flutter/material.dart';
import 'package:liuyao/store/schemas.dart';
import 'package:liuyao/store/store.dart';
import 'package:realm/realm.dart';

class RegisterPage extends StatefulWidget {
  final StoreService storeService;

  RegisterPage({required this.storeService});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      if(widget.storeService.query<UserInfo>("username=='$username'").isNotEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('用户名已存在')));
      }else{
        widget.storeService.update<UserInfo>(UserInfo(Uuid.v4(), username: username, passwd: password));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('注册成功')));
        Navigator.pop(context); // 注册成功后返回登录页面
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('注册')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: '用户名'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '密码'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  } else if (value.length < 6) {
                    return '密码长度应至少为6位';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
