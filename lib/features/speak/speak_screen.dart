import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import '../../services/speech_service.dart';

class SpeakScreen extends ConsumerStatefulWidget {
  const SpeakScreen({super.key});

  @override
  ConsumerState<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends ConsumerState<SpeakScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'animals';
  String? _selectedWord;
  bool _isRecording = false;
  bool _speechInitialized = false;
  String _recognizedText = '';
  String? _feedbackMessage;
  bool? _lastMatchResult;
  final SpeechService _speechService = SpeechService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, List<SpeakWord>> _categories = {
    'animals': [
      SpeakWord(en: 'Cat', bn: 'বিড়াল', icon: Icons.pets_rounded),
      SpeakWord(en: 'Dog', bn: 'কুকুর', icon: Icons.pets_rounded),
      SpeakWord(en: 'Bird', bn: 'পাখি', icon: Icons.flutter_dash_rounded),
      SpeakWord(en: 'Fish', bn: 'মাছ', icon: Icons.water_rounded),
      SpeakWord(en: 'Lion', bn: 'সিংহ', icon: Icons.pets_rounded),
      SpeakWord(en: 'Elephant', bn: 'হাতি', icon: Icons.pets_rounded),
    ],
    'food': [
      SpeakWord(en: 'Apple', bn: 'আপেল', icon: Icons.apple_rounded),
      SpeakWord(en: 'Banana', bn: 'কলা', icon: Icons.lunch_dining_rounded),
      SpeakWord(en: 'Rice', bn: 'ভাত', icon: Icons.rice_bowl_rounded),
      SpeakWord(en: 'Water', bn: 'পানি', icon: Icons.water_drop_rounded),
      SpeakWord(en: 'Milk', bn: 'দুধ', icon: Icons.local_cafe_rounded),
      SpeakWord(en: 'Bread', bn: 'রুটি', icon: Icons.bakery_dining_rounded),
    ],
    'colors': [
      SpeakWord(en: 'Red', bn: 'লাল', icon: Icons.circle, iconColor: Colors.red),
      SpeakWord(
          en: 'Blue', bn: 'নীল', icon: Icons.circle, iconColor: Colors.blue),
      SpeakWord(
          en: 'Green', bn: 'সবুজ', icon: Icons.circle, iconColor: Colors.green),
      SpeakWord(
          en: 'Yellow',
          bn: 'হলুদ',
          icon: Icons.circle,
          iconColor: Colors.yellow),
      SpeakWord(
          en: 'Orange',
          bn: 'কমলা',
          icon: Icons.circle,
          iconColor: Colors.orange),
      SpeakWord(
          en: 'Purple',
          bn: 'বেগুনি',
          icon: Icons.circle,
          iconColor: Colors.purple),
    ],
    'numbers': [
      SpeakWord(en: 'One', bn: 'এক', icon: Icons.looks_one_rounded),
      SpeakWord(en: 'Two', bn: 'দুই', icon: Icons.looks_two_rounded),
      SpeakWord(en: 'Three', bn: 'তিন', icon: Icons.looks_3_rounded),
      SpeakWord(en: 'Four', bn: 'চার', icon: Icons.looks_4_rounded),
      SpeakWord(en: 'Five', bn: 'পাঁচ', icon: Icons.looks_5_rounded),
      SpeakWord(en: 'Six', bn: 'ছয়', icon: Icons.looks_6_rounded),
    ],
    'family': [
      SpeakWord(en: 'Mother', bn: 'মা', icon: Icons.woman_rounded),
      SpeakWord(en: 'Father', bn: 'বাবা', icon: Icons.man_rounded),
      SpeakWord(en: 'Sister', bn: 'বোন', icon: Icons.girl_rounded),
      SpeakWord(en: 'Brother', bn: 'ভাই', icon: Icons.boy_rounded),
      SpeakWord(
          en: 'Grandmother', bn: 'দাদি/নানি', icon: Icons.elderly_woman_rounded),
      SpeakWord(
          en: 'Grandfather', bn: 'দাদা/নানা', icon: Icons.elderly_rounded),
    ],
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initSpeechRecognition();
  }

