import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/section_themes.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/kid_card.dart';
import '../../core/i18n/language_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      body: ScreenBackground(
        theme: ScreenTheme.home,
        showFloatingShapes: true,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with language toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(bounds),
                            child: Text(
                              language == AppLanguage.bangla
                                  ? 'কিডলার্ন'
                                  : 'KidLearn',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            language == AppLanguage.bangla
                                ? 'চলো আজ নতুন কিছু শিখি!'
                                : 'Let\'s learn something new today!',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      _LanguageToggleButton(
                        language: language,
                        onToggle: () => languageNotifier.toggleLanguage(),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing3Xl),

                  // Progress Card
                  _ProgressCard(language: language),

                  const SizedBox(height: AppTheme.spacing3Xl),

                  // Section Title
                  Text(
                    language == AppLanguage.bangla
                        ? 'শেখার মডিউল'
                        : 'Learning Modules',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Module Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppTheme.spacingLg,
                    mainAxisSpacing: AppTheme.spacingLg,
                    childAspectRatio: 1.0,
                    children: [
                      ModuleCard(
                        moduleType: ModuleType.alphabet,
                        onTap: () => _showAlphabetChoice(context, language),
                      ),
                      ModuleCard(
                        moduleType: ModuleType.math,
                        onTap: () => context.go('/math'),
                      ),
                      ModuleCard(
                        moduleType: ModuleType.draw,
                        onTap: () => context.go('/draw'),
                      ),
                      ModuleCard(
                        moduleType: ModuleType.story,
                        onTap: () => context.go('/story'),
                      ),
                      ModuleCard(
                        moduleType: ModuleType.speak,
                        onTap: () => context.go('/speak'),
                      ),
                      ModuleCard(
                        moduleType: ModuleType.games,
                        onTap: () => context.push('/games'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing3Xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAlphabetChoice(BuildContext context, AppLanguage language) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacing2Xl),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radius2Xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Text(
              language == AppLanguage.bangla
                  ? 'বর্ণমালা নির্বাচন করুন'
                  : 'Choose Alphabet',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2Xl),
            Row(
              children: [
                Expanded(
                  child: _AlphabetChoiceCard(
                    title: 'English',
                    subtitle: 'A B C D...',
                    color: AppTheme.primaryBlue,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/alphabet/english');
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLg),
                Expanded(
                  child: _AlphabetChoiceCard(
                    title: 'বাংলা',
                    subtitle: 'অ আ ই ঈ...',
                    color: AppTheme.primaryGreen,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/alphabet/bangla');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXl),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggleButton extends StatelessWidget {
  final AppLanguage language;
  final VoidCallback onToggle;

  const _LanguageToggleButton({
    required this.language,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: AppTheme.shadowMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language == AppLanguage.english ? '🇺🇸' : '🇧🇩',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              language == AppLanguage.english ? 'EN' : 'বাং',
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
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatefulWidget {
  final AppLanguage language;

  const _ProgressCard({required this.language});

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF6366F1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 100),
                      painter: _SparklePainter(progress: _sparkleController.value),
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.language == AppLanguage.bangla
                                ? 'তোমার অগ্রগতি'
                                : 'Your Progress',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.language == AppLanguage.bangla
                                ? 'দারুণ করছো!'
                                : 'Great job!',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _AnimatedProgressStat(
                                icon: Icons.star_rounded,
                                value: '150',
                                label: widget.language == AppLanguage.bangla ? 'পয়েন্ট' : 'Points',
                              ),
                              const SizedBox(width: 20),
                              _AnimatedProgressStat(
                                icon: Icons.local_fire_department_rounded,
                                value: '5',
                                label: widget.language == AppLanguage.bangla ? 'দিন' : 'Days',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _AnimatedProgressCircle(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;

  _SparklePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.fill;

    final sparkles = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 0.85, size.height * 0.3),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final offset = sparkles[i];
      final phase = (progress + i * 0.2) % 1.0;
      final sparkleSize = 3 + 4 * (0.5 + 0.5 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2));
      paint.color = Colors.white.withAlpha((150 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2)).toInt());
      
      final path = Path();
      path.moveTo(offset.dx, offset.dy - sparkleSize);
      path.lineTo(offset.dx + sparkleSize * 0.3, offset.dy);
      path.lineTo(offset.dx, offset.dy + sparkleSize);
      path.lineTo(offset.dx - sparkleSize * 0.3, offset.dy);
      path.close();
      
      path.moveTo(offset.dx - sparkleSize, offset.dy);
      path.lineTo(offset.dx, offset.dy + sparkleSize * 0.3);
      path.lineTo(offset.dx + sparkleSize, offset.dy);
      path.lineTo(offset.dx, offset.dy - sparkleSize * 0.3);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AnimatedProgressCircle extends StatefulWidget {
  @override
  State<_AnimatedProgressCircle> createState() => _AnimatedProgressCircleState();
}

class _AnimatedProgressCircleState extends State<_AnimatedProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    _progressAnimation = Tween<double>(begin: 0, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedProgressStat extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;

  const _AnimatedProgressStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  State<_AnimatedProgressStat> createState() => _AnimatedProgressStatState();
}

class _AnimatedProgressStatState extends State<_AnimatedProgressStat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
    return Row(
      children: [
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: Icon(widget.icon, color: Colors.amber, size: 20),
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          widget.value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _AlphabetChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AlphabetChoiceCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
