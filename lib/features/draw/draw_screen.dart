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
import '../alphabet/models/letter_models.dart';

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
  int _selectedGuideCategory = 0; // 0=None, 1=English, 2=Bangla Vowels, 3=Bangla Consonants, 4=Numbers

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

  // Guide data
  static final List<String> _englishLetters =
      EnglishAlphabetData.letters.map((l) => l.letter).toList();

  static final List<String> _banglaVowels =
      BanglaAlphabetData.swarabarna.map((l) => l.letter).toList();

  static final List<String> _banglaConsonants =
      BanglaAlphabetData.byanjanbarna.map((l) => l.letter).toList();

  static const List<String> _numbers = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9'
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

  void _setGuideCategory(int category) {
    setState(() {
      _selectedGuideCategory = category;
      if (category == 0) {
        _guideCharacter = null;
        _showGuide = false;
      }
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

      final rawImage = await boundary.toImage(pixelRatio: 2.0);

      // Composite onto a white background for better AI recognition
      final width = rawImage.width;
      final height = rawImage.height;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = Colors.white,
      );
      canvas.drawImage(rawImage, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);

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
    final hasGuide = _guideCharacter != null;

    // Determine if the answer is correct using the AI's isMatch field AND confidence threshold
    // Require at least 0.5 confidence even if AI says is_match is true
    final isCorrect = hasGuide ? (result.isMatch && result.confidence >= 0.5) : true;
    final resultColor = isCorrect ? AppTheme.primaryGreen : AppTheme.primaryRed;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: resultColor,
                size: 50,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Status text
            Text(
              isCorrect
                  ? (isBangla ? 'সঠিক!' : 'Correct!')
                  : (isBangla ? 'আবার চেষ্টা করো!' : 'Try Again!'),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: resultColor,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Show what was drawn vs expected
            if (hasGuide) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // What was drawn
                  Column(
                    children: [
                      Text(
                        isBangla ? 'তুমি এঁকেছ' : 'You drew',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: (isCorrect
                                  ? AppTheme.primaryGreen
                                  : AppTheme.primaryOrange)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: isCorrect
                                ? AppTheme.primaryGreen
                                : AppTheme.primaryOrange,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            result.character,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: isCorrect
                                  ? AppTheme.primaryGreen
                                  : AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Arrow or comparison
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                    child: Icon(
                      isCorrect ? Icons.check_rounded : Icons.compare_arrows_rounded,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),

                  // Expected character
                  Column(
                    children: [
                      Text(
                        isBangla ? 'গাইড ছিল' : 'Expected',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _guideCharacter!,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ] else ...[
              // No guide - just show recognized character
              Text(
                result.character,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 100,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],

            // Stars for confidence
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
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Feedback text
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                result.feedback,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Action buttons
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
                    backgroundColor:
                        isCorrect ? AppTheme.primaryBlue : AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: KidButton(
                    text: isBangla
                        ? (isCorrect ? 'চালিয়ে যান' : 'ঠিক আছে')
                        : (isCorrect ? 'Continue' : 'OK'),
                    icon:
                        isCorrect ? Icons.arrow_forward_rounded : Icons.check_rounded,
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

  List<String> _getGuideCharactersForCategory(int category) {
    switch (category) {
      case 1:
        return _englishLetters;
      case 2:
        return _banglaVowels;
      case 3:
        return _banglaConsonants;
      case 4:
        return _numbers;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isBangla = language == AppLanguage.bangla;

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
                    isBangla ? 'আঁকার বোর্ড' : 'Drawing Board',
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
                        // 6 second delay so user has time to finish drawing
                        _recognitionTimer?.cancel();
                        _recognitionTimer = Timer(
                          const Duration(seconds: 6),
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
              padding: const EdgeInsets.all(AppTheme.spacingMd),
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

                  const SizedBox(height: AppTheme.spacingMd),

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

                  // Guide Category Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _GuideCategoryTab(
                          label: isBangla ? 'গাইড বন্ধ' : 'No Guide',
                          isSelected: _selectedGuideCategory == 0,
                          color: AppTheme.textSecondary,
                          onTap: () => _setGuideCategory(0),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        _GuideCategoryTab(
                          label: 'A-Z',
                          isSelected: _selectedGuideCategory == 1,
                          color: AppTheme.primaryBlue,
                          onTap: () => _setGuideCategory(1),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        _GuideCategoryTab(
                          label: isBangla ? 'স্বরবর্ণ' : 'Bangla Vowels',
                          isSelected: _selectedGuideCategory == 2,
                          color: AppTheme.primaryGreen,
                          onTap: () => _setGuideCategory(2),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        _GuideCategoryTab(
                          label: isBangla ? 'ব্যঞ্জনবর্ণ' : 'Bangla Consonants',
                          isSelected: _selectedGuideCategory == 3,
                          color: AppTheme.primaryOrange,
                          onTap: () => _setGuideCategory(3),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        _GuideCategoryTab(
                          label: '0-9',
                          isSelected: _selectedGuideCategory == 4,
                          color: AppTheme.primaryPurple,
                          onTap: () => _setGuideCategory(4),
                        ),
                      ],
                    ),
                  ),

                  // Guide Characters Grid (when a category is selected)
                  if (_selectedGuideCategory > 0) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getGuideCharactersForCategory(
                                  _selectedGuideCategory)
                              .map(
                            (char) => Padding(
                              padding: const EdgeInsets.only(
                                  right: AppTheme.spacingXs),
                              child: _GuideButton(
                                label: char,
                                isSelected:
                                    _showGuide && _guideCharacter == char,
                                color: _getCategoryColor(_selectedGuideCategory),
                                onTap: () => _setGuide(char),
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int category) {
    switch (category) {
      case 1:
        return AppTheme.primaryBlue;
      case 2:
        return AppTheme.primaryGreen;
      case 3:
        return AppTheme.primaryOrange;
      case 4:
        return AppTheme.primaryPurple;
      default:
        return AppTheme.primaryGreen;
    }
  }
}

class _GuideCategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GuideCategoryTab({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Haptics.selection();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _GuideButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GuideButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Haptics.selection();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : color,
            ),
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
