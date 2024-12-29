import 'package:flutter/material.dart';
import '../../core/reading/reading_settings.dart';

class ReadingSettingsPanel extends StatelessWidget {
  final ScrollMode currentScrollMode;
  final double currentBrightness;
  final Function(ScrollMode) onScrollModeChanged;
  final Function(double) onBrightnessChanged;
  final bool isDarkMode;
  final Color textColor;

  const ReadingSettingsPanel({
    Key? key,
    required this.currentScrollMode,
    required this.currentBrightness,
    required this.onScrollModeChanged,
    required this.onBrightnessChanged,
    required this.isDarkMode,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buildScrollModeSelector() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '阅读模式',
            style: TextStyle(color: textColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ScrollMode.values.map((mode) {
              final isSelected = mode == currentScrollMode;
              return ChoiceChip(
                label: Text(mode.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) onScrollModeChanged(mode);
                },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : textColor,
                ),
                backgroundColor: isDarkMode ? Colors.grey[800] : null,
              );
            }).toList(),
          ),
        ],
      );
    }

    Widget buildBrightnessControl() {
      return Row(
        children: [
          Icon(Icons.brightness_medium, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).primaryColor,
                thumbColor: Theme.of(context).primaryColor,
                inactiveTrackColor: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                overlayColor: Theme.of(context).primaryColor.withOpacity(0.12),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  pressedElevation: 8,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
                trackHeight: 4,
              ),
              child: Slider(
                value: currentBrightness,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                onChanged: onBrightnessChanged,
                onChangeStart: (value) => onBrightnessChanged(value),
                onChangeEnd: (value) => onBrightnessChanged(value),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(currentBrightness * 100).round()}%',
              style: TextStyle(color: textColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF333333) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '阅读设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // 翻页模式
          buildScrollModeSelector(),

          const SizedBox(height: 16),
          
          // 亮度调节
          buildBrightnessControl(),
        ],
      ),
    );
  }
} 