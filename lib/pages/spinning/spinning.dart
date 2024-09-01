import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/utils/logger.dart';

enum Direction { up, down }
class BaGuaController {
  double rotation = 0.0;
  Direction direction = Direction.up;
  Gua? currentGua; // 当前选中的内容
  Function? onStart;
  Function? onEnd;

  BaGuaController();

  Gua getGua() {
    var guaList = Gua.values.toList();
    var unit = 2 * pi / guaList.length;

    // 调整 rotation 使其基于 Y 轴正上方
    double adjustedRotation = (rotation - pi / 2) % (2 * pi);

    if (adjustedRotation < 0) {
      adjustedRotation += 2 * pi;  // 保证 adjustedRotation 是正数
    }

    // 计算索引
    int index = (adjustedRotation / unit).floor() % guaList.length;

    currentGua = guaList[index];
    logger.info("当前角度: $rotation, Y 轴上方选中: ${guaList[index]}");
    return currentGua!;
  }

  void startRotation() {
    if (onStart != null) {
      onStart!();
    }
  }

  void stopRotation() {
    if (onEnd != null) {
      onEnd!();
    }
  }

  void dispose() {}
}

class BaGuaWheelController extends StatefulWidget {
  final double size;
  final BaGuaController controller;
  final Direction direction;
  final Function? onComplete;

  BaGuaWheelController(
      {required this.size,
        required this.controller,
        required this.direction,
        this.onComplete});

  @override
  _BaGuaWheelControllerState createState() => _BaGuaWheelControllerState();
}

class _BaGuaWheelControllerState extends State<BaGuaWheelController>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double currentRotation = 0.0; // 记录当前旋转角度

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // 监听动画
    _animationController.addListener(() {
      setState(() {
        currentRotation = _animation.value;
        widget.controller.rotation = currentRotation; // 更新到 controller
        logger.info("进行中 $currentRotation");
      });
    });

    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        widget.controller.stopRotation();
        widget.onComplete?.call(widget.controller.getGua());
        logger.info("完成 $currentRotation");
      }
    });

    widget.controller.onStart = () {
      final int randomDuration = Random().nextInt(3) + 1;
      final double randomRotation = 2 * pi * Random().nextDouble();

      final double normalizedRotation = currentRotation % (2 * pi);
      final double targetRotation = 2 * pi - normalizedRotation;

      _animationController.duration = Duration(seconds: randomDuration);

      _animation = Tween<double>(
          begin: currentRotation,
          end: currentRotation + randomRotation + targetRotation)
          .animate(CurvedAnimation(
          parent: _animationController, curve: Curves.decelerate));

      _animationController.forward(from: 0.0);
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _animationController.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          final Offset center = Offset(widget.size / 2, widget.size / 2);
          final Offset touchPosition = details.localPosition;

          final double angleAtTouchPosition =
          atan2(touchPosition.dy - center.dy, touchPosition.dx - center.dx);

          final double previousAngle = atan2(
              touchPosition.dy - center.dy - details.delta.dy,
              touchPosition.dx - center.dx - details.delta.dx);

          final double deltaAngle = angleAtTouchPosition - previousAngle;
          currentRotation += deltaAngle;
          widget.controller.rotation = currentRotation;
        });
      },
      onPanEnd: (details) {
        final double velocity = details.velocity.pixelsPerSecond.dx * 0.001;
        final int duration = (velocity.abs() * 500)
            .clamp(200, 2000)
            .toInt();

        _animationController.duration = Duration(milliseconds: duration);
        _animation = Tween<double>(
            begin: currentRotation,
            end: currentRotation + velocity * duration / 100)
            .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.decelerate));
        _animationController.forward(from: 0.0);
      },
      child: Transform.rotate(
        angle: currentRotation,
        child: BaGuaWheel(size: widget.size, direction: widget.direction),
      ),
    );
  }
}


class BaGuaPainter extends CustomPainter {
  final List<Gua> guaList = Gua.getGuaListByPostnatalIndex();
  final Direction direction;

  BaGuaPainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width / 2, size.height / 2);
    final double angle = 2 * pi / guaList.length;

    for (int i = 0; i < guaList.length; i++) {
      // 将 labelAngle 以 -pi/2 为起点，使第一个卦象在 Y 轴正上方
      final double labelAngle = i * angle - pi / 2;
      final double labelRadius = radius * 0.85;
      final Offset labelOffset = Offset(
        size.width / 2 + labelRadius * cos(labelAngle),
        size.height / 2 + labelRadius * sin(labelAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: "${guaList[i].name}\n${guaList[i].symbol}",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);

      // 根据方向调整字体的旋转角度
      if (direction == Direction.up) {
        canvas.rotate(labelAngle + pi / 2);
      } else {
        canvas.rotate(labelAngle - pi / 2);
      }

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BaGuaWheel extends StatelessWidget {
  final double size;
  final Direction direction;

  BaGuaWheel({required this.size, required this.direction});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BaGuaPainter(direction: direction),
    );
  }
}
