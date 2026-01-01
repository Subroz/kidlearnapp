import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ScreenTheme {
  home,
  math,
  draw,
  stories,
  speak,
  games,
  alphabet,
}

class ScreenBackground extends StatefulWidget {
  final Widget child;
  final bool showFloatingShapes;
  final List<Color>? gradientColors;
  final ScreenTheme theme;

  const ScreenBackground({
    super.key,
    required this.child,
    this.showFloatingShapes = true,
    this.gradientColors,
    this.theme = ScreenTheme.home,
  });

  @override
  State<ScreenBackground> createState() => _ScreenBackgroundState();
}

class _ScreenBackgroundState extends State<ScreenBackground>
    with TickerProviderStateMixin {
  late List<FloatingShape> _shapes;
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeShapes();
  }

  List<Color> _getThemeGradient() {
    switch (widget.theme) {
      case ScreenTheme.home:
        return [
          const Color(0xFFF8F0FF),
          const Color(0xFFE8F4FF),
          const Color(0xFFFFF0F5),
          const Color(0xFFF0FFF4),
        ];
      case ScreenTheme.math:
        return [
          const Color(0xFFE3F2FD),
          const Color(0xFFBBDEFB),
          const Color(0xFFE1F5FE),
          const Color(0xFFB3E5FC),
        ];
      case ScreenTheme.draw:
        return [
          const Color(0xFFFFF8E1),
          const Color(0xFFFFECB3),
          const Color(0xFFFCE4EC),
          const Color(0xFFF8BBD9),
        ];
      case ScreenTheme.stories:
        return [
          const Color(0xFFF3E5F5),
          const Color(0xFFE1BEE7),
          const Color(0xFFEDE7F6),
          const Color(0xFFD1C4E9),
        ];
      case ScreenTheme.speak:
        return [
          const Color(0xFFFFEBEE),
          const Color(0xFFFFCDD2),
          const Color(0xFFFCE4EC),
          const Color(0xFFF8BBD9),
        ];
      case ScreenTheme.games:
        return [
          const Color(0xFFE8F5E9),
          const Color(0xFFC8E6C9),
          const Color(0xFFE0F7FA),
          const Color(0xFFB2EBF2),
        ];
      case ScreenTheme.alphabet:
        return [
          const Color(0xFFFFF3E0),
          const Color(0xFFFFE0B2),
          const Color(0xFFFFF8E1),
          const Color(0xFFFFECB3),
        ];
    }
  }

  List<Color> _getThemeShapeColors() {
    switch (widget.theme) {
      case ScreenTheme.home:
        return [
          AppTheme.primaryPurple.withAlpha(40),
          AppTheme.primaryBlue.withAlpha(35),
          AppTheme.primaryPink.withAlpha(35),
          AppTheme.primaryGreen.withAlpha(30),
        ];
      case ScreenTheme.math:
        return [
          const Color(0xFF2196F3).withAlpha(45),
          const Color(0xFF03A9F4).withAlpha(40),
          const Color(0xFF00BCD4).withAlpha(35),
          const Color(0xFF3F51B5).withAlpha(35),
        ];
      case ScreenTheme.draw:
        return [
          const Color(0xFFFF9800).withAlpha(45),
          const Color(0xFFFF5722).withAlpha(40),
          const Color(0xFFFFEB3B).withAlpha(35),
          const Color(0xFFE91E63).withAlpha(35),
        ];
      case ScreenTheme.stories:
        return [
          const Color(0xFF9C27B0).withAlpha(45),
          const Color(0xFF673AB7).withAlpha(40),
          const Color(0xFF7C4DFF).withAlpha(35),
          const Color(0xFFE040FB).withAlpha(35),
        ];
      case ScreenTheme.speak:
        return [
          const Color(0xFFE91E63).withAlpha(45),
          const Color(0xFFF06292).withAlpha(40),
          const Color(0xFFFF4081).withAlpha(35),
          const Color(0xFFFF80AB).withAlpha(35),
        ];
      case ScreenTheme.games:
        return [
          const Color(0xFF4CAF50).withAlpha(45),
          const Color(0xFF8BC34A).withAlpha(40),
          const Color(0xFF00BCD4).withAlpha(35),
          const Color(0xFF009688).withAlpha(35),
        ];
      case ScreenTheme.alphabet:
        return [
          const Color(0xFFFF9800).withAlpha(45),
          const Color(0xFFFFC107).withAlpha(40),
          const Color(0xFFFFEB3B).withAlpha(35),
          const Color(0xFFFF5722).withAlpha(35),
        ];
    }
  }

  void _initializeShapes() {
    final random = Random();
    final shapeColors = _getThemeShapeColors();
    
    _shapes = List.generate(10, (index) {
      return FloatingShape(
        type: ShapeType.values[random.nextInt(ShapeType.values.length)],
        color: shapeColors[index % shapeColors.length],
        size: 25 + random.nextDouble() * 50,
        initialX: random.nextDouble(),
        initialY: random.nextDouble(),
        duration: Duration(seconds: 12 + random.nextInt(10)),
      );
    });

    _controllers = _shapes.map((shape) {
      final controller = AnimationController(
        duration: shape.duration,
        vsync: this,
      )..repeat(reverse: true);
      return controller;
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? _getThemeGradient();
    
    final stops = List.generate(
      colors.length,
      (index) => index / (colors.length - 1),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: stops,
        ),
      ),
      child: Stack(
        children: [
          if (widget.showFloatingShapes)
            ...List.generate(_shapes.length, (index) {
              return AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) {
                  final shape = _shapes[index];
                  final progress = _controllers[index].value;
                  
                  return Positioned(
                    left: MediaQuery.of(context).size.width *
                        (shape.initialX + sin(progress * pi * 2) * 0.08),
                    top: MediaQuery.of(context).size.height *
                        (shape.initialY + cos(progress * pi * 2) * 0.06),
                    child: Opacity(
                      opacity: 0.6 + 0.4 * sin(progress * pi),
                      child: Transform.rotate(
                        angle: progress * pi * 0.3,
                        child: Transform.scale(
                          scale: 0.85 + 0.15 * sin(progress * pi * 2),
                          child: _buildShape(shape),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          widget.child,
        ],
      ),
    );
  }

  Widget _buildShape(FloatingShape shape) {
    switch (shape.type) {
      case ShapeType.circle:
        return Container(
          width: shape.size,
          height: shape.size,
          decoration: BoxDecoration(
            color: shape.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shape.color.withAlpha(30),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      case ShapeType.star:
        return CustomPaint(
          size: Size(shape.size, shape.size),
          painter: StarPainter(color: shape.color),
        );
      case ShapeType.triangle:
        return CustomPaint(
          size: Size(shape.size, shape.size),
          painter: TrianglePainter(color: shape.color),
        );
      case ShapeType.square:
        return Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: shape.size * 0.7,
            height: shape.size * 0.7,
            decoration: BoxDecoration(
              color: shape.color,
              borderRadius: BorderRadius.circular(shape.size * 0.15),
            ),
          ),
        );
      case ShapeType.heart:
        return CustomPaint(
          size: Size(shape.size, shape.size),
          painter: HeartPainter(color: shape.color),
        );
      case ShapeType.cloud:
        return CustomPaint(
          size: Size(shape.size * 1.5, shape.size),
          painter: CloudPainter(color: shape.color),
        );
    }
  }
}

enum ShapeType { circle, star, triangle, square, heart, cloud }

class FloatingShape {
  final ShapeType type;
  final Color color;
  final double size;
  final double initialX;
  final double initialY;
  final Duration duration;

  FloatingShape({
    required this.type,
    required this.color,
    required this.size,
    required this.initialX,
    required this.initialY,
    required this.duration,
  });
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    
    path.moveTo(size.width / 2, size.height * 0.85);
    path.cubicTo(
      size.width * 0.1, size.height * 0.5,
      size.width * 0.1, size.height * 0.15,
      size.width / 2, size.height * 0.3,
    );
    path.cubicTo(
      size.width * 0.9, size.height * 0.15,
      size.width * 0.9, size.height * 0.5,
      size.width / 2, size.height * 0.85,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CloudPainter extends CustomPainter {
  final Color color;

  CloudPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    
    canvas.drawCircle(Offset(w * 0.3, h * 0.6), h * 0.35, paint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), h * 0.4, paint);
    canvas.drawCircle(Offset(w * 0.7, h * 0.55), h * 0.35, paint);
    canvas.drawCircle(Offset(w * 0.4, h * 0.65), h * 0.25, paint);
    canvas.drawCircle(Offset(w * 0.6, h * 0.6), h * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
