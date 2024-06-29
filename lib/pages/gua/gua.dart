// 展示六十四卦
import 'package:flutter/material.dart';
import 'package:liuyao_flutter/constants/liuyao.const.dart';

class GuaPage extends StatefulWidget {
  @override
  _GuaPageState createState() => _GuaPageState();
}

class _GuaPageState extends State<GuaPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('六十四卦'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 开始排盘按钮
          ElevatedButton(
            onPressed: ()=>{
              print(Xiang.getXiangByTitle('乾').getGuaProps().rawDescription)
            },
            child: Text('查看'),
          ),
        ],
      ),
    );
  }
}

