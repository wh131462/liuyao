import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/pages/hexagrams/hexagram.detail.dart';
import 'package:liuyao/pages/spinning/spinning.dart';

import '../../utils/logger.dart';

class SpinningPage extends StatefulWidget {
  @override
  _SpinningPageState createState() => _SpinningPageState();
}

class _SpinningPageState extends State<SpinningPage> {
  final BaGuaController upController = BaGuaController(
      direction: Direction.down);
  final BaGuaController downController = BaGuaController(
      direction: Direction.up);
  late List<Gua> guaList;
  @override
  void initState() {
    super.initState();
    guaList = [upController.getGua(), downController.getGua()];
  }
  @override
  void dispose() {
    upController.dispose();
    downController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final largeWheelSize = screenSize.width; // 大转盘的直径是屏幕宽度
    final smallWheelSize = largeWheelSize / 2; // 小转盘的直径是大转盘的1/2
    final buttonSize = 80.0;
    return Scaffold(
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
              size: largeWheelSize,
              controller: upController,
              onComplete: (Gua gua) {
                setState(() {
                  logger.info("当前上卦:$gua");
                  guaList.first = gua;
                });
              },
            ),
          ),
          // 小转盘
          Positioned(
            top: largeWheelSize / 2 + 20, // 小转盘放在大转盘下方
            child: BaGuaWheelController(
              size: smallWheelSize,
              controller: downController,
              onComplete: (Gua gua) {
                setState(() {
                  logger.info("当前下卦:$gua");
                  guaList.last = gua;
                });
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
          Positioned(
            top: largeWheelSize / 2 +
                180 +
                (smallWheelSize / 2) -
                (buttonSize / 2), // 开始按钮位于小转盘中心
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HexagramDetailPage(hexagram: Xiang
                            .getXiangByYaoList(guaList)),
                  ),
                );
              },
              child: Text(guaList.length >= 2 ? Xiang
                  .getXiangByYaoList(guaList)
                  .getGuaProps()
                  .fullName : '',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),),),
          ),
        ],
      ),);
  }
}