  Future<void> _initSpeechRecognition() async {
    _speechInitialized = await _speechService.initializeSpeechRecognition();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.stopListening();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final language = ref.read(languageProvider);
    final isBangla = language == AppLanguage.bangla;

    if (_isRecording) {
      // Stop recording
      await _speechService.stopListening();
      setState(() {
        _isRecording = false;
        _pulseController.stop();
        _pulseController.reset();
      });
    } else {
      // Check if a word is selected
      if (_selectedWord == null) {
        setState(() {
          _feedbackMessage = isBangla 
              ? 'প্রথমে একটি শব্দ নির্বাচন করো!' 
              : 'Please select a word first!';
          _lastMatchResult = null;
        });
        return;
      }

      // Check if speech recognition is available
      if (!_speechInitialized) {
        setState(() {
          _feedbackMessage = isBangla 
              ? 'স্পিচ রিকগনিশন উপলব্ধ নয়' 
              : 'Speech recognition not available';
          _lastMatchResult = null;
        });
        return;
      }

      // Start recording
      setState(() {
        _isRecording = true;
        _recognizedText = '';
        _feedbackMessage = null;
        _lastMatchResult = null;
        _pulseController.repeat(reverse: true);
      });
      Haptics.medium();

      await _speechService.startListening(
        onResult: (text) async {
          setState(() {
            _recognizedText = text;
          });
          
          // Check if the recognized text matches the selected word
          if (text.isNotEmpty && _selectedWord != null) {
            final isMatch = _speechService.checkWordMatch(text, _selectedWord!);
            setState(() {
              _lastMatchResult = isMatch;
              if (isMatch) {
                _feedbackMessage = isBangla ? 'অসাধারণ! 🎉' : 'Great job! 🎉';
                Haptics.success();
              } else {
                _feedbackMessage = isBangla 
                    ? 'আবার চেষ্টা করো! তুমি বললে: "$text"' 
                    : 'Try again! You said: "$text"';
              }
            });
            
            // Stop listening and provide voice feedback
            await _speechService.stopListening();
            setState(() {
              _isRecording = false;
              _pulseController.stop();
              _pulseController.reset();
            });
            
            // Give voice feedback after a short delay
            await Future.delayed(const Duration(milliseconds: 300));
            if (isMatch) {
              await _speechService.speakEncouragement(isBangla: isBangla);
            } else {
              // Say "Try again" and then the correct word
              if (isBangla) {
                await _speechService.speakBangla('আবার চেষ্টা করো');
              } else {
                await _speechService.speakEnglish('Try again');
              }
              await Future.delayed(const Duration(milliseconds: 500));
              // Speak the correct word
              await _speechService.speakWord(_selectedWord!, isBangla: isBangla);
            }
          }
        },
        isBangla: isBangla,
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
      );

      // Auto-stop after listening period if still recording
      Future.delayed(const Duration(seconds: 6), () async {
        if (mounted && _isRecording) {
          await _speechService.stopListening();
          setState(() {
            _isRecording = false;
            _pulseController.stop();
            _pulseController.reset();
            if (_recognizedText.isEmpty) {
              _feedbackMessage = isBangla 
                  ? 'কিছু শুনতে পাইনি। আবার চেষ্টা করো!' 
                  : "I didn't hear anything. Try again!";
              _lastMatchResult = null;
            }
          });
          
          // Speak feedback if nothing was heard
          if (_recognizedText.isEmpty) {
            if (isBangla) {
              await _speechService.speakBangla('আবার চেষ্টা করো');
            } else {
              await _speechService.speakEnglish("Let's try again");
            }
          }
        }
      });
    }
  }

  void _speakWord(SpeakWord word, bool isBangla) {
    _speechService.speakWord(
      isBangla ? word.bn : word.en,
      isBangla: isBangla,
    );
    Haptics.light();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isBangla = language == AppLanguage.bangla;
    final words = _categories[_selectedCategory] ?? [];

    return Scaffold(
      body: ScreenBackground(
        theme: ScreenTheme.speak,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        context.go('/');
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isBangla ? 'চলো বলি' : "Let's Speak",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // Balance the back button
                  ],
                ),
              ),

