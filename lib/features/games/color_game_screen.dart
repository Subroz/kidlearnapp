import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/header.dart';
import '../../core/i18n/language_controller.dart';

class ColorGameScreen extends ConsumerStatefulWidget {
  const ColorGameScreen({super.key});

  @override
  ConsumerState<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends ConsumerState<ColorGameScreen> {
  final Random _random = Random();
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  late _ColorData _targetColor;
  List<_ColorData> _options = [];
  bool _showResult = false;
  bool _wasCorrect = false;

  final List<_ColorData> _allColors = [
    _ColorData('red', Colors.red, 'Red', 'লাল'),
    _ColorData('blue', Colors.blue, 'Blue', 'নীল'),
    _ColorData('green', Colors.green, 'Green', 'সবুজ'),
    _ColorData('yellow', Colors.yellow.shade700, 'Yellow', 'হলুদ'),
    _ColorData('orange', Colors.orange, 'Orange', 'কমলা'),
    _ColorData('purple', Colors.purple, 'Purple', 'বেগুনি'),
    _ColorData('pink', Colors.pink, 'Pink', 'গোলাপি'),
    _ColorData('brown', Colors.brown, 'Brown', 'বাদামি'),
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    _allColors.shuffle(_random);
    _targetColor = _allColors[0];
    _options = _allColors.take(4).toList();
    _options.shuffle(_random);
    _showResult = false;
    setState(() {});
  }

  void _checkAnswer(_ColorData selected) {
    if (_showResult) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _showResult = true;
      _wasCorrect = selected.id == _targetColor.id;
      if (_wasCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_round < _totalRounds - 1) {
        setState(() {
          _round++;
        });
        _generateQuestion();
      } else {
        _showFinalScore();
      }
    });
  }

  void _showFinalScore() {
    final language = ref.read(languageProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _score >= 8 ? '🌈' : _score >= 5 ? '🎨' : '💪',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              _score >= 8
                  ? (language == AppLanguage.bangla
                      ? 'রং মাস্টার!'
                      : 'Color Master!')
                  : _score >= 5
                      ? (language == AppLanguage.bangla
                          ? 'দারুণ হয়েছে!'
                          : 'Great Job!')
                      : (language == AppLanguage.bangla
                          ? 'আবার চেষ্টা করো!'
                          : 'Try Again!'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              language == AppLanguage.bangla
                  ? 'তোমার স্কোর: $_score/$_totalRounds'
                  : 'Your Score: $_score/$_totalRounds',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _round = 0;
              });
              _generateQuestion();
            },
            child: Text(
              language == AppLanguage.bangla ? 'আবার খেলো' : 'Play Again',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: ScreenBackground(
        showFloatingShapes: true,
        child: SafeArea(
          child: Column(
            children: [
              Header(
                title: language == AppLanguage.bangla ? 'রং চেনা' : 'Color Quiz',
                subtitle: language == AppLanguage.bangla
                    ? 'রং চিনতে শেখো!'
                    : 'Learn to identify colors!',
                color: const Color(0xFFF59E0B),
                showBackButton: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(
                      label: language == AppLanguage.bangla ? 'স্কোর' : 'Score',
                      value: '$_score',
                      color: AppTheme.primaryGreen,
                    ),
                    _StatChip(
                      label: language == AppLanguage.bangla ? 'রাউন্ড' : 'Round',
                      value: '${_round + 1}/$_totalRounds',
                      color: AppTheme.primaryOrange,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _targetColor.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _targetColor.color.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing2Xl),
                      Text(
                        language == AppLanguage.bangla
                            ? 'এটা কোন রং?'
                            : 'What color is this?',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing2Xl),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingLg,
                        mainAxisSpacing: AppTheme.spacingLg,
                        childAspectRatio: 2.2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _options.map((colorData) {
                          final isCorrect = colorData.id == _targetColor.id;
                          final showCorrect = _showResult && isCorrect;

                          return _ColorButton(
                            colorData: colorData,
                            language: language,
                            onTap: () => _checkAnswer(colorData),
                            isCorrect: showCorrect,
                            showResult: _showResult,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorData {
  final String id;
  final Color color;
  final String nameEn;
  final String nameBn;

  _ColorData(this.id, this.color, this.nameEn, this.nameBn);
}

class _ColorButton extends StatelessWidget {
  final _ColorData colorData;
  final AppLanguage language;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool showResult;

  const _ColorButton({
    required this.colorData,
    required this.language,
    required this.onTap,
    this.isCorrect = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = colorData.color;

    if (showResult && isCorrect) {
      bgColor = AppTheme.primaryGreen.withValues(alpha: 0.15);
      borderColor = AppTheme.primaryGreen;
    }

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colorData.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorData.color.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (showResult && isCorrect)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
            Text(
              language == AppLanguage.bangla
                  ? colorData.nameBn
                  : colorData.nameEn,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color:
                    showResult && isCorrect ? AppTheme.primaryGreen : colorData.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
