import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      icon: Icons.school_rounded,
      titleEn: 'Welcome to KidLearn!',
      titleBn: 'কিডলার্নে স্বাগতম!',
      descriptionEn: 'A fun and interactive way to learn alphabets, math, drawing, and more!',
      descriptionBn: 'বর্ণমালা, গণিত, আঁকা এবং আরও অনেক কিছু শেখার একটি মজার উপায়!',
      color: AppTheme.primaryPurple,
    ),
    const OnboardingPage(
      icon: Icons.translate_rounded,
      titleEn: 'Learn Two Languages',
      titleBn: 'দুটি ভাষা শিখুন',
      descriptionEn: 'Master both English and Bangla alphabets with fun exercises!',
      descriptionBn: 'মজার অনুশীলনের মাধ্যমে ইংরেজি এবং বাংলা বর্ণমালা শিখুন!',
      color: AppTheme.primaryBlue,
    ),
    const OnboardingPage(
      icon: Icons.auto_stories_rounded,
      titleEn: 'AI-Powered Stories',
      titleBn: 'AI দিয়ে গল্প তৈরি',
      descriptionEn: 'Create magical stories using AI and your favorite words!',
      descriptionBn: 'AI এবং তোমার পছন্দের শব্দ দিয়ে জাদুকরী গল্প তৈরি করো!',
      color: AppTheme.primaryOrange,
    ),
    const OnboardingPage(
      icon: Icons.emoji_events_rounded,
      titleEn: 'Learn & Earn',
      titleBn: 'শিখো ও জিতো',
      descriptionEn: 'Complete lessons, earn points, and track your progress!',
      descriptionBn: 'পাঠ শেষ করো, পয়েন্ট অর্জন করো এবং তোমার অগ্রগতি দেখো!',
      color: AppTheme.primaryGreen,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pages[_currentPage].color.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        language == AppLanguage.bangla ? 'এড়িয়ে যাও' : 'Skip',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing3Xl,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon container
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: page.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              page.icon,
                              size: 80,
                              color: page.color,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing4Xl),

                          // Title
                          Text(
                            language == AppLanguage.bangla
                                ? page.titleBn
                                : page.titleEn,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: page.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingLg),

                          // Description
                          Text(
                            language == AppLanguage.bangla
                                ? page.descriptionBn
                                : page.descriptionEn,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _pages[_currentPage].color
                          : AppTheme.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppTheme.spacing3Xl),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing2Xl),
                child: _currentPage == _pages.length - 1
                    ? KidButton(
                        text: language == AppLanguage.bangla
                            ? 'শুরু করো'
                            : 'Get Started',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _completeOnboarding,
                        size: KidButtonSize.large,
                        fullWidth: true,
                        backgroundColor: _pages[_currentPage].color,
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: KidButton(
                              text: language == AppLanguage.bangla
                                  ? 'পরবর্তী'
                                  : 'Next',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              size: KidButtonSize.large,
                              fullWidth: true,
                              backgroundColor: _pages[_currentPage].color,
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

class OnboardingPage {
  final IconData icon;
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.color,
  });
}
