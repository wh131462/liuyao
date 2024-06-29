import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArrangePage extends StatefulWidget {
  @override
  _ArrangePageState createState() => _ArrangePageState();
}

class _ArrangePageState extends State<ArrangePage> {
  // 用于存储输入的六位数字
  String _inputNumber = '';

  // 随机生成六位数字的方法
  String generateRandomNumber() {
    const String possibleCharacters = '6789';
    const int length = 6;
    var random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) {
      return possibleCharacters.codeUnitAt(random.nextInt(possibleCharacters.length));
    }));
  }

  // 处理开始排盘按钮点击事件
  void _startArrangement() {
    // 这里可以添加开始排盘的逻辑
    print('开始排盘，输入的数字为: $_inputNumber');
    // 根据需要添加其他逻辑
  }

  // 处理赛博摇卦按钮点击事件
  void _cyberShake() {
    setState(() {
      _inputNumber = generateRandomNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('排盘页面'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 输入框，限定为6位数字
          TextField(
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [
              // 限制只能输入数字6789
              FilteringTextInputFormatter.allow('6789')
            ],
            onChanged: (value) {
              setState(() {
                _inputNumber = value;
              });
            },
          ),
          SizedBox(height: 20), // 用于添加按钮之间的间距
          // 赛博摇卦按钮
          ElevatedButton(
            onPressed: _cyberShake,
            child: Text('赛博摇卦'),
          ),
          // 开始排盘按钮
          ElevatedButton(
            onPressed: _startArrangement,
            child: Text('开始排盘'),
          ),
        ],
      ),
    );
  }
}

// 输入格式化器，用于限制只能输入特定的字符
class FilteringTextInputFormatter extends TextInputFormatter {
  final String _allowedCharacters;

  FilteringTextInputFormatter.allow(this._allowedCharacters);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String filtered = newValue.text;
    for (int i = 0; i < filtered.length; i++) {
      if (_allowedCharacters.indexOf(filtered[i]) == -1) {
        filtered = filtered.replaceRange(i, i + 1, '');
      }
    }
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}