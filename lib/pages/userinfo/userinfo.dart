import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_info.dart';
import '../../store/store.dart';
import '../../widgets/settings/settings_section.dart';

class UserInfoPage extends StatefulWidget {
  final String userId;

  const UserInfoPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late UserInfo _userInfo;
  bool _isEditing = false;
  bool _isLoading = true;

  final _controllers = UserInfoControllers();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final storeService = context.read<StoreService>();
      final userInfo = await storeService.getUserInfo(widget.userId);
      
      setState(() {
        _userInfo = userInfo!;
        _controllers.initializeWith(_userInfo);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载用户信息失败: $e')),
        );
      }
    }
  }

  Future<void> _updateUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final storeService = context.read<StoreService>();
      
      final updatedInfo = UserInfo(
        id: _userInfo.id,
        username: _controllers.username.text,
        passwd: _controllers.password.text,
        name: _controllers.name.text,
        email: _controllers.email.text,
        phone: _controllers.phone.text,
        memo: _controllers.memo.text,
        avatarPath: _userInfo.avatarPath,
        createdAt: _userInfo.createdAt,
        updatedAt: DateTime.now(),
      );

      await storeService.updateUserInfo(updatedInfo);
      
      setState(() {
        _userInfo = updatedInfo;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户信息更新成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateUserInfo();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              UserAvatarSection(
                avatarPath: _userInfo.avatarPath,
                isEditing: _isEditing,
                onAvatarChanged: (String path) {
                  // TODO: 实现头像更新逻辑
                },
              ),
              const SizedBox(height: 24),
              UserInfoFields(
                controllers: _controllers,
                isEditing: _isEditing,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateUserInfo,
                  child: const Text('保存修改'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UserInfoControllers {
  final username = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final memo = TextEditingController();

  void initializeWith(UserInfo userInfo) {
    username.text = userInfo.username;
    password.text = userInfo.passwd ?? '';
    name.text = userInfo.name ?? '';
    email.text = userInfo.email ?? '';
    phone.text = userInfo.phone ?? '';
    memo.text = userInfo.memo ?? '';
  }

  void dispose() {
    username.dispose();
    password.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    memo.dispose();
  }
}

class UserAvatarSection extends StatelessWidget {
  final String? avatarPath;
  final bool isEditing;
  final Function(String) onAvatarChanged;

  const UserAvatarSection({
    Key? key,
    this.avatarPath,
    required this.isEditing,
    required this.onAvatarChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: avatarPath != null
                ? AssetImage(avatarPath!)
                : null,
            child: avatarPath == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          if (isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 18),
                  color: Colors.white,
                  onPressed: () {
                    // TODO: 实现头像选择逻辑
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class UserInfoFields extends StatelessWidget {
  final UserInfoControllers controllers;
  final bool isEditing;

  const UserInfoFields({
    Key? key,
    required this.controllers,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserInfoTextField(
          controller: controllers.username,
          label: '用户名',
          enabled: isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入用户名';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        UserInfoTextField(
          controller: controllers.password,
          label: '密码',
          enabled: isEditing,
          obscureText: true,
          validator: (value) {
            if (isEditing && (value == null || value.isEmpty)) {
              return '请输入密码';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        UserInfoTextField(
          controller: controllers.name,
          label: '姓名',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        UserInfoTextField(
          controller: controllers.email,
          label: '邮箱',
          enabled: isEditing,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '请输入有效的邮箱地址';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        UserInfoTextField(
          controller: controllers.phone,
          label: '电话',
          enabled: isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        UserInfoTextField(
          controller: controllers.memo,
          label: '备注',
          enabled: isEditing,
          maxLines: 3,
        ),
      ],
    );
  }
}

class UserInfoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;

  const UserInfoTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }
}
