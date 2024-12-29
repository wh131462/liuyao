import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  // 定义颜色选项列表，包含名称和颜色值
  static const List<Map<String, dynamic>> colorOptions = [
    {'name': '天空蓝', 'color': Colors.blue},
    {'name': '翡翠绿', 'color': Colors.green},
    {'name': '皇室紫', 'color': Colors.purple},
    {'name': '暖阳橙', 'color': Colors.orange},
    {'name': '热情红', 'color': Colors.red},
    {'name': '青碧蓝', 'color': Colors.teal},
    {'name': '浪漫粉', 'color': Colors.pink},
    {'name': '深邃蓝', 'color': Colors.indigo},
  ];

  String _getColorName(Color color, BuildContext context) {
    // 查找预设颜色的名称
    final preset = colorOptions.firstWhere(
      (option) => option['color'].value == color.value,
      orElse: () => {'name': '自定义'},
    );
    return preset['name'];
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "主题设置",
      canBack: true,
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isCustomColor = !colorOptions.any((option) =>
              option['color'].value == themeProvider.primaryColor.value);

          return ListView(
            children: [
              _buildThemeModeSection(context, themeProvider),
              const Divider(),
              _buildColorSection(context, themeProvider, isCustomColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context, ThemeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('主题模式',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('跟随系统'),
          value: ThemeMode.system,
          groupValue: provider.themeMode,
          onChanged: (value) => provider.setThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('浅色模式'),
          value: ThemeMode.light,
          groupValue: provider.themeMode,
          onChanged: (value) => provider.setThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('深色模式'),
          value: ThemeMode.dark,
          groupValue: provider.themeMode,
          onChanged: (value) => provider.setThemeMode(value!),
        ),
      ],
    );
  }

  Widget _buildColorSection(
      BuildContext context, ThemeProvider provider, bool isCustomColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('主题颜色',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                _getColorName(provider.primaryColor, context),
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ...colorOptions.map((option) => _buildColorButton(
                    context,
                    provider,
                    option['color'],
                    option['name'],
                  )),
              _buildCustomColorButton(context, provider, isCustomColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorButton(
    BuildContext context,
    ThemeProvider provider,
    Color color,
    String name,
  ) {
    final isSelected = provider.primaryColor.value == color.value;

    return Tooltip(
      message: name,
      child: GestureDetector(
        onTap: () => provider.setPrimaryColor(color),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomColorButton(
      BuildContext context, ThemeProvider provider, bool isCustomColor) {
    return Tooltip(
      message: '自定义颜色',
      child: GestureDetector(
        onTap: () => _showColorPicker(context, provider),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCustomColor ? provider.primaryColor : null,
            border: Border.all(
              color: isCustomColor ? Colors.white : Colors.grey,
              width: isCustomColor ? 3 : 1,
            ),
            boxShadow: [
              if (isCustomColor)
                BoxShadow(
                  color: provider.primaryColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: isCustomColor ? null : const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: provider.primaryColor,
            onColorChanged: (color) => provider.setPrimaryColor(color),
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
