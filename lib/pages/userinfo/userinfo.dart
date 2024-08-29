import 'package:flutter/material.dart';
import 'package:liuyao/store/schemas.dart';
import 'package:liuyao/store/store.dart';
import 'package:realm/realm.dart';

class UserInfoPage extends StatefulWidget {
  final StoreService storeService;
  final Uuid userId;

  const UserInfoPage({Key? key, required this.storeService, required this.userId}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  late UserInfo userInfo;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController memoController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    userInfo = widget.storeService.getById<UserInfo>(widget.userId)!;

    usernameController = TextEditingController(text: userInfo.username);
    passwordController = TextEditingController(text: userInfo.passwd);
    nameController = TextEditingController(text: userInfo.name);
    memoController = TextEditingController(text: userInfo.memo);
    emailController = TextEditingController(text: userInfo.email);
    phoneController = TextEditingController(text: userInfo.phone);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    memoController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateUserInfo() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        userInfo.username = usernameController.text;
        userInfo.passwd = passwordController.text;
        userInfo.name = nameController.text;
        userInfo.memo = memoController.text;
        userInfo.email = emailController.text;
        userInfo.phone = phoneController.text;
        userInfo.lastModified = DateTime.now(); // 更新用户信息时修改最后更新时间
      });

      widget.storeService.update<UserInfo>(userInfo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: memoController,
                decoration: const InputDecoration(labelText: 'Memo'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserInfo,
                child: const Text('Update Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
