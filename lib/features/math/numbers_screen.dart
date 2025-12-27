import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import '../../services/speech_service.dart';

class NumbersScreen extends ConsumerStatefulWidget {
  final bool isBangla;

  const NumbersScreen({
    super.key,
    required this.isBangla,
  });

  @override
  ConsumerState<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends ConsumerState<NumbersScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _englishNumbers = [
    {'number': '0', 'word': 'Zero'},
    {'number': '1', 'word': 'One'},
    {'number': '2', 'word': 'Two'},
    {'number': '3', 'word': 'Three'},
    {'number': '4', 'word': 'Four'},
    {'number': '5', 'word': 'Five'},
    {'number': '6', 'word': 'Six'},
    {'number': '7', 'word': 'Seven'},
    {'number': '8', 'word': 'Eight'},
    {'number': '9', 'word': 'Nine'},
    {'number': '10', 'word': 'Ten'},
  ];

  final List<Map<String, String>> _banglaNumbers = [
    {'number': '০', 'word': 'শূন্য'},
    {'number': '১', 'word': 'এক'},
    {'number': '২', 'word': 'দুই'},
    {'number': '৩', 'word': 'তিন'},
    {'number': '৪', 'word': 'চার'},
    {'number': '৫', 'word': 'পাঁচ'},
    {'number': '৬', 'word': 'ছয়'},
    {'number': '৭', 'word': 'সাত'},
    {'number': '৮', 'word': 'আট'},
    {'number': '৯', 'word': 'নয়'},
    {'number': '১০', 'word': 'দশ'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _speakNumber(String word) {
    Haptics.light();
    SpeechService().speakWord(word, isBangla: widget.isBangla);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final numbers = widget.isBangla ? _banglaNumbers : _englishNumbers;

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
              // Header
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
                    const Spacer(),
                    Text(
                      widget.isBangla
                          ? (language == AppLanguage.bangla
                              ? 'সংখ্যা (বাংলা)'
                              : 'Numbers (Bangla)')
                          : (language == AppLanguage.bangla
                              ? 'সংখ্যা (ইংরেজি)'
                              : 'Numbers (English)'),
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
              ),

              // Page Indicator
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    numbers.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primaryBlue
                            : AppTheme.primaryBlue.withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing2Xl),

              // Number Cards
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: numbers.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    Haptics.light();
                  },
                  itemBuilder: (context, index) {
                    final numberData = numbers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing2Xl,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Number Display Card
                          GestureDetector(
                            onTap: () => _speakNumber(numberData['word']!),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(AppTheme.spacingLg),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radius2Xl),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue
                                          .withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Number
                                  Text(
                                    numberData['number']!,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 120,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  // Word
                                  Text(
                                    numberData['word']!,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  // Sound Button
                                  Container(
                                    padding: const EdgeInsets.all(
                                        AppTheme.spacingSm),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.volume_up_rounded,
                                      color: AppTheme.primaryBlue,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  children: [
                    Expanded(
                      child: KidButton(
                        text: language == AppLanguage.bangla
                            ? 'পূর্ববর্তী'
                            : 'Previous',
                        icon: Icons.arrow_back_rounded,
                        onPressed: _currentPage > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        size: KidButtonSize.medium,
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: KidButton(
                        text:
                            language == AppLanguage.bangla ? 'পরবর্তী' : 'Next',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _currentPage < numbers.length - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        size: KidButtonSize.medium,
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                    ),
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
