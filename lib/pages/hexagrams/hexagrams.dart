// 展示六十四卦
import 'package:flutter/material.dart';
import 'package:liuyao_flutter/constants/liuyao.const.dart';
import 'package:liuyao_flutter/constants/xiang.dictionary.dart';

import 'hexagram.detail.dart';

class HexagramsPage extends StatefulWidget {
  @override
  _HexagramsPageState createState() => _HexagramsPageState();
}

class _HexagramsPageState extends State<HexagramsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('六十四卦'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: Xiang.values.length,
        itemBuilder: (context, index) {
          return HexagramCard(Xiang.getXiangByIndex(index+1));
        },
      ),
    );
  }
}

class HexagramCard extends StatelessWidget {
  final Xiang hexagram;

  HexagramCard(this.hexagram);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HexagramDetailPage(hexagram: hexagram),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(text: TextSpan(text: hexagram.getSymbolText(), style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 14,height: 0.9))),
            Text(hexagram.name),
            Text("(${hexagram.getGuaProps().fullName})"),
            // 这里可以添加更多的信息展示，例如卦象的图片等
          ],
        ),
      ),
    );
  }
}
