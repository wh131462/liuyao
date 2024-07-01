// 展示六十四卦
import 'package:flutter/material.dart';
import 'package:liuyao_flutter/constants/liuyao.const.dart';
import 'package:liuyao_flutter/constants/xiang.dictionary.dart';

class GuaPage extends StatefulWidget {
  @override
  _GuaPageState createState() => _GuaPageState();
}

class _GuaPageState extends State<GuaPage> {
  late XiangDicItem? _item;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _item = Xiang.getXiangByTitle('乾').getGuaProps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('六十四卦'),
      ),
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 开始排盘按钮
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _item = Xiang.getRandomXiang().getGuaProps();
                    print(_item?.name);
                  });
                },
                child: Text('查看'),
              ),
              RichText(
                  text: TextSpan(text: _item?.originalHexagram ?? '')),
            ]),
      ),
      backgroundColor: Colors.blue,
    );
  }
}
