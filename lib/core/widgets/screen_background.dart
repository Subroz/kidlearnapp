import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScreenBackground extends StatefulWidget {
  final Widget child;
  final bool showFloatingShapes;
  final List<Color>? gradientColors;

  const ScreenBackground({
    super.key,
    required this.child,
    this.showFloatingShapes = true,
    this.gradientColors,
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

  void _initializeShapes() {
    final random = Random();
    _shapes = List.generate(8, (index) {
      return FloatingShape(
        type: ShapeType.values[random.nextInt(ShapeType.values.length)],
        color: _getShapeColor(index),
        size: 20 + random.nextDouble() * 60,
        initialX: random.nextDouble(),
        initialY: random.nextDouble(),
        duration: Duration(seconds: 15 + random.nextInt(15)),
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

  Color _getShapeColor(int index) {
    final colors = [
      AppTheme.primaryPurple.withValues(alpha: 0.15),
      AppTheme.primaryBlue.withValues(alpha: 0.12),
      AppTheme.primaryGreen.withValues(alpha: 0.12),
      AppTheme.primaryOrange.withValues(alpha: 0.15),
      AppTheme.primaryPink.withValues(alpha: 0.12),
      const Color(0xFFE0E7FF).withValues(alpha: 0.5),
      const Color(0xFFFCE7F3).withValues(alpha: 0.5),
      const Color(0xFFD1FAE5).withValues(alpha: 0.4),
    ];
    return colors[index % colors.length];
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
    final colors = widget.gradientColors ??
        [
          const Color(0xFFF0F4FF),
          const Color(0xFFFFF0F5),
          const Color(0xFFF0FFF4),
          const Color(0xFFFFFBEB),
        ];
    
    // Generate stops dynamically based on number of colors
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
          // Floating shapes
          if (widget.showFloatingShapes)
            ...List.generate(_shapes.length, (index) {
              return AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) {
                  final shape = _shapes[index];
                  final progress = _controllers[index].value;
                  
                  return Positioned(
                    left: MediaQuery.of(context).size.width *
                        (shape.initialX + sin(progress * pi * 2) * 0.1),
                    top: MediaQuery.of(context).size.height *
                        (shape.initialY + cos(progress * pi * 2) * 0.08),
                    child: Transform.rotate(
                      angle: progress * pi * 0.5,
                      child: _buildShape(shape),
                    ),
                  );
                },
              );
            }),
          // Main content
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
    }
  }
}

enum ShapeType { circle, star, triangle, square, heart }

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
