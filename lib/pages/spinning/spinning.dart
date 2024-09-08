import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/utils/logger.dart';

enum Direction { up, down }

class BaGuaController {
  double rotation = 0.0;
  final Direction direction;
  Gua? currentGua; // 当前选中的内容
  Function? onStart;
  Function? onEnd;

  BaGuaController({this.direction = Direction.up});

  Gua getGua() {
    var guaList = Gua.getGuaListByPostnatalIndex();
    var unit = 2 * pi / guaList.length;
    var cur = direction == Direction.up ? rotation : rotation + pi;
    if (cur < 0) {
      cur += 2 * pi; // 保证 adjustedRotation 是正数
    }

    // 计算索引
    int index = (guaList.length - (cur / unit).floor()) % guaList.length;

    currentGua = guaList[index];
    // logger.info("当前旋转角度: $cur $unit 卦象索引: $index, 当前选中: ${guaList[index]}");
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
  final Function? onComplete;

  BaGuaWheelController({
    required this.size,
    required this.controller,
    this.onComplete,
  });

  @override
  _BaGuaWheelControllerState createState() => _BaGuaWheelControllerState();
}

class _BaGuaWheelControllerState extends State<BaGuaWheelController>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double currentRotation = 0.0; // 记录当前旋转角度
  double currentVelocity = 0.0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 监听动画
    _animationController.addListener(() {
      if (_animationController.isAnimating) {
        setState(() {
          if (!isDragging) {
            currentRotation = _animation.value % (2 * pi);
            widget.controller.rotation = currentRotation; // 更新到 controller
          }
        });
      }
    });

    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && !isDragging) {
        isDragging = false;
        // 先归位最近的卦象
        normalizeRotation(currentVelocity);
        widget.onComplete?.call(widget.controller.getGua());
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
      currentVelocity = randomRotation + targetRotation;
      _animationController.forward(from: 0.0);
    };
  }

  void normalizeRotation(double velocity) {
    var guaList = Gua.values.toList();
    var unit = 2 * pi / guaList.length;
    var diff = currentRotation % unit;
    if (diff == 0) return;
    double targetOffset;
    if (velocity < 0) {
      targetOffset = -diff;
    } else {
      targetOffset = unit - diff;
    }
    double targetRotation = currentRotation + targetOffset;

    _animation = Tween<double>(
      begin: currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));

    _animationController.duration = Duration(milliseconds: 300);
    _animationController.forward(from: 0.0);
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
        isDragging = true;
      },
      onPanUpdate: (details) {
        setState(() {
          final Offset center = Offset(widget.size / 2, widget.size / 2);
          final Offset touchPosition = details.localPosition;

          final double angleAtTouchPosition =
          atan2(touchPosition.dy - center.dy, touchPosition.dx - center.dx);

          // 计算前一次触摸位置的角度
          final double previousAngle = atan2(
              touchPosition.dy - center.dy - details.delta.dy,
              touchPosition.dx - center.dx - details.delta.dx);

          // 计算角度的差值，并更新当前旋转角度
          final double deltaAngle = angleAtTouchPosition - previousAngle;
          currentRotation += deltaAngle;
          widget.controller.rotation = currentRotation;
        });
      },
      onPanEnd: (details) {
        isDragging = false;
        final Offset center = Offset(widget.size / 2, widget.size / 2);
        final under = details.localPosition.dy > center.dy?-1:1;
        final double velocity =under* details.velocity.pixelsPerSecond.dx * 0.001;
        final int duration = (velocity.abs() * 500).clamp(200, 2000).toInt();
        _animationController.duration = Duration(milliseconds: duration);
        _animation = Tween<double>(
            begin: currentRotation,
            end: currentRotation + velocity * duration / 100)
            .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.decelerate));
        // 执行惯性动画，动画结束后再进行归一化
        currentVelocity = velocity;
        _animationController.forward(from: 0.0).then((_) {
          normalizeRotation(currentVelocity); // 惯性动画结束后，进行归一化
        });
      },
      child: Transform.rotate(
        angle: currentRotation,
        child: BaGuaWheel(size: widget.size, direction: widget.controller.direction),
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
