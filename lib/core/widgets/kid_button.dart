import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum KidButtonSize { small, medium, large }
enum KidButtonVariant { primary, secondary, outline, ghost }

class KidButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final KidButtonSize size;
  final KidButtonVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final bool fullWidth;
  final double? borderRadius;

  const KidButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.size = KidButtonSize.medium,
    this.variant = KidButtonVariant.primary,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
  });

  @override
  State<KidButton> createState() => _KidButtonState();
}

class _KidButtonState extends State<KidButton>
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    final padding = _getPadding();
    final iconSize = _getIconSize();
    final fontSize = _getFontSize();

    Color bgColor;
    Color fgColor;
    BoxBorder? border;

    switch (widget.variant) {
      case KidButtonVariant.primary:
        bgColor = widget.backgroundColor ?? AppTheme.primaryPurple;
        fgColor = widget.textColor ?? Colors.white;
        break;
      case KidButtonVariant.secondary:
        bgColor = widget.backgroundColor ?? AppTheme.primaryPurple.withValues(alpha: 0.1);
        fgColor = widget.textColor ?? AppTheme.primaryPurple;
        break;
      case KidButtonVariant.outline:
        bgColor = widget.backgroundColor ?? Colors.transparent;
        fgColor = widget.textColor ?? AppTheme.textPrimary;
        border = Border.all(
          color: AppTheme.textTertiary.withValues(alpha: 0.3),
          width: 2,
        );
        break;
      case KidButtonVariant.ghost:
        bgColor = widget.backgroundColor ?? Colors.transparent;
        fgColor = widget.textColor ?? AppTheme.textPrimary;
        break;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: height,
              padding: padding,
              constraints: BoxConstraints(
                minWidth: widget.fullWidth ? double.infinity : 0,
              ),
              decoration: BoxDecoration(
                color: _isPressed
                    ? bgColor.withValues(alpha: bgColor.a * 0.8)
                    : bgColor,
                borderRadius:
                    BorderRadius.circular(widget.borderRadius ?? height / 2),
                border: border,
                boxShadow: widget.variant == KidButtonVariant.primary
                    ? [
                        BoxShadow(
                          color: bgColor.withValues(alpha: 0.3),
                          blurRadius: _isPressed ? 4 : 8,
                          offset: Offset(0, _isPressed ? 2 : 4),
                        ),
                      ]
                    : null,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(fgColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: iconSize, color: fgColor),
                          if (widget.text != null)
                            const SizedBox(width: 8),
                        ],
                        if (widget.text != null)
                          Flexible(
                            child: Text(
                              widget.text!,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: fontSize,
                                fontWeight: FontWeight.w700,
                                color: fgColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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

  double _getHeight() {
    switch (widget.size) {
      case KidButtonSize.small:
        return 40;
      case KidButtonSize.medium:
        return 52;
      case KidButtonSize.large:
        return 64;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case KidButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case KidButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case KidButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case KidButtonSize.small:
        return 18;
      case KidButtonSize.medium:
        return 22;
      case KidButtonSize.large:
        return 28;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case KidButtonSize.small:
        return 14;
      case KidButtonSize.medium:
        return 16;
      case KidButtonSize.large:
        return 18;
    }
  }
}

class KidIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showShadow;

  const KidIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
    this.backgroundColor,
    this.iconColor,
    this.showShadow = true,
  });

  @override
  State<KidIconButton> createState() => _KidIconButtonState();
}

class _KidIconButtonState extends State<KidIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final bgColor = widget.backgroundColor ?? AppTheme.surfaceLight;
    final iconColor = widget.iconColor ?? AppTheme.textPrimary;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _isPressed ? bgColor.withValues(alpha: 0.9) : bgColor,
                shape: BoxShape.circle,
                boxShadow: widget.showShadow
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: _isPressed ? 4 : 8,
                          offset: Offset(0, _isPressed ? 2 : 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                size: widget.size * 0.5,
                color: iconColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
