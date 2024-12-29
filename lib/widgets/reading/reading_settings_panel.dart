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
          Text('翻页模式', style: TextStyle(color: textColor)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ScrollMode.values.map((mode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      mode.label,
                      style: TextStyle(
                        color: currentScrollMode == mode 
                            ? Colors.white 
                            : textColor,
                      ),
                    ),
                    selected: currentScrollMode == mode,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: isDarkMode ? Colors.grey[800] : null,
                    onSelected: (selected) {
                      if (selected) {
                        onScrollModeChanged(mode);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          
          // 亮度调节
          Row(
            children: [
              Icon(Icons.brightness_medium, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).primaryColor,
                    thumbColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  ),
                  child: Slider(
                    value: currentBrightness,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    onChanged: onBrightnessChanged,
                  ),
                ),
              ),
              Text(
                '${(currentBrightness * 100).round()}%',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 