import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liuyao_flutter/constants/liuyao.const.dart';
import 'package:liuyao_flutter/pages/arrange/arrange.detail.dart';
import 'package:liuyao_flutter/utils/liuyao.util.dart';

class ArrangePage extends StatefulWidget {
  @override
  _ArrangePageState createState() => _ArrangePageState();
}

class _ArrangePageState extends State<ArrangePage> {
  // 用于存储输入的六位数字
  final TextEditingController _numberEditingController =
      TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();

  // 随机生成六位数字的方法
  String generateRandomNumber() {
    const String possibleCharacters = '6789';
    const int length = 6;
    var random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) {
      return possibleCharacters
          .codeUnitAt(random.nextInt(possibleCharacters.length));
    }));
  }

  // 在 _ArrangePageState 类中添加一个方法来处理跳转
  void _navigateToResultPage() {
    if (_numberEditingController.text.isNotEmpty) {
      Map<Hexagram, Xiang> map = LiuYaoUtil.getHexagramsByText(_numberEditingController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArrangeDetailPage(
            question: _textEditingController.text!,
            originalHexagram: map[Hexagram.original]!,
            transformedHexagram: map[Hexagram.transformed]!,
            reversedHexagram: map[Hexagram.reversed]!,
            mutualHexagram: map[Hexagram.mutual]!,
            oppositeHexagram: map[Hexagram.opposite]!,
          ),
        ),
      );
    }
  }

  // 处理赛博摇卦按钮点击事件
  void _cyberShake() {
    setState(() {
      _numberEditingController.text = generateRandomNumber();
      print(_numberEditingController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('排卦页面'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 新的文本输入框，用于输入“何惑？”
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: '何惑？',
              hintStyle: TextStyle(fontSize: 18),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
            ),
          ),
          SizedBox(height: 20), // 用于添加输入框和按钮之间的间距

          // 数字输入框，限定为6位数字
          TextField(
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow('6789')],
            controller: _numberEditingController,
            decoration: InputDecoration(
              hintText: '答案在其中',
              hintStyle: TextStyle(fontSize: 18),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
            ),
          ),
          SizedBox(height: 20), // 用于添加输入框和按钮之间的间距
          // 赛博摇卦按钮
          ElevatedButton(
            onPressed: _cyberShake,
            child: Text('赛博摇卦'),
          ),
          SizedBox(height: 10), // 按钮间距

          // 开始排盘按钮
          ElevatedButton(
            onPressed: _navigateToResultPage,
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
      if (!_allowedCharacters.contains(filtered[i])) {
        filtered = filtered.replaceRange(i, i + 1, '');
      }
    }
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
