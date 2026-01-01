import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/header.dart';
import '../../core/i18n/language_controller.dart';

class ShapeGameScreen extends ConsumerStatefulWidget {
  const ShapeGameScreen({super.key});

  @override
  ConsumerState<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends ConsumerState<ShapeGameScreen> {
  final Random _random = Random();
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  late _ShapeData _targetShape;
  List<_ShapeData> _options = [];
  bool _showResult = false;
  bool _wasCorrect = false;

  final List<_ShapeData> _allShapes = [
    _ShapeData('circle', Icons.circle, 'Circle', 'বৃত্ত', Colors.red),
    _ShapeData('square', Icons.square, 'Square', 'বর্গ', Colors.blue),
    _ShapeData(
        'triangle', Icons.change_history, 'Triangle', 'ত্রিভুজ', Colors.green),
    _ShapeData('star', Icons.star, 'Star', 'তারা', Colors.orange),
    _ShapeData('heart', Icons.favorite, 'Heart', 'হৃদয়', Colors.pink),
    _ShapeData('diamond', Icons.diamond, 'Diamond', 'হীরা', Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    _allShapes.shuffle(_random);
    _targetShape = _allShapes[0];
    _options = _allShapes.take(4).toList();
    _options.shuffle(_random);
    _showResult = false;
    setState(() {});
  }

  void _checkAnswer(_ShapeData selected) {
    if (_showResult) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _showResult = true;
      _wasCorrect = selected.id == _targetShape.id;
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
              _score >= 8 ? '🏆' : _score >= 5 ? '⭐' : '💪',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              _score >= 8
                  ? (language == AppLanguage.bangla ? 'অসাধারণ!' : 'Amazing!')
                  : _score >= 5
                      ? (language == AppLanguage.bangla
                          ? 'ভালো করেছো!'
                          : 'Well Done!')
                      : (language == AppLanguage.bangla
                          ? 'চেষ্টা চালিয়ে যাও!'
                          : 'Keep Practicing!'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
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
        theme: ScreenTheme.games,
        showFloatingShapes: true,
        child: SafeArea(
          child: Column(
            children: [
              Header(
                title: language == AppLanguage.bangla
                    ? 'আকৃতি মেলাও'
                    : 'Shape Match',
                subtitle: language == AppLanguage.bangla
                    ? 'সঠিক আকৃতি খুঁজো!'
                    : 'Find the matching shape!',
                color: const Color(0xFF10B981),
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
                        padding: const EdgeInsets.all(AppTheme.spacing3Xl),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radius2Xl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _targetShape.icon,
                          size: 80,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      Text(
                        language == AppLanguage.bangla
                            ? 'এটা কোন আকৃতি?'
                            : 'What shape is this?',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
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
                        childAspectRatio: 1.3,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _options.map((shape) {
                          final isCorrect = shape.id == _targetShape.id;
                          final showCorrect = _showResult && isCorrect;

                          return _ShapeButton(
                            shape: shape,
                            language: language,
                            onTap: () => _checkAnswer(shape),
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

class _ShapeData {
  final String id;
  final IconData icon;
  final String nameEn;
  final String nameBn;
  final Color color;

  _ShapeData(this.id, this.icon, this.nameEn, this.nameBn, this.color);
}

class _ShapeButton extends StatelessWidget {
  final _ShapeData shape;
  final AppLanguage language;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool showResult;

  const _ShapeButton({
    required this.shape,
    required this.language,
    required this.onTap,
    this.isCorrect = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = shape.color;

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              shape.icon,
              size: 40,
              color: shape.color,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  language == AppLanguage.bangla ? shape.nameBn : shape.nameEn,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: showResult && isCorrect
                        ? AppTheme.primaryGreen
                        : shape.color,
                  ),
                ),
              ],
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
