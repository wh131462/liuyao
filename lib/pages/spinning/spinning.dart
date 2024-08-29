import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:widget_spinning_wheel/widget_spinning_wheel.dart';

class SpinningWheelPage extends StatefulWidget {
  @override
  _SpinningWheelPageState createState() => _SpinningWheelPageState();
}

class _SpinningWheelPageState extends State<SpinningWheelPage> {
  final StreamController<int> _dividerController = StreamController<int>();

  @override
  void dispose() {
    _dividerController.close();
    super.dispose();
  }

  void _showDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("卦象"),
          content: Text("卦象为 $result"),
          actions: <Widget>[
            TextButton(
              child: Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('转盘页面'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          WidgetSpinningWheel(
            labels: Xiang.values.map((Xiang xiang){return xiang.getGuaProps().fullName;}).toList(),
            onSpinComplete: (String label) {
              _showDialog(label);
            },
            size: 400,
          ),
          SizedBox(height: 50),
          StreamBuilder<int>(
            stream: _dividerController.stream,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text('正在选中: ${snapshot.data}',
                  style: TextStyle(fontSize: 24))
                  : Container();
            },
          ),
        ],
      ),
    );
  }
}
