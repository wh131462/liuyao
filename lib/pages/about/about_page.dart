import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../license/license.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'hao131462@qq.com',
      queryParameters: {
        'subject': '六爻排盘 - 用户反馈',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw '无法打开邮箱应用';
    }
  }

  Future<void> _launchGitHub() async {
    final Uri githubUri = Uri.parse('https://github.com/wh131462');

    if (await canLaunchUrl(githubUri)) {
      await launchUrl(githubUri, mode: LaunchMode.externalApplication);
    } else {
      throw '无法打开浏览器';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final info = snapshot.data!;
            return ListView(
              children: [
                ListTile(
                  title: const Text('版本'),
                  trailing: Text(info.version),
                ),
                ListTile(
                  title: const Text('开发者'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Eternal Heart'),
                      const SizedBox(width: 4),
                      Icon(Icons.open_in_new, 
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ],
                  ),
                  onTap: () async {
                    try {
                      await _launchGitHub();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('打开GitHub失败: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('开源许可'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyLicensePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('联系我们'),
                  subtitle: const Text('hao131462@qq.com'),
                  trailing: const Icon(Icons.email),
                  onTap: () async {
                    try {
                      await _launchEmail();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('打开邮箱失败: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('隐私政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('用户协议'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserAgreementPage(),
                      ),
                    );
                  },
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

// 隐私政策页面
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
隐私政策

最后更新日期：2024年3月20日

1. 信息收集
我们只收集必要的信息来提供服务，包括：
- 用户创建的卦象数据
- 应用设置信息

2. 信息使用
收集的信息仅用于：
- 提供核心功能服务
- 改善用户体验
- 应用性能优化

3. 信息存储
所有数据均存储在用户本地设备上，我们不会上传或分享您的个人信息。

4. 用户权利
您有权：
- 访问您的所有数据
- 删除您的数据
- 修改您的个人设置

5. 联系我们
如有任何问题，请联���：
support@eternalheart.com
''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// 用户协议页面
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
用户协议

1. 服务说明
本应用提供六爻排盘服务，仅供参考，不作为任何决策依据。

2. 用户责任
- 遵守相关法律法规
- 不得滥用本应用服务
- 对自己的行为负责

3. 知识产权
本应用的所有内容均受著作权法保护。

4. 免责声明
- 本应用不对卦象解释的准确性负责
- 用户因使用本应用产生的任何损失，本应用概不负责

5. 协议修改
我们保留随时修改本协议的权利。
''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 