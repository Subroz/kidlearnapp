import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/header.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/i18n/language_controller.dart';
import '../../services/spelling_bee_service.dart';
import '../../services/speech_service.dart';
import 'models/spelling_models.dart';

class SpellingBeeScreen extends ConsumerStatefulWidget {
  const SpellingBeeScreen({super.key});

  @override
  ConsumerState<SpellingBeeScreen> createState() => _SpellingBeeScreenState();
}

class _SpellingBeeScreenState extends ConsumerState<SpellingBeeScreen>
    with TickerProviderStateMixin {
  final SpellingBeeService _spellingService = SpellingBeeService();
  final SpeechService _speechService = SpeechService();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  // Game state
  SpellingGameState _gameState = const SpellingGameState();
  SpellingWord? _currentWord;
  bool _isLoading = false;
  bool _isListening = false;
  String _currentHint = '';
  int _hintLevel = 0;

  // Animations
  late AnimationController _beeController;
  late AnimationController _celebrationController;
  late Animation<double> _beeAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startGame();
  }

  void _initializeAnimations() {
    _beeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _beeAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _beeController, curve: Curves.easeInOut),
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _beeController.dispose();
    _celebrationController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startGame() {
    _spellingService.resetSession();
    setState(() {
      _gameState = const SpellingGameState();
      _currentHint = '';
      _hintLevel = 0;
    });
    _loadNextWord();
  }

  void _loadNextWord() {
    final isBangla = ref.read(languageProvider) == AppLanguage.bangla;
    setState(() {
      _currentWord = _spellingService.getRandomWord(
        _gameState.currentDifficulty,
        isBangla: isBangla,
      );
      _inputController.clear();
      _currentHint = '';
      _hintLevel = 0;
      _gameState = _gameState.copyWith(
        hintsRemaining: 3,
      );
    });
    _speakCurrentWord();
  }

  Future<void> _speakCurrentWord() async {
    if (_currentWord == null) return;
    final isBangla = ref.read(languageProvider) == AppLanguage.bangla;
    final word = _currentWord!.getWord(isBangla);
    
    await _speechService.speakWord(word, isBangla: isBangla);
  }

  Future<void> _checkSpelling() async {
    if (_currentWord == null || _inputController.text.trim().isEmpty) return;

    final isBangla = ref.read(languageProvider) == AppLanguage.bangla;
    final userInput = _inputController.text.trim();

    final evaluation = _spellingService.checkSpelling(
      userInput,
      _currentWord!,
      isBangla: isBangla,
    );

    final feedback = await _spellingService.getEncouragingFeedback(
      evaluation.isCorrect,
      _gameState.streak,
      isBangla: isBangla,
    );

    if (evaluation.isCorrect) {
      setState(() {
        _gameState = _gameState.copyWith(
          score: _gameState.score + _calculateScore(),
          streak: _gameState.streak + 1,
          totalAttempts: _gameState.totalAttempts + 1,
          correctAttempts: _gameState.correctAttempts + 1,
        );
      });
      _celebrationController.forward(from: 0);
      HapticFeedback.mediumImpact();
    } else {
      final newWeakWords = List<String>.from(_gameState.weakWords);
      if (!newWeakWords.contains(_currentWord!.wordEn)) {
        newWeakWords.add(_currentWord!.wordEn);
      }
      setState(() {
        _gameState = _gameState.copyWith(
          streak: _gameState.streak > 0 ? 0 : _gameState.streak - 1,
          totalAttempts: _gameState.totalAttempts + 1,
          weakWords: newWeakWords,
        );
      });
      HapticFeedback.lightImpact();
    }

    // Check for difficulty change
    final suggestedDifficulty = _gameState.suggestDifficultyChange();
    if (suggestedDifficulty != null) {
      setState(() {
        _gameState = _gameState.copyWith(
          currentDifficulty: suggestedDifficulty,
          streak: 0,
        );
      });
    }

    // Show result dialog
    if (mounted) {
      _showResultDialog(evaluation.isCorrect, feedback, isBangla, suggestedDifficulty);
    }

    // Speak feedback
    if (evaluation.isCorrect) {
      await _speechService.speakEncouragement(isBangla: isBangla);
    }
  }

  void _showResultDialog(bool isCorrect, String feedback, bool isBangla, SpellingDifficulty? newDifficulty) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCorrect
                  ? [AppTheme.primaryGreen, AppTheme.primaryGreen.withValues(alpha: 0.9)]
                  : [AppTheme.primaryOrange, AppTheme.primaryOrange.withValues(alpha: 0.9)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
            boxShadow: [
              BoxShadow(
                color: (isCorrect ? AppTheme.primaryGreen : AppTheme.primaryOrange)
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Result Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.celebration_rounded : Icons.refresh_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Feedback Text
              Text(
                feedback,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              // Show correct answer if wrong
              if (!isCorrect && _currentWord != null) ...[
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  isBangla ? 'সঠিক বানান:' : 'Correct spelling:',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Text(
                    _currentWord!.getWord(isBangla),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],

              // Level change notification
              if (newDifficulty != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        newDifficulty.index > _gameState.currentDifficulty.index
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBangla
                            ? 'লেভেল: ${_getDifficultyLabelFull(newDifficulty, isBangla)}'
                            : 'Level: ${_getDifficultyLabelFull(newDifficulty, isBangla)}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingXl),

              // Next Word Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadNextWord();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isCorrect ? AppTheme.primaryGreen : AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: isCorrect ? AppTheme.primaryGreen : AppTheme.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBangla ? 'পরের শব্দ' : 'Next Word',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isCorrect ? AppTheme.primaryGreen : AppTheme.primaryOrange,
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

  String _getDifficultyLabelFull(SpellingDifficulty difficulty, bool isBangla) {
    return switch (difficulty) {
      SpellingDifficulty.easy => isBangla ? 'সহজ' : 'Easy',
      SpellingDifficulty.medium => isBangla ? 'মাঝারি' : 'Medium',
      SpellingDifficulty.hard => isBangla ? 'কঠিন' : 'Hard',
    };
  }

  int _calculateScore() {
    final baseScore = switch (_gameState.currentDifficulty) {
      SpellingDifficulty.easy => 10,
      SpellingDifficulty.medium => 20,
      SpellingDifficulty.hard => 30,
    };
    final hintPenalty = _hintLevel * 3;
    final streakBonus = _gameState.streak * 2;
    return baseScore - hintPenalty + streakBonus;
  }

  Future<void> _getHint() async {
    if (_currentWord == null || _gameState.hintsRemaining <= 0) return;

    setState(() => _isLoading = true);
    
    final isBangla = ref.read(languageProvider) == AppLanguage.bangla;
    _hintLevel++;
    
    final hint = await _spellingService.generateHint(
      _currentWord!,
      isBangla: isBangla,
      hintLevel: _hintLevel,
    );

    setState(() {
      _currentHint = hint.hint;
      _gameState = _gameState.copyWith(
        hintsRemaining: _gameState.hintsRemaining - 1,
      );
      _isLoading = false;
    });

    // Speak the hint
    await _speechService.speakWord(hint.hint, isBangla: isBangla);
  }

  Future<void> _startVoiceInput() async {
    final isBangla = ref.read(languageProvider) == AppLanguage.bangla;
    
    setState(() => _isListening = true);

    final success = await _speechService.startListening(
      onResult: (text) {
        setState(() {
          _inputController.text = text;
        });
      },
      isBangla: isBangla,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice input error: $error')),
        );
      },
    );

    if (!success) {
      setState(() => _isListening = false);
    }
  }

  void _stopVoiceInput() {
    _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _showDifficultyChangeDialog(SpellingDifficulty newDifficulty, bool isBangla) {
    final levelName = switch (newDifficulty) {
      SpellingDifficulty.easy => isBangla ? 'সহজ' : 'Easy',
      SpellingDifficulty.medium => isBangla ? 'মাঝারি' : 'Medium',
      SpellingDifficulty.hard => isBangla ? 'কঠিন' : 'Hard',
    };

    final isLevelUp = newDifficulty.index > _gameState.currentDifficulty.index;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isLevelUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isLevelUp
                  ? (isBangla ? 'দারুণ! এখন $levelName লেভেল!' : 'Great! Now at $levelName level!')
                  : (isBangla ? '$levelName লেভেলে অনুশীলন করো' : 'Practice at $levelName level'),
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: isLevelUp ? AppTheme.primaryGreen : AppTheme.primaryOrange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isBangla = language == AppLanguage.bangla;

    return Scaffold(
      body: ScreenBackground(
        theme: ScreenTheme.games,
        showFloatingShapes: true,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Header(
                title: isBangla ? 'স্পেলিং বি' : 'Spelling Bee',
                subtitle: isBangla
                    ? 'শব্দ শুনে বানান লেখো!'
                    : 'Listen and spell the word!',
                color: const Color(0xFFF59E0B),
                showBackButton: true,
              ),

              // Stats Bar
              _buildStatsBar(isBangla),

              // Main Game Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    children: [
                      // Animated Bee Mascot
                      _buildBeeMascot(),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Word Display Area
                      _buildWordArea(isBangla),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Hint Area
                      if (_currentHint.isNotEmpty) _buildHintArea(isBangla),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Input Area
                      _buildInputArea(isBangla),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Action Buttons
                      _buildActionButtons(isBangla),

                      const SizedBox(height: AppTheme.spacing3Xl),
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

  Widget _buildStatsBar(bool isBangla) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.star_rounded,
            value: '${_gameState.score}',
            label: isBangla ? 'স্কোর' : 'Score',
            color: const Color(0xFFF59E0B),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            value: '${_gameState.streak}',
            label: isBangla ? 'ধারা' : 'Streak',
            color: AppTheme.primaryOrange,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _StatItem(
            icon: Icons.lightbulb_rounded,
            value: '${_gameState.hintsRemaining}',
            label: isBangla ? 'হিন্ট' : 'Hints',
            color: AppTheme.primaryBlue,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _StatItem(
            icon: Icons.trending_up_rounded,
            value: _getDifficultyLabel(isBangla),
            label: isBangla ? 'লেভেল' : 'Level',
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(bool isBangla) {
    return switch (_gameState.currentDifficulty) {
      SpellingDifficulty.easy => isBangla ? 'সহজ' : 'Easy',
      SpellingDifficulty.medium => isBangla ? 'মাঝারি' : 'Mid',
      SpellingDifficulty.hard => isBangla ? 'কঠিন' : 'Hard',
    };
  }

  Widget _buildBeeMascot() {
    return AnimatedBuilder(
      animation: _beeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _beeAnimation.value),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🐝',
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordArea(bool isBangla) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isBangla ? 'শব্দটি বানান করো:' : 'Spell this word:',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Listen button
          GestureDetector(
            onTap: _speakCurrentWord,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    isBangla ? 'শব্দ শুনুন' : 'Listen',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_currentWord != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              isBangla ? 'বিভাগ: ${_currentWord!.category}' : 'Category: ${_currentWord!.category}',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHintArea(bool isBangla) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              _currentHint,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isBangla) {
    return Column(
      children: [
        // Text Input Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowMd,
          ),
          child: TextField(
            controller: _inputController,
            focusNode: _inputFocusNode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: isBangla ? 'এখানে লিখো...' : 'Type here...',
              hintStyle: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 2,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingLg,
              ),
              suffixIcon: _inputController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _inputController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _checkSpelling(),
            textInputAction: TextInputAction.done,
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Voice Input Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isListening ? _stopVoiceInput : _startVoiceInput,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [AppTheme.primaryRed, AppTheme.primaryRed.withValues(alpha: 0.8)]
                        : [AppTheme.primaryPurple, AppTheme.primaryPurple.withValues(alpha: 0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? AppTheme.primaryRed : AppTheme.primaryPurple)
                          .withValues(alpha: 0.4),
                      blurRadius: _isListening ? 20 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              _isListening
                  ? (isBangla ? 'শুনছি...' : 'Listening...')
                  : (isBangla ? 'ভয়েসে বলো' : 'Speak'),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isListening ? AppTheme.primaryRed : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isBangla) {
    return Column(
      children: [
        // Check Button (full width, prominent)
        SizedBox(
          width: double.infinity,
          child: KidButton(
            text: isBangla ? 'চেক করো' : 'Check',
            icon: Icons.check_circle_rounded,
            onPressed: _inputController.text.trim().isNotEmpty
                ? _checkSpelling
                : null,
            size: KidButtonSize.large,
            backgroundColor: AppTheme.primaryGreen,
            fullWidth: true,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Hint and Skip buttons side by side
        Row(
          children: [
            // Hint Button
            Expanded(
              child: KidButton(
                text: isBangla ? 'হিন্ট' : 'Hint',
                icon: Icons.lightbulb_outline_rounded,
                onPressed: _gameState.hintsRemaining > 0 && !_isLoading ? _getHint : null,
                size: KidButtonSize.small,
                backgroundColor: AppTheme.primaryBlue,
                fullWidth: true,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // Skip Button
            Expanded(
              child: KidButton(
                text: isBangla ? 'বাদ দাও' : 'Skip',
                icon: Icons.skip_next_rounded,
                onPressed: _loadNextWord,
                size: KidButtonSize.small,
                backgroundColor: AppTheme.primaryOrange,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
