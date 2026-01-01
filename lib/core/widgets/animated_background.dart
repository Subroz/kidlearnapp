import 'dart:math';
import 'package:flutter/material.dart';

enum BackgroundTheme {
  home,
  math,
  draw,
  stories,
  speak,
  games,
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final BackgroundTheme theme;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.theme = BackgroundTheme.home,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late List<_FloatingShape> _shapes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _generateShapes();
  }

  void _generateShapes() {
    _shapes = List.generate(12, (index) {
      return _FloatingShape(
        type: _ShapeType.values[_random.nextInt(_ShapeType.values.length)],
        startX: _random.nextDouble(),
        startY: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 40,
        speed: 0.3 + _random.nextDouble() * 0.7,
        phase: _random.nextDouble() * 2 * pi,
      );
    });
  }

  List<Color> _getGradientColors() {
    switch (widget.theme) {
      case BackgroundTheme.home:
        return [
          const Color(0xFFF8F0FF),
          const Color(0xFFE8F4FF),
          const Color(0xFFFFF0F5),
        ];
      case BackgroundTheme.math:
        return [
          const Color(0xFFE3F2FD),
          const Color(0xFFE1F5FE),
          const Color(0xFFE8EAF6),
        ];
      case BackgroundTheme.draw:
        return [
          const Color(0xFFFFF8E1),
          const Color(0xFFFCE4EC),
          const Color(0xFFE8F5E9),
        ];
      case BackgroundTheme.stories:
        return [
          const Color(0xFFF3E5F5),
          const Color(0xFFEDE7F6),
          const Color(0xFFE8EAF6),
        ];
      case BackgroundTheme.speak:
        return [
          const Color(0xFFFFEBEE),
          const Color(0xFFFCE4EC),
          const Color(0xFFF3E5F5),
        ];
      case BackgroundTheme.games:
        return [
          const Color(0xFFE8F5E9),
          const Color(0xFFE0F7FA),
          const Color(0xFFFFF8E1),
        ];
    }
  }

  Color _getShapeColor() {
    switch (widget.theme) {
      case BackgroundTheme.home:
        return const Color(0xFF9C27B0).withAlpha(30);
      case BackgroundTheme.math:
        return const Color(0xFF2196F3).withAlpha(30);
      case BackgroundTheme.draw:
        return const Color(0xFFFF9800).withAlpha(30);
      case BackgroundTheme.stories:
        return const Color(0xFF673AB7).withAlpha(30);
      case BackgroundTheme.speak:
        return const Color(0xFFE91E63).withAlpha(30);
      case BackgroundTheme.games:
        return const Color(0xFF4CAF50).withAlpha(30);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getGradientColors();
    final shapeColor = _getShapeColor();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _FloatingShapesPainter(
                shapes: _shapes,
                progress: _floatController.value,
                color: shapeColor,
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

enum _ShapeType { circle, star, heart, cloud, diamond }

class _FloatingShape {
  final _ShapeType type;
  final double startX;
  final double startY;
  final double size;
  final double speed;
  final double phase;

  _FloatingShape({
    required this.type,
    required this.startX,
    required this.startY,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _FloatingShapesPainter extends CustomPainter {
  final List<_FloatingShape> shapes;
  final double progress;
  final Color color;

  _FloatingShapesPainter({
    required this.shapes,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final shape in shapes) {
      final animProgress = (progress * shape.speed + shape.phase) % 1.0;
      final x = shape.startX * size.width +
          sin(animProgress * 2 * pi) * 30;
      final y = shape.startY * size.height +
          cos(animProgress * 2 * pi * 0.7) * 20;

      canvas.save();
      canvas.translate(x, y);
      
      final scale = 0.8 + 0.2 * sin(animProgress * 2 * pi);
      canvas.scale(scale);

      switch (shape.type) {
        case _ShapeType.circle:
          canvas.drawCircle(Offset.zero, shape.size / 2, paint);
          break;
        case _ShapeType.star:
          _drawStar(canvas, shape.size / 2, paint);
          break;
        case _ShapeType.heart:
          _drawHeart(canvas, shape.size, paint);
          break;
        case _ShapeType.cloud:
          _drawCloud(canvas, shape.size, paint);
          break;
        case _ShapeType.diamond:
          _drawDiamond(canvas, shape.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final point = Offset(cos(angle) * radius, sin(angle) * radius);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final w = size * 0.5;
    final h = size * 0.5;
    path.moveTo(0, h * 0.3);
    path.cubicTo(-w * 0.5, -h * 0.3, -w, h * 0.3, 0, h);
    path.cubicTo(w, h * 0.3, w * 0.5, -h * 0.3, 0, h * 0.3);
    canvas.drawPath(path, paint);
  }

  void _drawCloud(Canvas canvas, double size, Paint paint) {
    final r = size * 0.2;
    canvas.drawCircle(Offset(-r, 0), r, paint);
    canvas.drawCircle(Offset(r, 0), r, paint);
    canvas.drawCircle(Offset(0, -r * 0.5), r * 1.2, paint);
  }

  void _drawDiamond(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final half = size / 2;
    path.moveTo(0, -half);
    path.lineTo(half * 0.6, 0);
    path.lineTo(0, half);
    path.lineTo(-half * 0.6, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FloatingShapesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
