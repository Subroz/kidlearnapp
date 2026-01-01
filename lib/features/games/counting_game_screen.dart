import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/header.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/bangla_digits.dart';

class CountingGameScreen extends ConsumerStatefulWidget {
  const CountingGameScreen({super.key});

  @override
  ConsumerState<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingGameScreenState extends ConsumerState<CountingGameScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  int _correctAnswer = 0;
  List<int> _options = [];
  String _currentEmoji = '';
  int _score = 0;
  int _round = 0;
  final int _totalRounds = 10;
  bool _showResult = false;
  bool _wasCorrect = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<String> _emojis = [
    '🍎', '🍌', '🍊', '🌟', '🎈', '🦋', '🐶', '🐱', '🌺', '🍀',
    '🚗', '⚽', '🎁', '🍕', '🍦', '🐻', '🦁', '🐸', '🌈', '🎂',
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    _correctAnswer = _random.nextInt(8) + 2;
    _currentEmoji = _emojis[_random.nextInt(_emojis.length)];

    final wrongAnswers = <int>{};
    while (wrongAnswers.length < 3) {
      int wrong = _random.nextInt(10) + 1;
      if (wrong != _correctAnswer) {
        wrongAnswers.add(wrong);
      }
    }

    _options = [_correctAnswer, ...wrongAnswers];
    _options.shuffle(_random);

    _showResult = false;
    setState(() {});
  }

  void _checkAnswer(int selected) {
    if (_showResult) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _showResult = true;
      _wasCorrect = selected == _correctAnswer;
      if (_wasCorrect) {
        _score++;
      } else {
        _shakeController.forward().then((_) => _shakeController.reset());
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
              _score >= 7 ? '🏆' : _score >= 5 ? '⭐' : '💪',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              _score >= 7
                  ? (language == AppLanguage.bangla ? 'চমৎকার!' : 'Excellent!')
                  : _score >= 5
                      ? (language == AppLanguage.bangla
                          ? 'ভালো হয়েছে!'
                          : 'Good Job!')
                      : (language == AppLanguage.bangla
                          ? 'আবার চেষ্টা করো!'
                          : 'Keep Trying!'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue,
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
                    ? 'গণনা খেলা'
                    : 'Counting Game',
                subtitle: language == AppLanguage.bangla
                    ? 'কতগুলো আছে গুনো!'
                    : 'Count the objects!',
                color: const Color(0xFF3B82F6),
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
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _shakeAnimation.value *
                                  sin(_shakeController.value * pi * 4),
                              0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacing2Xl),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radius2Xl),
                                boxShadow: AppTheme.shadowLg,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  _correctAnswer,
                                  (index) => Text(
                                    _currentEmoji,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing3Xl),
                      Text(
                        language == AppLanguage.bangla
                            ? 'কতগুলো $_currentEmoji আছে?'
                            : 'How many $_currentEmoji are there?',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing2Xl),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingLg,
                        mainAxisSpacing: AppTheme.spacingLg,
                        childAspectRatio: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _options.map((option) {
                          final isCorrect = option == _correctAnswer;
                          final showCorrect = _showResult && isCorrect;
                          final showWrong =
                              _showResult && !isCorrect && !_wasCorrect;

                          return _AnswerButton(
                            value: language == AppLanguage.bangla
                                ? BanglaDigits.toBangla(option)
                                : option.toString(),
                            onTap: () => _checkAnswer(option),
                            isCorrect: showCorrect,
                            isWrong: showWrong && option == _options.first,
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

class _AnswerButton extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;

  const _AnswerButton({
    required this.value,
    required this.onTap,
    this.isCorrect = false,
    this.isWrong = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = AppTheme.primaryBlue;
    Color textColor = AppTheme.primaryBlue;

    if (showResult && isCorrect) {
      bgColor = AppTheme.primaryGreen.withValues(alpha: 0.15);
      borderColor = AppTheme.primaryGreen;
      textColor = AppTheme.primaryGreen;
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
                    size: 28,
                  ),
                ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
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
