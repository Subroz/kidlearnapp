import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../services/speech_service.dart';
import 'models/letter_models.dart';

class LetterDetailScreen extends ConsumerWidget {
  final String language;
  final String letterId;

  const LetterDetailScreen({
    super.key,
    required this.language,
    required this.letterId,
  });

  Letter? _findLetter() {
    if (language == 'english') {
      return EnglishAlphabetData.letters.firstWhere(
        (l) => l.id == letterId,
        orElse: () => EnglishAlphabetData.letters.first,
      );
    } else {
      return BanglaAlphabetData.allLetters.firstWhere(
        (l) => l.id == letterId,
        orElse: () => BanglaAlphabetData.allLetters.first,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLanguage = ref.watch(languageProvider);
    final letter = _findLetter();
    final speechService = SpeechService();
    final isBangla = language == 'bangla';
    final isVowel = letter?.type == 'vowel';
    final color = isBangla
        ? (isVowel ? AppTheme.primaryGreen : AppTheme.primaryOrange)
        : (isVowel ? AppTheme.primaryBlue : AppTheme.primaryPurple);

    if (letter == null) {
      return const Scaffold(
        body: Center(child: Text('Letter not found')),
      );
    }

    return Scaffold(
      body: ScreenBackground(
        gradientColors: isBangla
            ? [
                const Color(0xFFD1FAE5),
                const Color(0xFFFEF3C7),
              ]
            : [
                const Color(0xFFDBEAFE),
                const Color(0xFFEDE9FE),
              ],
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Row(
                    children: [
                      KidIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.pop(),
                        size: 44,
                        backgroundColor: Colors.white,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          isVowel
                              ? (appLanguage == AppLanguage.bangla
                                  ? 'স্বরবর্ণ'
                                  : 'Vowel')
                              : (appLanguage == AppLanguage.bangla
                                  ? 'ব্যঞ্জনবর্ণ'
                                  : 'Consonant'),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing3Xl),

                  // Large Letter Display
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        letter.letter,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: isBangla ? 100 : 120,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing2Xl),

                  // Pronunciation
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2Xl,
                      vertical: AppTheme.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '/${letter.pronunciation}/',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Listen Button
                  KidButton(
                    icon: Icons.volume_up_rounded,
                    text: appLanguage == AppLanguage.bangla
                        ? 'উচ্চারণ শুনুন'
                        : 'Listen',
                    onPressed: () {
                      // Use pronunciation string for better clarity
                      if (isBangla) {
                        speechService.speakBangla(letter.pronunciation);
                      } else {
                        speechService.speakEnglish(letter.pronunciation);
                      }
                    },
                    size: KidButtonSize.large,
                    backgroundColor: color,
                  ),

                  const SizedBox(height: AppTheme.spacing3Xl),

                  // Example Words Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      appLanguage == AppLanguage.bangla
                          ? 'উদাহরণ শব্দ'
                          : 'Example Words',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Example Word Cards
                  ...letter.examples.map((example) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        child: _ExampleWordCard(
                          word: example.word,
                          meaning: example.meaning,
                          color: color,
                          onSpeak: () =>
                              speechService.speakWord(example.word, isBangla: isBangla),
                        ),
                      )),

                  const SizedBox(height: AppTheme.spacing2Xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExampleWordCard extends StatelessWidget {
  final String word;
  final String meaning;
  final Color color;
  final VoidCallback onSpeak;

  const _ExampleWordCard({
    required this.word,
    required this.meaning,
    required this.color,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meaning,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          KidIconButton(
            icon: Icons.volume_up_rounded,
            onPressed: onSpeak,
            size: 44,
            backgroundColor: color.withValues(alpha: 0.1),
            iconColor: color,
            showShadow: false,
          ),
        ],
      ),
    );
  }
}
