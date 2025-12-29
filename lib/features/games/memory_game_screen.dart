import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/header.dart';
import '../../core/i18n/language_controller.dart';

class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  final List<_MemoryCard> _cards = [];
  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isChecking = false;
  int _matchedPairs = 0;
  int _moves = 0;
  int _totalPairs = 6;

  final List<_CardData> _cardDataList = [
    _CardData('A', Colors.red, Icons.abc),
    _CardData('B', Colors.blue, Icons.abc),
    _CardData('1', Colors.green, Icons.looks_one_rounded),
    _CardData('2', Colors.orange, Icons.looks_two_rounded),
    _CardData('3', Colors.purple, Icons.looks_3_rounded),
    _CardData('4', Colors.pink, Icons.looks_4_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cards.clear();
    _matchedPairs = 0;
    _moves = 0;
    _firstCardIndex = null;
    _secondCardIndex = null;
    _isChecking = false;

    final pairs = <_CardData>[];
    for (var data in _cardDataList) {
      pairs.add(data);
      pairs.add(data);
    }
    pairs.shuffle(Random());

    for (int i = 0; i < pairs.length; i++) {
      _cards.add(_MemoryCard(id: i, data: pairs[i]));
    }
    setState(() {});
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFlipped) return;

    HapticFeedback.lightImpact();

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstCardIndex == null) {
      _firstCardIndex = index;
    } else {
      _secondCardIndex = index;
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isChecking = true;
    final first = _cards[_firstCardIndex!];
    final second = _cards[_secondCardIndex!];

    Timer(const Duration(milliseconds: 800), () {
      if (first.data.label == second.data.label) {
        HapticFeedback.mediumImpact();
        setState(() {
          _cards[_firstCardIndex!].isMatched = true;
          _cards[_secondCardIndex!].isMatched = true;
          _matchedPairs++;
        });

        if (_matchedPairs == _totalPairs) {
          _showVictoryDialog();
        }
      } else {
        setState(() {
          _cards[_firstCardIndex!].isFlipped = false;
          _cards[_secondCardIndex!].isFlipped = false;
        });
      }

      _firstCardIndex = null;
      _secondCardIndex = null;
      _isChecking = false;
    });
  }

  void _showVictoryDialog() {
    final language = ref.read(languageProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              language == AppLanguage.bangla ? 'অভিনন্দন!' : 'Congratulations!',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              language == AppLanguage.bangla
                  ? 'তুমি $_moves চালে সব মিলিয়ে ফেলেছো!'
                  : 'You matched all pairs in $_moves moves!',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
            },
            child: Text(
              language == AppLanguage.bangla ? 'আবার খেলো' : 'Play Again',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: ScreenBackground(
        showFloatingShapes: true,
        child: SafeArea(
          child: Column(
            children: [
              Header(
                title: language == AppLanguage.bangla
                    ? 'মেমরি ম্যাচ'
                    : 'Memory Match',
                subtitle: language == AppLanguage.bangla
                    ? 'জোড়া খুঁজে বের করো!'
                    : 'Find the matching pairs!',
                color: const Color(0xFF7C3AED),
                showBackButton: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(
                      label: language == AppLanguage.bangla ? 'চাল' : 'Moves',
                      value: '$_moves',
                      color: AppTheme.primaryBlue,
                    ),
                    _StatChip(
                      label: language == AppLanguage.bangla ? 'মিল' : 'Matched',
                      value: '$_matchedPairs/$_totalPairs',
                      color: AppTheme.primaryGreen,
                    ),
                    IconButton(
                      onPressed: _initializeGame,
                      icon: const Icon(Icons.refresh_rounded),
                      color: AppTheme.primaryOrange,
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _MemoryCardWidget(
                        card: _cards[index],
                        onTap: () => _onCardTap(index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final String label;
  final Color color;
  final IconData icon;

  _CardData(this.label, this.color, this.icon);
}

class _MemoryCard {
  final int id;
  final _CardData data;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.id,
    required this.data,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _MemoryCardWidget extends StatelessWidget {
  final _MemoryCard card;
  final VoidCallback onTap;

  const _MemoryCardWidget({
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: card.isFlipped || card.isMatched
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    card.data.color,
                    card.data.color.withValues(alpha: 0.7),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: (card.isFlipped || card.isMatched
                      ? card.data.color
                      : const Color(0xFF6366F1))
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: card.isFlipped || card.isMatched
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      card.data.icon,
                      size: 36,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.data.label,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : const Center(
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
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
    );
  }
}
