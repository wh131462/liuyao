import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';

enum Direction { up, down }

class BaGuaController {
  double rotation = 0.0;
  final Direction direction;
  Gua? currentGua; // 当前选中的内容
  Function? onStart;
  Function? onEnd;
  bool isSpinning = false;

  BaGuaController({this.direction = Direction.up});

  Gua getGua() {
    var guaList = Gua.getGuaListByPostnatalIndex();
    var unit = 2 * pi / guaList.length;
    
    // 调整角度计算
    var cur = rotation % (2 * pi);
    if (cur < 0) {
      cur += 2 * pi;
    }

    // 计算基础索引
    int baseIndex = ((2 * pi - cur + unit / 2) / unit).floor() % guaList.length;
    
    // 根据方向调整索引
    int index;
    if (direction == Direction.down) {
      // 下模式（大转盘）：取下方卦象作为上卦
      index = (baseIndex + guaList.length / 2).floor() % guaList.length;
    } else {
      // 上模式（小转盘）：取上方卦象作为下卦
      index = baseIndex;
    }

    currentGua = guaList[index];
    return currentGua!;
  }

  void startRotation() {
    isSpinning = true;
    if (onStart != null) {
      onStart!();
    }
  }

  void stopRotation() {
    isSpinning = false;
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
  final bool showTaiji;
  final bool isSmall;

  BaGuaWheelController({
    required this.size,
    required this.controller,
    this.onComplete,
    this.showTaiji = true,
    this.isSmall = false,
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

    // 监听
    _animationController.addListener(() {
      if (_animationController.isAnimating) {
        setState(() {
          if (!isDragging) {
            currentRotation = _animation.value % (2 * pi);
            widget.controller.rotation = currentRotation;
          }
        });
      }
    });

    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && !isDragging) {
        isDragging = false;
        // 先归位最近的卦象
        normalizeRotation(currentVelocity);
        widget.controller.stopRotation();
        widget.onComplete?.call(widget.controller.getGua());
      }
    });

    widget.controller.onStart = () {
      // 随机生成2-5秒的转动时间
      final int randomDuration = Random().nextInt(4) + 2;
      // 随机生成3-6圈的转动圈数
      final double randomRotation = 2 * pi * (Random().nextDouble() * 3 + 3);
      final double normalizedRotation = currentRotation % (2 * pi);
      final double targetRotation = 2 * pi - normalizedRotation;

      _animationController.duration = Duration(seconds: randomDuration);

      _animation = Tween<double>(
        begin: currentRotation,
        end: currentRotation + randomRotation + targetRotation,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,  // 使用更自然的缓动曲线
      ));

      currentVelocity = randomRotation + targetRotation;
      _animationController.forward(from: 0.0);
    };
  }

  void normalizeRotation(double velocity) {
    var guaList = Gua.values.toList();
    var unit = 2 * pi / guaList.length;
    
    var normalizedRotation = currentRotation % (2 * pi);
    if (normalizedRotation < 0) {
      normalizedRotation += 2 * pi;
    }
    
    var targetSegment = ((normalizedRotation + unit / 2) / unit).floor();
    var targetRotation = targetSegment * unit;
    
    if (velocity > 0 && targetRotation < normalizedRotation) {
      targetRotation += unit;
    } else if (velocity < 0 && targetRotation > normalizedRotation) {
      targetRotation -= unit;
    }

    _animation = Tween<double>(
      begin: currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.duration = const Duration(milliseconds: 300);
    _animationController.forward(from: 0.0);
  }

  void _handlePanStart(DragStartDetails details) {
    _animationController.stop();
    isDragging = true;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      final Offset center = Offset(widget.size / 2, widget.size / 2);
      final Offset touchPosition = details.localPosition;

      final double angleAtTouchPosition =
          atan2(touchPosition.dy - center.dy, touchPosition.dx - center.dx);

      final double previousAngle = atan2(
          touchPosition.dy - center.dy - details.delta.dy,
          touchPosition.dx - center.dx - details.delta.dx);

      double deltaAngle = angleAtTouchPosition - previousAngle;
      
      if (deltaAngle > pi) {
        deltaAngle -= 2 * pi;
      } else if (deltaAngle < -pi) {
        deltaAngle += 2 * pi;
      }

      currentRotation += deltaAngle;
      widget.controller.rotation = currentRotation;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    isDragging = false;
    final Offset center = Offset(widget.size / 2, widget.size / 2);
    final under = details.localPosition.dy > center.dy ? -1 : 1;
    final double velocity = under * details.velocity.pixelsPerSecond.dx * 0.001;
    final int duration = (velocity.abs() * 500).clamp(200, 2000).toInt();
    
    _animationController.duration = Duration(milliseconds: duration);
    _animation = Tween<double>(
      begin: currentRotation,
      end: currentRotation + velocity * duration / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));

    currentVelocity = velocity;
    _animationController.forward(from: 0.0).then((_) {
      normalizeRotation(currentVelocity);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Transform.rotate(
        angle: currentRotation,
        child: BaGuaWheel(
          size: widget.size,
          direction: widget.controller.direction,
          isSpinning: widget.controller.isSpinning,
          currentGua: widget.controller.currentGua,
          onTap: () {
            if (!widget.controller.isSpinning) {
              widget.controller.startRotation();
            }
          },
        ),
      ),
    );
  }
}

