import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../store/store.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final storeService = Provider.of<StoreService>(context, listen: false);
    final username = await storeService.getLocal('username');
    final password = await storeService.getLocal('password');
    final rememberMe = await storeService.getLocal('rememberMe');
    
    setState(() {
      _usernameController.text = username ?? '';
      _passwordController.text = password ?? '';
      _rememberMe = rememberMe == 'true';
    });
  }

  Future<void> _saveCredentials() async {
    final storeService = Provider.of<StoreService>(context, listen: false);
    if (_rememberMe) {
      await storeService.setLocal('username', _usernameController.text);
      await storeService.setLocal('password', _passwordController.text);
      await storeService.setLocal('rememberMe', 'true');
    } else {
      await storeService.removeLocal('username');
      await storeService.removeLocal('password');
      await storeService.setLocal('rememberMe', 'false');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final storeService = Provider.of<StoreService>(context, listen: false);
      
      // 验证用户名和密码
      final user = await dbService.getUserByUsername(_usernameController.text);
      if (user == null || user.passwd != _passwordController.text) {
        throw '用户名或密码错误';
      }

      // 保存凭据（如果选择了记住我）
      await _saveCredentials();

      // 设置登录状态和用户ID
      await storeService.setCurrentUser(user.id);
      await storeService.setLocal('isLoggedIn', 'true');

      if (mounted) {
        // 返回到主页并选中"我的"标签
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
          arguments: {'initialIndex': 3}, // 假设"我的"标签索引为3
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset(
                'assets/icon/logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 32),
              
              // 用户名输入框
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 密码输入框
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).hintColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 记住我和忘记密码行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 记住我复选框
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('记住我'),
                    ],
                  ),
                  // 忘记密码按钮
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forget');
                    },
                    child: const Text('忘记密码？'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('登录'),
              ),

              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () async {
                  // 使用 pushNamed 并等待结果
                  final result = await Navigator.pushNamed(context, '/register');
                  // 如果注册成功（返回 true），则关闭登录页面
                  if (result == true) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                child: const Text('还没有账号？立即注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
