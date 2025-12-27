import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/kid_card.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import 'models/math_models.dart';
import 'math_generator.dart';

class MathPracticeScreen extends ConsumerStatefulWidget {
  final MathOperation operation;
  final MathDifficulty difficulty;

  const MathPracticeScreen({
    super.key,
    required this.operation,
    required this.difficulty,
  });

  @override
  ConsumerState<MathPracticeScreen> createState() => _MathPracticeScreenState();
}

class _MathPracticeScreenState extends ConsumerState<MathPracticeScreen>
    with SingleTickerProviderStateMixin {
  late MathProblem _currentProblem;
  int? _selectedAnswer;
  bool _showResult = false;
  int _score = 0;
  int _totalQuestions = 0;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _generateNewProblem() {
    setState(() {
      _currentProblem = MathGenerator.generateProblem(
        operation: widget.operation,
        difficulty: widget.difficulty,
      );
      _selectedAnswer = null;
      _showResult = false;
    });
  }

  void _checkAnswer(int answer) {
    if (_showResult) return;

    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _totalQuestions++;

      if (answer == _currentProblem.correctAnswer) {
        _score++;
        Haptics.celebrate();
        _celebrationController.forward().then((_) {
          _celebrationController.reverse();
        });
      } else {
        Haptics.error();
      }
    });
  }

  void _nextProblem() {
    _generateNewProblem();
  }

  String _getOperationName(AppLanguage language) {
    switch (widget.operation) {
      case MathOperation.addition:
        return language == AppLanguage.bangla ? 'যোগ' : 'Addition';
      case MathOperation.subtraction:
        return language == AppLanguage.bangla ? 'বিয়োগ' : 'Subtraction';
      case MathOperation.multiplication:
        return language == AppLanguage.bangla ? 'গুণ' : 'Multiplication';
      case MathOperation.division:
        return language == AppLanguage.bangla ? 'ভাগ' : 'Division';
      case MathOperation.numbersBangla:
        return language == AppLanguage.bangla ? 'সংখ্যা (বাংলা)' : 'Numbers (Bangla)';
      case MathOperation.numbersEnglish:
        return language == AppLanguage.bangla ? 'সংখ্যা (ইংরেজি)' : 'Numbers (English)';
      case MathOperation.multiplicationTable:
        return language == AppLanguage.bangla ? 'গুণন সারণী' : 'Multiplication Table';
      case MathOperation.mathPractice:
        return language == AppLanguage.bangla ? 'গণিত অনুশীলন' : 'Math Practice';
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: ScreenBackground(
        gradientColors: const [
          Color(0xFFDBEAFE),
          Color(0xFFC7D2FE),
          Color(0xFFE0E7FF),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header with Score
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  children: [
                    // Back Button
                    KidIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                      size: 44,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    // Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_score / $_totalQuestions',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getOperationName(language),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Reset Button
                    KidIconButton(
                      icon: Icons.refresh_rounded,
                      onPressed: () {
                        setState(() {
                          _score = 0;
                          _totalQuestions = 0;
                        });
                        _generateNewProblem();
                      },
                      size: 44,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing2Xl),

              // Problem Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                  ),
                  child: Column(
                    children: [
                      // Question
                      AnimatedBuilder(
                        animation: _celebrationAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _showResult &&
                                    _selectedAnswer ==
                                        _currentProblem.correctAnswer
                                ? _celebrationAnimation.value
                                : 1.0,
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacing2Xl),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radius2Xl),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _currentProblem.questionText,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (_showResult) ...[
                                    const SizedBox(height: AppTheme.spacingMd),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacingLg,
                                        vertical: AppTheme.spacingSm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedAnswer ==
                                                _currentProblem.correctAnswer
                                            ? AppTheme.primaryGreen
                                                .withValues(alpha: 0.15)
                                            : AppTheme.primaryRed
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusFull),
                                      ),
                                      child: Text(
                                        _selectedAnswer ==
                                                _currentProblem.correctAnswer
                                            ? (language == AppLanguage.bangla
                                                ? 'সঠিক!'
                                                : 'Correct!')
                                            : (language == AppLanguage.bangla
                                                ? 'আবার চেষ্টা করো!'
                                                : 'Try Again!'),
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: _selectedAnswer ==
                                                  _currentProblem.correctAnswer
                                              ? AppTheme.primaryGreen
                                              : AppTheme.primaryRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppTheme.spacing3Xl),

                      // Answer Options
                      Wrap(
                        spacing: AppTheme.spacingMd,
                        runSpacing: AppTheme.spacingMd,
                        children: _currentProblem.options.map((option) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width -
                                    AppTheme.spacingLg * 2 -
                                    AppTheme.spacingMd) /
                                2,
                            child: AnswerCard(
                              text: option.toString(),
                              isSelected: _selectedAnswer == option,
                              isCorrect: option == _currentProblem.correctAnswer,
                              showResult: _showResult,
                              onTap: () => _checkAnswer(option),
                            ),
                          );
                        }).toList(),
                      ),

                      const Spacer(),

                      // Next Button
                      if (_showResult)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppTheme.spacing2Xl),
                          child: KidButton(
                            text: language == AppLanguage.bangla
                                ? 'পরবর্তী'
                                : 'Next',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _nextProblem,
                            size: KidButtonSize.large,
                            fullWidth: true,
                            backgroundColor: AppTheme.primaryBlue,
                          ),
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

