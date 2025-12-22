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

class MathScreen extends ConsumerStatefulWidget {
  const MathScreen({super.key});

  @override
  ConsumerState<MathScreen> createState() => _MathScreenState();
}

class _MathScreenState extends ConsumerState<MathScreen>
    with SingleTickerProviderStateMixin {
  MathOperation _currentOperation = MathOperation.addition;
  final MathDifficulty _difficulty = MathDifficulty.easy;
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
        operation: _currentOperation,
        difficulty: _difficulty,
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
                      language == AppLanguage.bangla ? 'গণিত মজা' : 'Math Fun',
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

              // Operation Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: Row(
                  children: [
                    _OperationChip(
                      icon: Icons.add_rounded,
                      label: language == AppLanguage.bangla ? 'যোগ' : 'Add',
                      isSelected: _currentOperation == MathOperation.addition,
                      color: AppTheme.primaryBlue,
                      onTap: () {
                        setState(() => _currentOperation = MathOperation.addition);
                        _generateNewProblem();
                      },
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _OperationChip(
                      icon: Icons.remove_rounded,
                      label: language == AppLanguage.bangla ? 'বিয়োগ' : 'Subtract',
                      isSelected: _currentOperation == MathOperation.subtraction,
                      color: AppTheme.primaryGreen,
                      onTap: () {
                        setState(
                            () => _currentOperation = MathOperation.subtraction);
                        _generateNewProblem();
                      },
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _OperationChip(
                      icon: Icons.close_rounded,
                      label: language == AppLanguage.bangla ? 'গুণ' : 'Multiply',
                      isSelected:
                          _currentOperation == MathOperation.multiplication,
                      color: AppTheme.primaryOrange,
                      onTap: () {
                        setState(() =>
                            _currentOperation = MathOperation.multiplication);
                        _generateNewProblem();
                      },
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _OperationChip(
                      icon: Icons.horizontal_rule_rounded,
                      label: language == AppLanguage.bangla ? 'ভাগ' : 'Divide',
                      isSelected: _currentOperation == MathOperation.division,
                      color: AppTheme.primaryPink,
                      onTap: () {
                        setState(() => _currentOperation = MathOperation.division);
                        _generateNewProblem();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing3Xl),

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

class _OperationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _OperationChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
