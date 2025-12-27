import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../services/speech_service.dart';
import 'models/letter_models.dart';

class BanglaAlphabetScreen extends ConsumerStatefulWidget {
  const BanglaAlphabetScreen({super.key});

  @override
  ConsumerState<BanglaAlphabetScreen> createState() =>
      _BanglaAlphabetScreenState();
}

class _BanglaAlphabetScreenState extends ConsumerState<BanglaAlphabetScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;
  String _filter = 'all';
  final SpeechService _speechService = SpeechService();

  List<Letter> get filteredLetters {
    if (_filter == 'vowels') {
      return BanglaAlphabetData.swarabarna;
    } else if (_filter == 'consonants') {
      return BanglaAlphabetData.byanjanbarna;
    }
    return BanglaAlphabetData.allLetters;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final letters = filteredLetters;

    return Scaffold(
      body: ScreenBackground(
        gradientColors: const [
          Color(0xFFD1FAE5),
          Color(0xFFDBEAFE),
          Color(0xFFFEF3C7),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  children: [
                    KidIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => context.pop(),
                      size: 44,
                      backgroundColor: Colors.white,
                    ),
                    const Spacer(),
                    Text(
                      language == AppLanguage.bangla
                          ? 'বাংলা বর্ণমালা'
                          : 'Bangla Alphabet',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FilterChip(
                      label: language == AppLanguage.bangla ? 'সব' : 'All',
                      isSelected: _filter == 'all',
                      onTap: () {
                        setState(() {
                          _filter = 'all';
                          _currentIndex = 0;
                        });
                        _pageController.jumpToPage(0);
                      },
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _FilterChip(
                      label: language == AppLanguage.bangla
                          ? 'স্বরবর্ণ'
                          : 'Vowels',
                      isSelected: _filter == 'vowels',
                      onTap: () {
                        setState(() {
                          _filter = 'vowels';
                          _currentIndex = 0;
                        });
                        _pageController.jumpToPage(0);
                      },
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _FilterChip(
                      label: language == AppLanguage.bangla
                          ? 'ব্যঞ্জনবর্ণ'
                          : 'Consonants',
                      isSelected: _filter == 'consonants',
                      onTap: () {
                        setState(() {
                          _filter = 'consonants';
                          _currentIndex = 0;
                        });
                        _pageController.jumpToPage(0);
                      },
                      color: AppTheme.primaryOrange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing2Xl),

              // Letter Cards
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: letters.length,
                  itemBuilder: (context, index) {
                    final letter = letters[index];
                    return _LetterCard(
                      letter: letter,
                      onSpeak: () =>
                          _speechService.speakBangla(letter.pronunciation),
                      onTap: () => context.push(
                        '/alphabet/letter/bangla/${letter.id}',
                      ),
                    );
                  },
                ),
              ),

              // Page Indicators
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_currentIndex + 1}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      ' / ${letters.length}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.only(
                  left: AppTheme.spacingXl,
                  right: AppTheme.spacingXl,
                  bottom: AppTheme.spacingXl,
                ),
                child: Row(
                  children: [
                    if (_currentIndex > 0)
                      KidIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        backgroundColor: Colors.white,
                      )
                    else
                      const SizedBox(width: 56),
                    const Spacer(),
                    KidButton(
                      icon: Icons.volume_up_rounded,
                      text: language == AppLanguage.bangla ? 'শুনুন' : 'Listen',
                      onPressed: () => _speechService.speakBangla(
                        letters[_currentIndex].pronunciation,
                      ),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    const Spacer(),
                    if (_currentIndex < letters.length - 1)
                      KidIconButton(
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        backgroundColor: Colors.white,
                      )
                    else
                      const SizedBox(width: 56),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingSm,
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
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final Letter letter;
  final VoidCallback onSpeak;
  final VoidCallback onTap;

  const _LetterCard({
    required this.letter,
    required this.onSpeak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVowel = letter.type == 'vowel';
    final color = isVowel ? AppTheme.primaryGreen : AppTheme.primaryOrange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingLg,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Letter
            Text(
              letter.letter,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 100,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Pronunciation
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '/${letter.pronunciation}/',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            // Example word
            if (letter.examples.isNotEmpty) ...[
              Text(
                letter.examples.first.word,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                letter.examples.first.meaning,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
