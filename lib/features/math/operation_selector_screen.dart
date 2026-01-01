import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import 'models/math_models.dart';
import 'math_practice_screen.dart';

class OperationSelectorScreen extends ConsumerStatefulWidget {
  const OperationSelectorScreen({super.key});

  @override
  ConsumerState<OperationSelectorScreen> createState() =>
      _OperationSelectorScreenState();
}

class _OperationSelectorScreenState
    extends ConsumerState<OperationSelectorScreen> {
  MathOperation? _selectedOperation;
  MathDifficulty _selectedDifficulty = MathDifficulty.easy;

  void _startPractice() {
    if (_selectedOperation == null) {
      Haptics.error();
      return;
    }

    Haptics.success();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MathPracticeScreen(
          operation: _selectedOperation!,
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: ScreenBackground(
        theme: ScreenTheme.math,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    KidIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                      size: 44,
                      backgroundColor: Colors.white,
                    ),
                    const Spacer(),
                    Text(
                      language == AppLanguage.bangla
                          ? 'গণিত অনুশীলন'
                          : 'Math Practice',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Subtitle
                Text(
                  language == AppLanguage.bangla
                      ? 'একটি অপারেশন নির্বাচন করুন'
                      : 'Select an Operation',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacing3Xl),

                // Operation Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppTheme.spacingMd,
                    mainAxisSpacing: AppTheme.spacingMd,
                    children: [
                      _OperationCard(
                        icon: Icons.add_rounded,
                        label: language == AppLanguage.bangla ? 'যোগ' : 'Addition',
                        isSelected: _selectedOperation == MathOperation.addition,
                        onTap: () {
                          setState(() {
                            _selectedOperation = MathOperation.addition;
                          });
                          Haptics.light();
                        },
                      ),
                      _OperationCard(
                        icon: Icons.remove_rounded,
                        label: language == AppLanguage.bangla ? 'বিয়োগ' : 'Subtraction',
                        isSelected: _selectedOperation == MathOperation.subtraction,
                        onTap: () {
                          setState(() {
                            _selectedOperation = MathOperation.subtraction;
                          });
                          Haptics.light();
                        },
                      ),
                      _OperationCard(
                        icon: Icons.close_rounded,
                        label: language == AppLanguage.bangla ? 'গুণ' : 'Multiplication',
                        isSelected: _selectedOperation == MathOperation.multiplication,
                        onTap: () {
                          setState(() {
                            _selectedOperation = MathOperation.multiplication;
                          });
                          Haptics.light();
                        },
                      ),
                      _OperationCard(
                        icon: Icons.remove_rounded,
                        label: language == AppLanguage.bangla ? 'ভাগ' : 'Division',
                        customSymbol: '÷',
                        isSelected: _selectedOperation == MathOperation.division,
                        onTap: () {
                          setState(() {
                            _selectedOperation = MathOperation.division;
                          });
                          Haptics.light();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacing2Xl),

                // Difficulty Section
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                  child: Column(
                    children: [
                      Text(
                        language == AppLanguage.bangla
                            ? 'কঠিনতার স্তর'
                            : 'Difficulty Level',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _DifficultyChip(
                            label: language == AppLanguage.bangla ? 'সহজ' : 'Easy',
                            stars: 1,
                            isSelected: _selectedDifficulty == MathDifficulty.easy,
                            onTap: () {
                              setState(() {
                                _selectedDifficulty = MathDifficulty.easy;
                              });
                              Haptics.light();
                            },
                          ),
                          _DifficultyChip(
                            label: language == AppLanguage.bangla
                                ? 'মাঝারি'
                                : 'Medium',
                            stars: 2,
                            isSelected:
                                _selectedDifficulty == MathDifficulty.medium,
                            onTap: () {
                              setState(() {
                                _selectedDifficulty = MathDifficulty.medium;
                              });
                              Haptics.light();
                            },
                          ),
                          _DifficultyChip(
                            label: language == AppLanguage.bangla ? 'কঠিন' : 'Hard',
                            stars: 3,
                            isSelected: _selectedDifficulty == MathDifficulty.hard,
                            onTap: () {
                              setState(() {
                                _selectedDifficulty = MathDifficulty.hard;
                              });
                              Haptics.light();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacing2Xl),

                // Start Button
                KidButton(
                  text: language == AppLanguage.bangla
                      ? 'অনুশীলন শুরু করুন'
                      : 'Start Practice',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _startPractice,
                  size: KidButtonSize.large,
                  fullWidth: true,
                  backgroundColor: AppTheme.primaryBlue,
                ),

                const SizedBox(height: AppTheme.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? customSymbol;
  final bool isSelected;
  final VoidCallback onTap;

  const _OperationCard({
    required this.icon,
    required this.label,
    this.customSymbol,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? AppTheme.primaryBlue : Colors.white;
    final contentColor = isSelected ? Colors.white : AppTheme.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customSymbol != null)
              Text(
                customSymbol!,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  color: contentColor,
                ),
              )
            else
              Icon(
                icon,
                size: 60,
                color: contentColor,
              ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: contentColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final int stars;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.stars,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.shadowSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                stars,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


