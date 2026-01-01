import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import 'math_generator.dart';

class MultiplicationTableScreen extends ConsumerStatefulWidget {
  const MultiplicationTableScreen({super.key});

  @override
  ConsumerState<MultiplicationTableScreen> createState() =>
      _MultiplicationTableScreenState();
}

class _MultiplicationTableScreenState
    extends ConsumerState<MultiplicationTableScreen> {
  int _selectedNumber = 1;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final table = MathGenerator.generateTable(_selectedNumber);

    return Scaffold(
      body: ScreenBackground(
        theme: ScreenTheme.math,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Row(
                  children: [
                    // Back Button
                    KidIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                      size: 40,
                      backgroundColor: Colors.white,
                    ),
                    const Spacer(),
                    Text(
                      language == AppLanguage.bangla
                          ? 'গুণন সারণী'
                          : 'Multiplication Table',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Number Selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final number = index + 1;
                      final isSelected = number == _selectedNumber;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedNumber = number;
                            });
                            Haptics.light();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusXl,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.grey.withValues(alpha: 0.2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                          .withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Table Display
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Title
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMd,
                            vertical: AppTheme.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue,
                                AppTheme.primaryBlue.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusXl,
                            ),
                          ),
                          child: Text(
                            language == AppLanguage.bangla
                                ? '$_selectedNumber এর গুণন সারণী'
                                : 'Table of $_selectedNumber',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        // Table Rows - All visible at once
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: table.rows.map((row) {
                              final index = table.rows.indexOf(row);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingMd,
                                  vertical: AppTheme.spacingXs,
                                ),
                                decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? AppTheme.primaryBlue
                                          .withValues(alpha: 0.05)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusLg,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primaryBlue
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${row.multiplier} × ${row.multiplicand}',
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      '=',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacingSm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd,
                                        ),
                                      ),
                                      child: Text(
                                        '${row.product}',
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingSm),
            ],
          ),
        ),
      ),
    );
  }
}

