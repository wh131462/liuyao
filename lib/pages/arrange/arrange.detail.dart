import 'package:flutter/material.dart';
import 'package:liuyao_flutter/constants/liuyao.const.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('排卦结果'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("求问: $question", style: const TextStyle(fontSize:32,color: Colors.black, fontWeight: FontWeight.bold)),
            const Text('本卦:', style: TextStyle(fontSize:32,color: Colors.blue, fontWeight: FontWeight.bold)),
            Text(Hexagram.original.description, style: const TextStyle(fontSize:18,color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            originalHexagram.getGuaProps().getFullRichText(),
            const Text('变卦:', style: TextStyle(fontSize:32,color: Colors.blue, fontWeight: FontWeight.bold)),
            Text(Hexagram.transformed.description, style: const TextStyle(fontSize:18,color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            transformedHexagram.getGuaProps().getFullRichText(),
            const Text('错卦:', style: TextStyle(fontSize:32,color: Colors.blue, fontWeight: FontWeight.bold)),
            Text(Hexagram.reversed.description, style: const TextStyle(fontSize:18,color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            reversedHexagram.getGuaProps().getFullRichText(),
            const Text('互卦:', style: TextStyle(fontSize:32,color: Colors.blue, fontWeight: FontWeight.bold)),
            Text(Hexagram.mutual.description, style: const TextStyle(fontSize:18,color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            mutualHexagram.getGuaProps().getFullRichText(),
            const Text('综卦:', style: TextStyle(fontSize:32,color: Colors.blue, fontWeight: FontWeight.bold)),
            Text(Hexagram.opposite.description, style: const TextStyle(fontSize:18,color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            oppositeHexagram.getGuaProps().getFullRichText(),
          ],
        ),
      ),
    );
  }
}
