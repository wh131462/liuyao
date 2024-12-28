import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/pages/hexagrams/hexagram.detail.dart';
import 'package:liuyao/pages/spinning/spinning.dart';

import '../../utils/logger.dart';

class SpinningPage extends StatefulWidget {
  @override
  _SpinningPageState createState() => _SpinningPageState();
}

class _SpinningPageState extends State<SpinningPage> with SingleTickerProviderStateMixin {
  final BaGuaController upController = BaGuaController(direction: Direction.down);
  final BaGuaController downController = BaGuaController(direction: Direction.up);
  late List<Gua> guaList;
  bool isSpinning = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    guaList = [upController.getGua(), downController.getGua()];
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut)
    );
  }

  void _updateResult(Gua gua, bool isUpper) {
    final oldGua = isUpper ? guaList[0] : guaList[1];
    if (oldGua != gua) {
      setState(() {
        if (isUpper) {
          guaList[0] = gua;
        } else {
          guaList[1] = gua;
        }
      });
      
      _fadeController.forward(from: 0.0);
    }
  }

  void _startSpinning() {
    setState(() {
      isSpinning = true;
    });
    // 开始旋转时重置动画
    _fadeController.stop();
    _fadeController.value = 1.0;
    upController.startRotation();
    downController.startRotation();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    upController.dispose();
    downController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final largeWheelSize = screenSize.width;
    final smallWheelSize = largeWheelSize / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('摇卦'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 大转盘
          Positioned(
            top: -largeWheelSize / 2,
            child: BaGuaWheelController(
              size: largeWheelSize,
              controller: upController,
              onComplete: (Gua gua) {
                _updateResult(gua, true);
                if (!downController.isSpinning) {
                  setState(() => isSpinning = false);
                }
              },
            ),
          ),
          // 小转盘
          Positioned(
            top: largeWheelSize / 2 + 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                BaGuaWheelController(
                  size: smallWheelSize,
                  controller: downController,
                  onComplete: (Gua gua) {
                    _updateResult(gua, false);
                    if (!upController.isSpinning) {
                      setState(() => isSpinning = false);
                    }
                  },
                ),
                if (isSpinning)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          // 结果显示
          Positioned(
            top: largeWheelSize / 2 + 180 + (smallWheelSize / 2),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TextButton(
                onPressed: isSpinning ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HexagramDetailPage(
                        hexagram: Xiang.getXiangByYaoList(guaList)
                      ),
                    ),
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    guaList.length >= 2 
                      ? Xiang.getXiangByYaoList(guaList).getGuaProps().fullName 
                      : '',
                    key: ValueKey('${guaList[0].name}-${guaList[1].name}'), // 添加key以触发动画
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 36
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaijiPainter extends CustomPainter {
  final Color darkColor;
  final Color lightColor;
  final bool isHalf; // 添加是否只显示一半的标志

  TaijiPainter({
    this.darkColor = Colors.black,
    this.lightColor = Colors.white,
    this.isHalf = false, // 默认显示完整太极
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final paint = Paint()..style = PaintingStyle.fill;

    if (isHalf) {
      // 绘制半个太极图
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, radius, size.width, size.height));
      
      // 绘制白色背景
      paint.color = lightColor;
      canvas.drawCircle(center, radius, paint);
      
      // 绘制黑色部分
      paint.color = darkColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi/2, pi, true, paint
      );

      // 绘制小圆
      final smallRadius = radius / 3;
      paint.color = lightColor;
      canvas.drawCircle(
        Offset(radius, radius + smallRadius/2),
        smallRadius,
        paint
      );
      paint.color = darkColor;
      canvas.drawCircle(
        Offset(radius, radius + smallRadius/2),
        smallRadius/3,
        paint
      );

      canvas.restore();
    } else {
      // 绘制整太极图（用于按钮）
      // 绘制白色背景
      paint.color = lightColor;
      canvas.drawCircle(center, radius, paint);
      
      // 绘制黑色半圆
      paint.color = darkColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi/2, pi, true, paint
      );

      // 绘制两个小圆
      final smallRadius = radius / 3;
      
      // 上白下黑
      paint.color = lightColor;
      canvas.drawCircle(
        Offset(radius, radius - smallRadius/2),
        smallRadius,
        paint
      );
      paint.color = darkColor;
      canvas.drawCircle(
        Offset(radius, radius + smallRadius/2),
        smallRadius,
        paint
      );

      // 内部小圆点
      paint.color = darkColor;
      canvas.drawCircle(
        Offset(radius, radius - smallRadius/2),
        smallRadius/3,
        paint
      );
      paint.color = lightColor;
      canvas.drawCircle(
        Offset(radius, radius + smallRadius/2),
        smallRadius/3,
        paint
      );

      // 绘制边框
      paint
        ..style = PaintingStyle.stroke
        ..color = darkColor
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius - 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleArrowPainter extends CustomPainter {
  final Color color;

  TriangleArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
