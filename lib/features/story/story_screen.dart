import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/utils/haptics.dart';
import '../../services/gemini_service.dart';
import '../../services/speech_service.dart';
import 'models/story_models.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  final List<String> _selectedWords = [];
  StoryResponse? _generatedStory;
  bool _isGenerating = false;
  bool _isFavorite = false;
  final GeminiService _geminiService = GeminiService();
  final SpeechService _speechService = SpeechService();

  void _toggleWord(String word) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
      } else if (_selectedWords.length < 5) {
        _selectedWords.add(word);
        Haptics.selection();
      }
    });
  }

  void _toggleLanguage() {
    ref.read(languageProvider.notifier).toggleLanguage();
    setState(() {
      _selectedWords.clear();
    });
  }

  Future<void> _generateStory() async {
    if (_selectedWords.length < 3) return;

    setState(() => _isGenerating = true);

    final language = ref.read(languageProvider);
    final isBangla = language == AppLanguage.bangla;

    try {
      final story = await _geminiService.generateStory(
        StoryRequest(words: _selectedWords, isBangla: isBangla),
      );
      setState(() {
        _generatedStory = story;
        _isGenerating = false;
      });
      Haptics.celebrate();
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == AppLanguage.bangla
                  ? 'গল্প তৈরি করতে সমস্যা হয়েছে'
                  : 'Failed to generate story',
            ),
          ),
        );
      }
    }
  }

  void _resetStory() {
    setState(() {
      _selectedWords.clear();
      _generatedStory = null;
      _isFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isBangla = language == AppLanguage.bangla;

    return Scaffold(
      body: ScreenBackground(
        theme: ScreenTheme.stories,
        child: SafeArea(
          child: _generatedStory != null
              ? _StoryView(
                  story: _generatedStory!,
                  isBangla: isBangla,
                  language: language,
                  isFavorite: _isFavorite,
                  onToggleFavorite: () =>
                      setState(() => _isFavorite = !_isFavorite),
                  onReadAloud: () => _speechService.speakStory(
                    _generatedStory!.content,
                    isBangla: isBangla,
                  ),
                  onStopReading: () => _speechService.stop(),
                  onBack: _resetStory,
                )
              : _WordSelector(
                  selectedWords: _selectedWords,
                  isGenerating: _isGenerating,
                  language: language,
                  onToggleWord: _toggleWord,
                  onGenerate: _generateStory,
                  onToggleLanguage: _toggleLanguage,
                ),
        ),
      ),
    );
  }
}

class _WordSelector extends StatelessWidget {
  final List<String> selectedWords;
  final bool isGenerating;
  final AppLanguage language;
  final Function(String) onToggleWord;
  final VoidCallback onGenerate;
  final VoidCallback onToggleLanguage;

  const _WordSelector({
    required this.selectedWords,
    required this.isGenerating,
    required this.language,
    required this.onToggleWord,
    required this.onGenerate,
    required this.onToggleLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = language == AppLanguage.bangla;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Row(
            children: [
              // Back Button
              KidIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.go('/'),
                size: 44,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Text(
                isBangla ? 'গল্পের সময়' : 'Story Time',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggleLanguage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isBangla ? '🇧🇩' : '🇺🇸',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBangla ? 'বাং' : 'EN',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.swap_horiz_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              // Selected count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${selectedWords.length}/5',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Instruction
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Text(
            isBangla
                ? 'গল্প তৈরি করতে ৩-৫টি শব্দ বেছে নাও'
                : 'Select 3-5 words to create your story',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: AppTheme.spacingLg),

        // Word Categories
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            itemCount: WordBankData.categories.length,
            itemBuilder: (context, index) {
              final category = WordBankData.categories[index];
              return _CategorySection(
                category: category,
                selectedWords: selectedWords,
                isBangla: isBangla,
                onToggleWord: onToggleWord,
              );
            },
          ),
        ),

        // Generate Button
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: KidButton(
            text: isGenerating
                ? (isBangla ? 'তৈরি হচ্ছে...' : 'Creating...')
                : (isBangla ? 'গল্প তৈরি করো' : 'Generate Story'),
            icon: isGenerating ? null : Icons.auto_stories_rounded,
            onPressed:
                selectedWords.length >= 3 && !isGenerating ? onGenerate : null,
            isLoading: isGenerating,
            size: KidButtonSize.large,
            fullWidth: true,
            backgroundColor: AppTheme.primaryOrange,
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final WordCategory category;
  final List<String> selectedWords;
  final bool isBangla;
  final Function(String) onToggleWord;

  const _CategorySection({
    required this.category,
    required this.selectedWords,
    required this.isBangla,
    required this.onToggleWord,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBangla ? category.nameBn : category.nameEn,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: category.words.map((word) {
            final wordText = isBangla ? word.wordBn : word.wordEn;
            final isSelected = selectedWords.contains(wordText);
            return _WordChip(
              word: wordText,
              isSelected: isSelected,
              onTap: () => onToggleWord(wordText),
            );
          }).toList(),
        ),
        const SizedBox(height: AppTheme.spacingXl),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool isSelected;
  final VoidCallback onTap;

  const _WordChip({
    required this.word,
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
          color: isSelected ? AppTheme.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryOrange
                : AppTheme.primaryOrange.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              word,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryView extends StatefulWidget {
  final StoryResponse story;
  final bool isBangla;
  final AppLanguage language;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Future<void> Function() onReadAloud;
  final Future<void> Function() onStopReading;
  final VoidCallback onBack;

  const _StoryView({
    required this.story,
    required this.isBangla,
    required this.language,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onReadAloud,
    required this.onStopReading,
    required this.onBack,
  });

  @override
  State<_StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<_StoryView> with TickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _catAnimationController;
  late AnimationController _mouthAnimationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _mouthAnimation;

  @override
  void initState() {
    super.initState();
    _catAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _mouthAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _catAnimationController, curve: Curves.easeInOut),
    );
    _mouthAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _mouthAnimationController, curve: Curves.easeInOut),
    );
  }

  void _startCatAnimation() {
    _catAnimationController.repeat(reverse: true);
    _mouthAnimationController.repeat(reverse: true);
  }

  void _stopCatAnimation() {
    _catAnimationController.stop();
    _catAnimationController.reset();
    _mouthAnimationController.stop();
    _mouthAnimationController.reset();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await widget.onStopReading();
      _stopCatAnimation();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _startCatAnimation();
      await widget.onReadAloud();
      if (mounted) {
        _stopCatAnimation();
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  void dispose() {
    _catAnimationController.dispose();
    _mouthAnimationController.dispose();
    if (_isPlaying) {
      widget.onStopReading();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Row(
            children: [
              KidIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: widget.onBack,
                size: 44,
                backgroundColor: Colors.white,
              ),
              const Spacer(),
              KidIconButton(
                icon: widget.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onPressed: widget.onToggleFavorite,
                size: 44,
                backgroundColor: widget.isFavorite
                    ? AppTheme.primaryPink.withValues(alpha: 0.15)
                    : Colors.white,
                iconColor: widget.isFavorite ? AppTheme.primaryPink : null,
              ),
            ],
          ),
        ),

        // Story Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Cat Character
                if (_isPlaying)
                  _AnimatedSpeakingCat(
                    bounceAnimation: _bounceAnimation,
                    mouthAnimation: _mouthAnimation,
                  ),

                // Title
                Center(
                  child: Text(
                    widget.story.title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppTheme.spacing2Xl),

                // Story Content
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingXl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    boxShadow: AppTheme.shadowMd,
                  ),
                  child: Text(
                    widget.story.content,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: widget.isBangla ? 18 : 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      height: 1.8,
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Moral
                if (widget.story.moral.isNotEmpty) ...[
                  _StorySection(
                    title: widget.isBangla
                        ? 'গল্পের শিক্ষা'
                        : 'Moral of the Story',
                    icon: Icons.lightbulb_rounded,
                    color: AppTheme.primaryGreen,
                    content: widget.story.moral,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],

                // Vocabulary
                if (widget.story.vocabulary.isNotEmpty) ...[
                  _StorySection(
                    title: widget.isBangla ? 'নতুন শব্দ' : 'New Words',
                    icon: Icons.book_rounded,
                    color: AppTheme.primaryBlue,
                    content: widget.story.vocabulary.join(', '),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],

                // Questions
                if (widget.story.questions.isNotEmpty) ...[
                  _StorySection(
                    title: widget.isBangla ? 'ভেবে দেখো' : 'Think About It',
                    icon: Icons.psychology_rounded,
                    color: AppTheme.primaryPurple,
                    content: widget.story.questions.join('\n'),
                  ),
                ],

                const SizedBox(height: AppTheme.spacing3Xl),
              ],
            ),
          ),
        ),

        // Read Aloud Button
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: KidButton(
            text: _isPlaying
                ? (widget.isBangla ? 'থামাও' : 'Stop')
                : (widget.isBangla ? 'পড়ে শোনাও' : 'Read Aloud'),
            icon: _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
            onPressed: _togglePlayPause,
            size: KidButtonSize.large,
            fullWidth: true,
            backgroundColor:
                _isPlaying ? AppTheme.primaryPink : AppTheme.primaryOrange,
          ),
        ),
      ],
    );
  }
}

class _StorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _StorySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSpeakingCat extends StatelessWidget {
  final Animation<double> bounceAnimation;
  final Animation<double> mouthAnimation;

  const _AnimatedSpeakingCat({
    required this.bounceAnimation,
    required this.mouthAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([bounceAnimation, mouthAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -bounceAnimation.value),
            child: Container(
              width: 140,
              height: 160,
              margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 130),
                    painter: _CatPainter(mouthOpenness: mouthAnimation.value),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Speaking...',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  final double mouthOpenness;

  _CatPainter({required this.mouthOpenness});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final orangePaint = Paint()
      ..color = const Color(0xFFFF8C00)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final blackPaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.fill;

    final pinkPaint = Paint()
      ..color = const Color(0xFFFF6B8A)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final leftEarPath = Path()
      ..moveTo(centerX - 28, centerY - 25)
      ..lineTo(centerX - 40, centerY - 58)
      ..lineTo(centerX - 12, centerY - 32)
      ..close();
    canvas.drawPath(leftEarPath, orangePaint);
    canvas.drawPath(leftEarPath, outlinePaint);

    final rightEarPath = Path()
      ..moveTo(centerX + 28, centerY - 25)
      ..lineTo(centerX + 40, centerY - 58)
      ..lineTo(centerX + 12, centerY - 32)
      ..close();
    canvas.drawPath(rightEarPath, orangePaint);
    canvas.drawPath(rightEarPath, outlinePaint);

    final leftInnerEarPath = Path()
      ..moveTo(centerX - 26, centerY - 28)
      ..lineTo(centerX - 35, centerY - 50)
      ..lineTo(centerX - 15, centerY - 33)
      ..close();
    canvas.drawPath(leftInnerEarPath, pinkPaint);

    final rightInnerEarPath = Path()
      ..moveTo(centerX + 26, centerY - 28)
      ..lineTo(centerX + 35, centerY - 50)
      ..lineTo(centerX + 15, centerY - 33)
      ..close();
    canvas.drawPath(rightInnerEarPath, pinkPaint);

    canvas.drawCircle(Offset(centerX, centerY), 48, orangePaint);
    canvas.drawCircle(Offset(centerX, centerY), 48, outlinePaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 12),
        width: 38,
        height: 28,
      ),
      whitePaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 18, centerY - 8),
        width: 24,
        height: 28,
      ),
      whitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 18, centerY - 8),
        width: 24,
        height: 28,
      ),
      whitePaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 18, centerY - 6),
        width: 14,
        height: 18,
      ),
      blackPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 18, centerY - 6),
        width: 14,
        height: 18,
      ),
      blackPaint,
    );

    canvas.drawCircle(Offset(centerX - 14, centerY - 10), 4, whitePaint);
    canvas.drawCircle(Offset(centerX - 20, centerY - 4), 2, whitePaint);
    canvas.drawCircle(Offset(centerX + 22, centerY - 10), 4, whitePaint);
    canvas.drawCircle(Offset(centerX + 16, centerY - 4), 2, whitePaint);

    final nosePath = Path();
    nosePath.moveTo(centerX, centerY + 6);
    nosePath.quadraticBezierTo(centerX - 8, centerY + 14, centerX, centerY + 18);
    nosePath.quadraticBezierTo(centerX + 8, centerY + 14, centerX, centerY + 6);
    canvas.drawPath(nosePath, pinkPaint);

    final noseHighlight = Paint()
      ..color = Colors.white.withAlpha(80)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 2, centerY + 10),
        width: 4,
        height: 3,
      ),
      noseHighlight,
    );

    final mouthHeight = 8 + (mouthOpenness * 16);
    final mouthWidth = 16 + (mouthOpenness * 4);
    
    final mouthBgPaint = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 28),
        width: mouthWidth,
        height: mouthHeight,
      ),
      mouthBgPaint,
    );

    if (mouthOpenness > 0.3) {
      final tonguePaint = Paint()
        ..color = const Color(0xFFFF6B6B)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 30 + (mouthOpenness * 4)),
          width: mouthWidth * 0.6,
          height: mouthHeight * 0.5,
        ),
        tonguePaint,
      );
    }

    final whiskerPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX - 22, centerY + 14),
      Offset(centerX - 50, centerY + 6),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(centerX - 22, centerY + 18),
      Offset(centerX - 52, centerY + 18),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(centerX - 22, centerY + 22),
      Offset(centerX - 50, centerY + 30),
      whiskerPaint,
    );

    canvas.drawLine(
      Offset(centerX + 22, centerY + 14),
      Offset(centerX + 50, centerY + 6),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(centerX + 22, centerY + 18),
      Offset(centerX + 52, centerY + 18),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(centerX + 22, centerY + 22),
      Offset(centerX + 50, centerY + 30),
      whiskerPaint,
    );

    canvas.drawCircle(Offset(centerX - 20, centerY + 12), 2, blackPaint);
    canvas.drawCircle(Offset(centerX - 14, centerY + 14), 2, blackPaint);
    canvas.drawCircle(Offset(centerX - 8, centerY + 12), 2, blackPaint);
    canvas.drawCircle(Offset(centerX + 20, centerY + 12), 2, blackPaint);
    canvas.drawCircle(Offset(centerX + 14, centerY + 14), 2, blackPaint);
    canvas.drawCircle(Offset(centerX + 8, centerY + 12), 2, blackPaint);
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) {
    return oldDelegate.mouthOpenness != mouthOpenness;
  }
}