class BaGuaPainter extends CustomPainter {
  final List<Gua> guaList = Gua.getGuaListByPostnatalIndex();
  final Direction direction;
  final double taijiRadius;
  final bool isSpinning;
  final Gua? currentGua;

  BaGuaPainter({
    required this.direction,
    this.taijiRadius = 0.45,
    this.isSpinning = false,
    this.currentGua,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width / 2, size.height / 2);
    final double angle = 2 * pi / guaList.length;
    final center = Offset(size.width / 2, size.height / 2);

    // 绘制卦象文字和符号
    for (int i = 0; i < guaList.length; i++) {
      final double labelAngle = i * angle - pi / 2;
      final double labelRadius = radius * 0.85;
      final Offset labelOffset = Offset(
        center.dx + labelRadius * cos(labelAngle),
        center.dy + labelRadius * sin(labelAngle),
      );

      // 判断是否是当前选中的卦象
      final bool isCurrentGua = !isSpinning && 
          currentGua != null && 
          guaList[i] == currentGua;

      // 根据方向决定文字和符号的顺序
      final String text = direction == Direction.up 
          ? "${guaList[i].symbol}\n${guaList[i].name}"
          : "${guaList[i].name}\n${guaList[i].symbol}";

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      // 文字旋转方向保持不变
      canvas.rotate(direction == Direction.up ? labelAngle + pi / 2 : labelAngle - pi / 2);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // 绘制中心太极图
    final taijiSize = radius * taijiRadius * 2;
    final paint = Paint()..style = PaintingStyle.fill;

    // 绘制白色背景
    paint.color = Colors.white;
    canvas.drawCircle(center, taijiSize / 2, paint);
    
    // 绘制黑色半圆
    paint.color = Colors.black;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: taijiSize / 2),
      -pi/2, pi, true, paint
    );

    // 调整阴阳鱼的比例
    final fishRadius = taijiSize * 0.25; // 保持阴阳鱼大小为太极图的1/4
    final offset = taijiSize * 0.25; // 稍微调整偏移量，阴阳鱼更贴近边缘
    
    // 上白下黑
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx, center.dy - offset),
      fishRadius,
      paint
    );
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx, center.dy + offset),
      fishRadius,
      paint
    );

    // 调整内部小圆点大小
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx, center.dy - offset),
      fishRadius * 0.18, // ��小一点点
      paint
    );
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx, center.dy + offset),
      fishRadius * 0.18,
      paint
    );

    // 绘制边框调整边框粗细
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 0.8; // 调细一点
    canvas.drawCircle(center, taijiSize / 2 - 0.4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BaGuaWheel extends StatelessWidget {
  final double size;
  final Direction direction;
  final bool isSpinning;
  final Gua? currentGua;
  final VoidCallback? onTap;

  BaGuaWheel({
    required this.size,
    required this.direction,
    this.isSpinning = false,
    this.currentGua,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter: BaGuaPainter(
          direction: direction,
          isSpinning: isSpinning,
          currentGua: currentGua,
        ),
      ),
    );
  }
}

