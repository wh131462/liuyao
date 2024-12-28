import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageContent();
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部封面和头像
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(profile.profile.nickname ?? '我的'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 封面图
                  profile.profile.coverPath != null
                      ? Image.file(
                          File(profile.profile.coverPath!),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                  // 切换封面按钮
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.ac_unit),
                      onPressed: profile.updateCover,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 个人信息区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 头像
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: profile.updateAvatar,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profile.profile.avatarPath != null
                              ? FileImage(File(profile.profile.avatarPath!))
                              : null,
                          child: profile.profile.avatarPath == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 个人信息编辑区
                  _buildInfoCard(context, profile),
                  
                  const SizedBox(height: 16),
                  
                  // 功能列表
                  _buildFunctionList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(BuildContext context, UserProfileProvider profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('昵称'),
              subtitle: Text(profile.profile.nickname ?? '点击设置昵称'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showEditDialog(context, profile, 'nickname'),
            ),
            const Divider(),
            ListTile(
              title: const Text('个性签名'),
              subtitle: Text(profile.profile.signature ?? '点击设置个性签名'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showEditDialog(context, profile, 'signature'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFunctionList(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('历史记录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 导航到历史记录页面
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('我的收藏'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 导航到收藏页面
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 导航到设置页面
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _showEditDialog(
    BuildContext context,
    UserProfileProvider profile,
    String field,
  ) async {
    final controller = TextEditingController(
      text: field == 'nickname' ? profile.profile.nickname : profile.profile.signature,
    );
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑${field == 'nickname' ? '昵称' : '个性签名'}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '请输入${field == 'nickname' ? '昵称' : '个性签名'}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (field == 'nickname') {
                profile.updateProfile(nickname: controller.text);
              } else {
                profile.updateProfile(signature: controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 