import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import '../../services/gemini_handwriting_service.dart';

class DrawScreen extends ConsumerStatefulWidget {
  const DrawScreen({super.key});

  @override
  ConsumerState<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends ConsumerState<DrawScreen> {
  final List<DrawnLine> _lines = [];
  Color _selectedColor = AppTheme.primaryPurple;
  double _strokeWidth = 5.0;
  String? _guideCharacter;
  bool _showGuide = false;

  // Recognition state
  final GlobalKey _canvasKey = GlobalKey();
  Timer? _recognitionTimer;
  bool _isRecognizing = false;

  final List<Color> _colors = [
    AppTheme.primaryPurple,
    AppTheme.primaryBlue,
    AppTheme.primaryGreen,
    AppTheme.primaryOrange,
    AppTheme.primaryPink,
    AppTheme.primaryRed,
    const Color(0xFF000000),
    const Color(0xFF6B7280),
  ];

  void _undo() {
    if (_lines.isNotEmpty) {
      setState(() {
        _lines.removeLast();
      });
      Haptics.light();
    }
  }

  void _clear() {
    setState(() {
      _lines.clear();
    });
    Haptics.medium();
  }

  void _setGuide(String? character) {
    setState(() {
      _guideCharacter = character;
      _showGuide = character != null;
    });
  }

  @override
  void dispose() {
    _recognitionTimer?.cancel();
    super.dispose();
  }

  Future<Uint8List?> _captureDrawing() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing drawing: $e');
      return null;
    }
  }

  bool _shouldUseBangla() {
    // If guide is selected and is Bangla character
    if (_guideCharacter != null) {
      return _isBanglaCharacter(_guideCharacter!);
    }
    // Otherwise use app language
    return ref.read(languageProvider) == AppLanguage.bangla;
  }

  bool _isBanglaCharacter(String char) {
    return char.codeUnitAt(0) >= 0x0980 && char.codeUnitAt(0) <= 0x09FF;
  }

  Future<void> _recognizeDrawing() async {
    if (_lines.isEmpty || _isRecognizing) return;

    setState(() => _isRecognizing = true);

    try {
      final imageBytes = await _captureDrawing();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture drawing')),
          );
        }
        return;
      }

      final service = GeminiHandwritingService();
      final result = await service.recognizeDrawing(
        imageBytes,
        guideCharacter: _guideCharacter,
        isBangla: _shouldUseBangla(),
      );

      if (mounted) {
        _showRecognitionDialog(result);
      }
    } catch (e) {
      debugPrint('Recognition error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recognition failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecognizing = false);
      }
    }
  }

  void _showRecognitionDialog(HandwritingResult result) {
    final language = ref.read(languageProvider);
    final isBangla = language == AppLanguage.bangla;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result.character,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 120,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                result.confidence >= 0.8
                    ? 3
                    : result.confidence >= 0.6
                        ? 2
                        : 1,
                (index) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              result.feedback,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (_guideCharacter != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                result.character.toUpperCase() == _guideCharacter!.toUpperCase()
                    ? (isBangla ? '✓ সঠিক!' : '✓ Correct!')
                    : (isBangla
                        ? '✗ গাইড: $_guideCharacter'
                        : '✗ Guide was: $_guideCharacter'),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: result.character.toUpperCase() ==
                          _guideCharacter!.toUpperCase()
                      ? AppTheme.primaryGreen
                      : AppTheme.primaryOrange,
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacingLg),
            Row(
              children: [
                Expanded(
                  child: KidButton(
                    text: isBangla ? 'আবার চেষ্টা' : 'Try Again',
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _clear();
                    },
                    size: KidButtonSize.small,
                    backgroundColor: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: KidButton(
                    text: isBangla ? 'চালিয়ে যান' : 'Continue',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                    size: KidButtonSize.small,
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  KidIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.go('/'),
                    size: 44,
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    language == AppLanguage.bangla
                        ? 'আঁকার বোর্ড'
                        : 'Drawing Board',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Undo Button
                  KidIconButton(
                    icon: Icons.undo_rounded,
                    onPressed: _lines.isNotEmpty ? _undo : null,
                    size: 40,
                    backgroundColor: _lines.isNotEmpty
                        ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    iconColor:
                        _lines.isNotEmpty ? AppTheme.primaryBlue : Colors.grey,
                    showShadow: false,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  // Check Button (Recognition)
                  KidIconButton(
                    icon: _isRecognizing
                        ? Icons.hourglass_empty_rounded
                        : Icons.check_circle_outline_rounded,
                    onPressed: _lines.isNotEmpty && !_isRecognizing
                        ? () {
                            _recognitionTimer?.cancel();
                            _recognizeDrawing();
                          }
                        : null,
                    size: 40,
                    backgroundColor: _lines.isNotEmpty && !_isRecognizing
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    iconColor: _lines.isNotEmpty && !_isRecognizing
                        ? AppTheme.primaryGreen
                        : Colors.grey,
                    showShadow: false,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  // Clear Button
                  KidIconButton(
                    icon: Icons.delete_outline_rounded,
                    onPressed: _lines.isNotEmpty ? _clear : null,
                    size: 40,
                    backgroundColor: _lines.isNotEmpty
                        ? AppTheme.primaryRed.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    iconColor:
                        _lines.isNotEmpty ? AppTheme.primaryRed : Colors.grey,
                    showShadow: false,
                  ),
                ],
              ),
            ),

            // Canvas
            Expanded(
              child: Stack(
                children: [
                  // Guide Character
                  if (_showGuide && _guideCharacter != null)
                    Center(
                      child: Text(
                        _guideCharacter!,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 300,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                    ),

                  // Drawing Canvas
                  RepaintBoundary(
                    key: _canvasKey,
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          _lines.add(DrawnLine(
                            points: [details.localPosition],
                            color: _selectedColor,
                            strokeWidth: _strokeWidth,
                          ));
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          if (_lines.isNotEmpty) {
                            _lines.last.points.add(details.localPosition);
                          }
                        });
                      },
                      onPanEnd: (details) {
                        // Start auto-recognition timer
                        _recognitionTimer?.cancel();
                        _recognitionTimer = Timer(
                          const Duration(seconds: 2),
                          _recognizeDrawing,
                        );
                      },
                      child: CustomPaint(
                        painter: DrawingPainter(lines: _lines),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Toolbar
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Color Picker
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColor = color);
                            Haptics.selection();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: isSelected ? 44 : 36,
                            height: isSelected ? 44 : 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Brush Size Slider
                  Row(
                    children: [
                      const Icon(
                        Icons.brush_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      Expanded(
                        child: Slider(
                          value: _strokeWidth,
                          min: 2,
                          max: 20,
                          divisions: 9,
                          activeColor: _selectedColor,
                          inactiveColor: _selectedColor.withValues(alpha: 0.2),
                          onChanged: (value) {
                            setState(() => _strokeWidth = value);
                          },
                        ),
                      ),
                      Container(
                        width: _strokeWidth + 10,
                        height: _strokeWidth + 10,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Guide Characters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _GuideButton(
                          label: language == AppLanguage.bangla
                              ? 'গাইড বন্ধ'
                              : 'No Guide',
                          isSelected: !_showGuide,
                          onTap: () => _setGuide(null),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        ...['A', 'B', 'C', '1', '2', '3', 'অ', 'আ', 'ক'].map(
                          (char) => Padding(
                            padding: const EdgeInsets.only(
                                right: AppTheme.spacingSm),
                            child: _GuideButton(
                              label: char,
                              isSelected: _showGuide && _guideCharacter == char,
                              onTap: () => _setGuide(char),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GuideButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen
              : AppTheme.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.primaryGreen,
          ),
        ),
      ),
    );
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawnLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  DrawingPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      if (line.points.isEmpty) continue;

      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (line.points.length == 1) {
        canvas.drawCircle(line.points.first, line.strokeWidth / 2, paint);
      } else {
        final path = Path();
        path.moveTo(line.points.first.dx, line.points.first.dy);

        for (int i = 1; i < line.points.length; i++) {
          path.lineTo(line.points[i].dx, line.points[i].dy);
        }

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
