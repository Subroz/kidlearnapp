import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/header.dart';
import '../../core/i18n/language_controller.dart';

class PuzzleGameScreen extends ConsumerStatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  ConsumerState<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends ConsumerState<PuzzleGameScreen> {
  final Random _random = Random();
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  List<String> _sequence = [];
  List<String> _options = [];
  String _correctAnswer = '';
  bool _showResult = false;
  bool _wasCorrect = false;

  final List<_PatternSet> _patternSets = [
    _PatternSet(['🔴', '🔵', '🔴', '🔵'], '🔴', ['🔴', '🟢', '🟡', '🔵']),
    _PatternSet(['🌟', '🌟', '🌙', '🌟', '🌟'], '🌙', ['🌟', '🌙', '☀️', '⭐']),
    _PatternSet(['🍎', '🍊', '🍎', '🍊'], '🍎', ['🍎', '🍇', '🍊', '🍋']),
    _PatternSet(['⬆️', '➡️', '⬇️', '⬅️'], '⬆️', ['⬆️', '⬇️', '↗️', '↘️']),
    _PatternSet(['1️⃣', '2️⃣', '3️⃣', '4️⃣'], '5️⃣', ['5️⃣', '6️⃣', '3️⃣', '1️⃣']),
    _PatternSet(['🐱', '🐶', '🐱', '🐶'], '🐱', ['🐱', '🐰', '🐶', '🐸']),
    _PatternSet(['❤️', '💛', '💚', '💙'], '💜', ['💜', '❤️', '🖤', '💛']),
    _PatternSet(['🔺', '🔻', '🔺', '🔻'], '🔺', ['🔺', '⬛', '🔻', '⬜']),
    _PatternSet(['🌸', '🌸', '🌺', '🌸', '🌸'], '🌺', ['🌸', '🌺', '🌻', '🌷']),
    _PatternSet(['A', 'B', 'C', 'D'], 'E', ['E', 'F', 'A', 'Z']),
    _PatternSet(['2', '4', '6', '8'], '10', ['10', '9', '12', '7']),
    _PatternSet(['🚗', '🚕', '🚗', '🚕'], '🚗', ['🚗', '🚌', '🚕', '🏎️']),
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final pattern = _patternSets[_random.nextInt(_patternSets.length)];
    _sequence = List.from(pattern.sequence);
    _correctAnswer = pattern.answer;
    _options = List.from(pattern.options);
    _options.shuffle(_random);
    _showResult = false;
    setState(() {});
  }

  void _checkAnswer(String selected) {
    if (_showResult) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _showResult = true;
      _wasCorrect = selected == _correctAnswer;
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
              _score >= 8 ? '🧩' : _score >= 5 ? '⭐' : '💪',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              _score >= 8
                  ? (language == AppLanguage.bangla
                      ? 'ধাঁধা মাস্টার!'
                      : 'Puzzle Master!')
                  : _score >= 5
                      ? (language == AppLanguage.bangla
                          ? 'বাহ্ দারুণ!'
                          : 'Well Done!')
                      : (language == AppLanguage.bangla
                          ? 'আবার চেষ্টা করো!'
                          : 'Keep Trying!'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFFEC4899),
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
                title: language == AppLanguage.bangla
                    ? 'ধাঁধা সমাধান'
                    : 'Pattern Puzzle',
                subtitle: language == AppLanguage.bangla
                    ? 'পরবর্তীটি কী হবে?'
                    : 'What comes next?',
                color: const Color(0xFFEC4899),
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
                        padding: const EdgeInsets.all(AppTheme.spacing2Xl),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radius2Xl),
                          boxShadow: AppTheme.shadowLg,
                        ),
                        child: Column(
                          children: [
                            Text(
                              language == AppLanguage.bangla
                                  ? 'প্যাটার্নটি দেখো:'
                                  : 'Look at the pattern:',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingLg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ..._sequence.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3E8FF),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusMd),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item,
                                            style: const TextStyle(fontSize: 28),
                                          ),
                                        ),
                                      ),
                                    )),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _showResult
                                          ? (_wasCorrect
                                              ? AppTheme.primaryGreen
                                                  .withValues(alpha: 0.2)
                                              : AppTheme.primaryRed
                                                  .withValues(alpha: 0.2))
                                          : const Color(0xFFEC4899)
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd),
                                      border: Border.all(
                                        color: _showResult
                                            ? (_wasCorrect
                                                ? AppTheme.primaryGreen
                                                : AppTheme.primaryRed)
                                            : const Color(0xFFEC4899),
                                        width: 2,
                                        style: _showResult
                                            ? BorderStyle.solid
                                            : BorderStyle.none,
                                      ),
                                    ),
                                    child: Center(
                                      child: _showResult
                                          ? Text(
                                              _correctAnswer,
                                              style:
                                                  const TextStyle(fontSize: 28),
                                            )
                                          : const Text(
                                              '?',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFFEC4899),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing2Xl),
                      Text(
                        language == AppLanguage.bangla
                            ? 'পরবর্তীটি কী হবে?'
                            : 'What comes next?',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingLg,
                        mainAxisSpacing: AppTheme.spacingLg,
                        childAspectRatio: 1.5,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _options.map((option) {
                          final isCorrect = option == _correctAnswer;
                          final showCorrect = _showResult && isCorrect;

                          return _OptionButton(
                            value: option,
                            onTap: () => _checkAnswer(option),
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

class _PatternSet {
  final List<String> sequence;
  final String answer;
  final List<String> options;

  _PatternSet(this.sequence, this.answer, this.options);
}

class _OptionButton extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool showResult;

  const _OptionButton({
    required this.value,
    required this.onTap,
    this.isCorrect = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFEC4899);

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
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showResult && isCorrect)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
              Text(
                value,
                style: const TextStyle(fontSize: 40),
              ),
            ],
          ),
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
