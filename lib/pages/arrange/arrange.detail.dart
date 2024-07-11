import 'package:flutter/material.dart';
import 'package:liuyao_flutter/constants/liuyao.const.dart';
import 'package:liuyao_flutter/pages/hexagrams/hexagram.detail.dart';

class ArrangeDetailPage extends StatelessWidget {
  final String question;
  final Xiang originalHexagram;
  final Xiang transformedHexagram;
  final Xiang reversedHexagram;
  final Xiang mutualHexagram;
  final Xiang oppositeHexagram;

  // 通过构造函数传递解析结果
  const ArrangeDetailPage({
    required this.question,
    required this.originalHexagram,
    required this.transformedHexagram,
    required this.reversedHexagram,
    required this.mutualHexagram,
    required this.oppositeHexagram,
  });

  /// 获取跳转文本按钮
  GestureDetector getTextButton(
      BuildContext context, String label, Xiang hexagram) {
    return GestureDetector(
        child: Text('$label: ${hexagram.getGuaProps().name}',
            style: const TextStyle(
                fontSize: 32, color: Colors.blue, fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HexagramDetailPage(hexagram: hexagram),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排卦结果'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("求问: $question",
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            getTextButton(context, "本卦", originalHexagram),
            Text(Hexagram.original.description,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold)),
            Text(originalHexagram.getGuaProps().originalHexagram),
            getTextButton(context, "变卦", transformedHexagram),
            Text(Hexagram.transformed.description,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold)),
            Text(transformedHexagram.getGuaProps().originalHexagram),
            getTextButton(context, "错卦", reversedHexagram),
            Text(Hexagram.reversed.description,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold)),
            Text(reversedHexagram.getGuaProps().originalHexagram),
            getTextButton(context, "互卦", mutualHexagram),
            Text(Hexagram.mutual.description,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold)),
            Text(mutualHexagram.getGuaProps().originalHexagram),
            getTextButton(context, "综卦", oppositeHexagram),
            Text(Hexagram.opposite.description,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold)),
            Text(oppositeHexagram.getGuaProps().originalHexagram),
          ],
        ),
      ),
    );
  }
}
