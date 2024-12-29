import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('主题设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/themeSetting');
            },
          ),
          ListTile(
            title: const Text('深色模式'),
            trailing: Switch(
              value: context.watch<ThemeProvider>().themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                context.read<ThemeProvider>().toggleDarkMode();
              },
            ),
          ),
          // 添加更多设置项...
        ],
      ),
    );
  }
} 