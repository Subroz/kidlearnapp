import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/section_themes.dart';

class KidCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool showShadow;
  final bool enableHover;

  const KidCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.showShadow = true,
    this.enableHover = true,
  });

  @override
  State<KidCard> createState() => _KidCardState();
}

class _KidCardState extends State<KidCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
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
      onTapDown: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
              HapticFeedback.lightImpact();
            }
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _elevationAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding ??
                    const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: widget.gradient == null
                      ? (widget.backgroundColor ?? Colors.white)
                      : null,
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? AppTheme.radius2Xl),
                  boxShadow: widget.showShadow
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: _isPressed ? 0.05 : 0.08),
                            blurRadius: _isPressed ? 8 : 16,
                            offset: Offset(0, _isPressed ? 4 : 8),
                          ),
                        ]
                      : null,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ModuleCard extends StatefulWidget {
  final ModuleType moduleType;
  final VoidCallback? onTap;
  final bool showProgress;
  final double progress;

  const ModuleCard({
    super.key,
    required this.moduleType,
    this.onTap,
    this.showProgress = false,
    this.progress = 0.0,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final theme = SectionThemes.getTheme(widget.moduleType);

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
              HapticFeedback.mediumImpact();
            }
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: theme.gradient,
                borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: _isPressed ? 0.2 : 0.35),
                    blurRadius: _isPressed ? 8 : 16,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      theme.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    theme.titleEn,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.showProgress) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnswerCard extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;

  const AnswerCard({
    super.key,
    required this.text,
    this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.showResult = false,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (widget.showResult && widget.isSelected) {
      if (widget.isCorrect) {
        bgColor = AppTheme.primaryGreen.withValues(alpha: 0.15);
        borderColor = AppTheme.primaryGreen;
        textColor = AppTheme.primaryGreen;
      } else {
        bgColor = AppTheme.primaryRed.withValues(alpha: 0.15);
        borderColor = AppTheme.primaryRed;
        textColor = AppTheme.primaryRed;
      }
    } else if (widget.isSelected) {
      bgColor = AppTheme.primaryPurple.withValues(alpha: 0.15);
      borderColor = AppTheme.primaryPurple;
      textColor = AppTheme.primaryPurple;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.withValues(alpha: 0.2);
      textColor = AppTheme.textPrimary;
    }

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) {
              _controller.forward();
              HapticFeedback.selectionClick();
            }
          : null,
      onTapUp: widget.onTap != null
          ? (_) => _controller.reverse()
          : null,
      onTapCancel: widget.onTap != null
          ? () => _controller.reverse()
          : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
                vertical: AppTheme.spacingLg,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.showResult && widget.isSelected) ...[
                    Icon(
                      widget.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: textColor,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
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
