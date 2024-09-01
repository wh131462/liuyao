import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/pages/spinning/spinning.dart';

class SpinningPage extends StatefulWidget {
  @override
  _SpinningPageState createState() => _SpinningPageState();
}

class _SpinningPageState extends State<SpinningPage> {
  final BaGuaController upController = BaGuaController();
  final BaGuaController downController = BaGuaController();

  @override
  void dispose() {
    upController.dispose();
    downController.dispose();
    super.dispose();
  }

  void showResult(guaList) {
    var xiang = Xiang.getXiangByYaoList(guaList);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("卦象"),
          content: Text("当前卦象为${xiang.getGuaProps().fullName}"),
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
    final screenSize = MediaQuery.of(context).size;
    final largeWheelSize = screenSize.width; // 大转盘的直径是屏幕宽度
    final smallWheelSize = largeWheelSize / 2; // 小转盘的直径是大转盘的1/2
    final buttonSize = 80.0;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('摇卦'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // 大转盘
            Positioned(
              top: -largeWheelSize / 2, // 大转盘的中心点在顶点
              child: BaGuaWheelController(
                direction: Direction.down,
                size: largeWheelSize,
                controller: upController,
                onComplete: (Gua gua){
                },
              ),
            ),
            // 小转盘
            Positioned(
              top: largeWheelSize / 2 + 20, // 小转盘放在大转盘下方
              child: BaGuaWheelController(
                direction: Direction.up,
                size: smallWheelSize,
                controller: downController,
                onComplete: (Gua gua){
                },
              ),
            ),
            // 开始按钮
            Positioned(
              top: largeWheelSize / 2 +
                  20 +
                  (smallWheelSize / 2) -
                  (buttonSize / 2), // 开始按钮位于小转盘中心
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: ElevatedButton(
                  onPressed: () {
                    upController.startRotation();
                    downController.startRotation();
                  },
                  child: Text("摇卦"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
