import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../providers/reader_provider.dart';
import '../../widgets/settings/settings_section.dart';

class ReaderSettingsPage extends StatelessWidget {
  const ReaderSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读器设置'),
      ),
      body: const ReaderSettingsBody(),
    );
  }
}

class ReaderSettingsBody extends StatelessWidget {
  const ReaderSettingsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, provider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FontSizeSection(provider: provider),
            const Divider(height: 32),
            LineHeightSection(provider: provider),
            const Divider(height: 32),
            ColorSection(provider: provider),
            const Divider(height: 32),
            FontFamilySection(provider: provider),
            const Divider(height: 32),
            DarkModeSection(provider: provider),
            const SizedBox(height: 16),
            PreviewSection(provider: provider),
          ],
        );
      },
    );
  }
}

class FontSizeSection extends StatelessWidget {
  final ReaderProvider provider;

  const FontSizeSection({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: '字体大小',
      child: Slider(
        value: provider.config.fontSize,
        min: 12,
        max: 32,
        divisions: 20,
        label: provider.config.fontSize.round().toString(),
        onChanged: provider.updateFontSize,
      ),
    );
  }
}

class LineHeightSection extends StatelessWidget {
  final ReaderProvider provider;

  const LineHeightSection({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: '行间距',
      child: Slider(
        value: provider.config.lineHeight,
        min: 1.0,
        max: 2.5,
        divisions: 15,
        label: provider.config.lineHeight.toStringAsFixed(1),
        onChanged: provider.updateLineHeight,
      ),
    );
  }
}

class ColorSection extends StatelessWidget {
  final ReaderProvider provider;

  const ColorSection({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: '颜色设置',
      child: Row(
        children: [
          Expanded(
            child: ColorPickerButton(
              label: '背景颜色',
              color: provider.config.backgroundColor,
              onColorChanged: provider.updateBackgroundColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ColorPickerButton(
              label: '文字颜色',
              color: provider.config.textColor,
              onColorChanged: provider.updateTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ColorPickerButton extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPicker(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: (color) {
              onColorChanged(color);
              Navigator.of(context).pop();
            },
            portraitOnly: true,
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
      ),
    );
  }
}

class FontFamilySection extends StatelessWidget {
  final ReaderProvider provider;
  static const List<String> fonts = ['System', 'Roboto', 'Serif', 'Monospace'];

  const FontFamilySection({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: '字体',
      child: Wrap(
        spacing: 8,
        children: fonts.map((font) => _buildFontChip(font)).toList(),
      ),
    );
  }

  Widget _buildFontChip(String font) {
    return ChoiceChip(
      label: Text(font),
      selected: provider.config.fontFamily == font,
      onSelected: (selected) {
        if (selected) {
          provider.updateFontFamily(font);
        }
      },
    );
  }
}

class DarkModeSection extends StatelessWidget {
  final ReaderProvider provider;

  const DarkModeSection({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('夜间模式'),
      value: provider.config.enableDarkMode,
      onChanged: provider.toggleDarkMode,
    );
  }
}

class PreviewSection extends StatelessWidget {
  final ReaderProvider provider;

  const PreviewSection({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '预览文本效果\n这是第二行文本\n这是第三行文本',
        style: TextStyle(
          fontSize: provider.config.fontSize,
          height: provider.config.lineHeight,
          color: provider.config.textColor,
          fontFamily: provider.config.fontFamily,
        ),
      ),
    );
  }
} 
