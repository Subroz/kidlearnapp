import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import 'models/math_models.dart';
import 'numbers_screen.dart';
import 'multiplication_table_screen.dart';
import 'operation_selector_screen.dart';

class MathSetupScreen extends ConsumerStatefulWidget {
  const MathSetupScreen({super.key});

  @override
  ConsumerState<MathSetupScreen> createState() => _MathSetupScreenState();
}

class _MathSetupScreenState extends ConsumerState<MathSetupScreen> {
  void _navigateToScreen(MathOperation operation) {
    Haptics.success();

    // Navigate to different screens based on operation type
    switch (operation) {
      case MathOperation.numbersBangla:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NumbersScreen(isBangla: true),
          ),
        );
        break;
      case MathOperation.numbersEnglish:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NumbersScreen(isBangla: false),
          ),
        );
        break;
      case MathOperation.multiplicationTable:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MultiplicationTableScreen(),
          ),
        );
        break;
      case MathOperation.mathPractice:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OperationSelectorScreen(),
          ),
        );
        break;
      default:
        break;
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
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: KidIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.go('/'),
                    size: 44,
                    backgroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Title
                Text(
                  language == AppLanguage.bangla ? 'গণিত অনুশীলন' : 'Math Practice',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacingSm),
                
                // Subtitle
                Text(
                  language == AppLanguage.bangla
                      ? 'অনুশীলনের জন্য একটি অপারেশন সেট দিন'
                      : 'Select an operation to practice',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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
                        icon: Icons.numbers_rounded,
                        label: language == AppLanguage.bangla ? 'সংখ্যা (বাংলা)' : 'Numbers (Bangla)',
                        customSymbol: '১২৩',
                        onTap: () => _navigateToScreen(MathOperation.numbersBangla),
                      ),
                      _OperationCard(
                        icon: Icons.numbers_rounded,
                        label: language == AppLanguage.bangla ? 'সংখ্যা (ইংরেজি)' : 'Numbers (English)',
                        customSymbol: '123',
                        onTap: () => _navigateToScreen(MathOperation.numbersEnglish),
                      ),
                      _OperationCard(
                        icon: Icons.table_chart_rounded,
                        label: language == AppLanguage.bangla ? 'গুণন সারণী' : 'Multiplication Table',
                        onTap: () => _navigateToScreen(MathOperation.multiplicationTable),
                      ),
                      _OperationCard(
                        icon: Icons.calculate_rounded,
                        label: language == AppLanguage.bangla ? 'গণিত অনুশীলন' : 'Math Practice',
                        onTap: () => _navigateToScreen(MathOperation.mathPractice),
                      ),
                    ],
                  ),
                ),
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
  final VoidCallback onTap;

  const _OperationCard({
    required this.icon,
    required this.label,
    this.customSymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
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
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 24, 124, 238),
                ),
              )
            else
              Icon(
                icon,
                size: 60,
                color: const Color.fromARGB(255, 6, 168, 47),
              ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