              // Category Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: Row(
                  children: [
                    _CategoryTab(
                      label: isBangla ? 'পশুপাখি' : 'Animals',
                      icon: Icons.pets_rounded,
                      isSelected: _selectedCategory == 'animals',
                      color: AppTheme.primaryPink,
                      onTap: () => setState(() => _selectedCategory = 'animals'),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _CategoryTab(
                      label: isBangla ? 'খাবার' : 'Food',
                      icon: Icons.restaurant_rounded,
                      isSelected: _selectedCategory == 'food',
                      color: AppTheme.primaryOrange,
                      onTap: () => setState(() => _selectedCategory = 'food'),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _CategoryTab(
                      label: isBangla ? 'রং' : 'Colors',
                      icon: Icons.palette_rounded,
                      isSelected: _selectedCategory == 'colors',
                      color: AppTheme.primaryPurple,
                      onTap: () => setState(() => _selectedCategory = 'colors'),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _CategoryTab(
                      label: isBangla ? 'সংখ্যা' : 'Numbers',
                      icon: Icons.looks_one_rounded,
                      isSelected: _selectedCategory == 'numbers',
                      color: AppTheme.primaryBlue,
                      onTap: () => setState(() => _selectedCategory = 'numbers'),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    _CategoryTab(
                      label: isBangla ? 'পরিবার' : 'Family',
                      icon: Icons.family_restroom_rounded,
                      isSelected: _selectedCategory == 'family',
                      color: AppTheme.primaryGreen,
                      onTap: () => setState(() => _selectedCategory = 'family'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing2Xl),

              // Words Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppTheme.spacingMd,
                      mainAxisSpacing: AppTheme.spacingMd,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      final isSelected =
                          _selectedWord == (isBangla ? word.bn : word.en);
                      return _WordCard(
                        word: word,
                        isBangla: isBangla,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() =>
                              _selectedWord = isBangla ? word.bn : word.en);
                          _speakWord(word, isBangla);
                        },
                      );
                    },
                  ),
                ),
              ),

              // Microphone Button
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing2Xl),
                child: Column(
                  children: [
                    // Feedback Message
                    if (_feedbackMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLg,
                            vertical: AppTheme.spacingMd,
                          ),
                          decoration: BoxDecoration(
                            color: _lastMatchResult == true
                                ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                                : AppTheme.primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(
                              color: _lastMatchResult == true
                                  ? AppTheme.primaryGreen
                                  : AppTheme.primaryOrange,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _feedbackMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _lastMatchResult == true
                                  ? AppTheme.primaryGreen
                                  : AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                    // Recognized text display
                    if (_recognizedText.isNotEmpty && _isRecording)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        child: Text(
                          '"$_recognizedText"',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              _isRecording ? _pulseAnimation.value : 1.0,
                          child: GestureDetector(
                            onTap: _toggleRecording,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? AppTheme.primaryRed
                                    : AppTheme.primaryPink,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording
                                            ? AppTheme.primaryRed
                                            : AppTheme.primaryPink)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      _isRecording
                          ? (isBangla ? 'শুনছি...' : 'Listening...')
                          : (_selectedWord == null 
                              ? (isBangla ? 'প্রথমে একটি শব্দ বেছে নাও' : 'Select a word first')
                              : (isBangla ? 'বলতে মাইকে ট্যাপ করো' : 'Tap to speak')),
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
            ],
          ),
        ),
      ),
    );
  }
}

class SpeakWord {
  final String en;
  final String bn;
  final IconData icon;
  final Color? iconColor;

  SpeakWord({
    required this.en,
    required this.bn,
    required this.icon,
    this.iconColor,
  });
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.icon,
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
              size: 18,
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

class _WordCard extends StatelessWidget {
  final SpeakWord word;
  final bool isBangla;
  final bool isSelected;
  final VoidCallback onTap;

  const _WordCard({
    required this.word,
    required this.isBangla,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryPink
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppTheme.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              word.icon,
              size: 40,
              color: word.iconColor ?? AppTheme.primaryPink,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              isBangla ? word.bn : word.en,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: isBangla ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              isBangla ? word.en : word.bn,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
