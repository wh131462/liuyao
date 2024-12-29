import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../store/store.dart';
import '../../models/user_info.dart';
import '../userinfo/userinfo.dart';
import '../login/login.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "我的",
      body: CustomScrollView(
        slivers: [
          // 顶部背景和头像区域
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          // 菜单列表
          SliverToBoxAdapter(
            child: _buildMenuList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // 顶部背景图
        Container(
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/wall.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
        ),
        // 头像和用户信息
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatar(context),
              const SizedBox(height: 16),
              _buildUserInfo(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return FutureBuilder<UserInfo?>(
      future: context.read<StoreService>().getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        
        return GestureDetector(
          onTap: () => _handleAvatarTap(context, user),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: user?.avatarPath != null
                  ? FileImage(File(user!.avatarPath!))
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return FutureBuilder<UserInfo?>(
      future: context.read<StoreService>().getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        
        return GestureDetector(
          onTap: () => _handleAvatarTap(context, user),
          child: Column(
            children: [
              Text(
                user?.username ?? '点击登录',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              if (user != null) ...[
                const SizedBox(height: 8),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('历史记录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
          FutureBuilder<UserInfo?>(
            future: context.read<StoreService>().getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    '退出登录',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _handleLogout(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _handleAvatarTap(BuildContext context, UserInfo? user) {
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  LoginPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  UserInfoPage(userId: user.id)),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storeService = context.read<StoreService>();
      await storeService.clearCurrentUser();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }
}
