import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/section_themes.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/header.dart';
import '../../core/i18n/language_controller.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final theme = SectionThemes.getTheme(ModuleType.games);

    return Scaffold(
      body: ScreenBackground(
        theme: ScreenTheme.games,
        showFloatingShapes: true,
        child: SafeArea(
          child: Column(
            children: [
              Header(
                title: language == AppLanguage.bangla ? 'খেলা' : 'Games',
                subtitle: language == AppLanguage.bangla
                    ? 'খেলতে খেলতে শেখো!'
                    : 'Learn while playing!',
                color: theme.primary,
                showBackButton: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    children: [
                      _GameCard(
                        title: language == AppLanguage.bangla
                            ? 'মেমরি ম্যাচ'
                            : 'Memory Match',
                        description: language == AppLanguage.bangla
                            ? 'জোড়া কার্ড খুঁজে বের করো'
                            : 'Find matching pairs of cards',
                        icon: Icons.grid_view_rounded,
                        color: const Color(0xFF7C3AED),
                        onTap: () => context.push('/games/memory'),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _GameCard(
                        title: language == AppLanguage.bangla
                            ? 'গণনা খেলা'
                            : 'Counting Game',
                        description: language == AppLanguage.bangla
                            ? 'জিনিস গুনতে শেখো'
                            : 'Learn to count objects',
                        icon: Icons.filter_9_plus_rounded,
                        color: const Color(0xFF3B82F6),
                        onTap: () => context.push('/games/counting'),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _GameCard(
                        title: language == AppLanguage.bangla
                            ? 'আকৃতি মেলাও'
                            : 'Shape Match',
                        description: language == AppLanguage.bangla
                            ? 'সঠিক আকৃতি খুঁজে বের করো'
                            : 'Match shapes to their shadows',
                        icon: Icons.category_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => context.push('/games/shapes'),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _GameCard(
                        title: language == AppLanguage.bangla
                            ? 'রং চেনা'
                            : 'Color Quiz',
                        description: language == AppLanguage.bangla
                            ? 'রং চিনতে শেখো'
                            : 'Learn to identify colors',
                        icon: Icons.palette_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => context.push('/games/colors'),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _GameCard(
                        title: language == AppLanguage.bangla
                            ? 'ধাঁধা সমাধান'
                            : 'Pattern Puzzle',
                        description: language == AppLanguage.bangla
                            ? 'পরবর্তী প্যাটার্ন খুঁজে বের করো'
                            : 'Find the next pattern in sequence',
                        icon: Icons.extension_rounded,
                        color: const Color(0xFFEC4899),
                        onTap: () => context.push('/games/puzzle'),
                      ),
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
}

class _GameCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color,
                          widget.color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingLg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
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
                  Icon(
                    Icons.play_circle_filled_rounded,
                    size: 40,
                    color: widget.color,
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
