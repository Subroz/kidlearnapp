import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../i18n/language_controller.dart';
import 'kid_button.dart';

class AppHeader extends ConsumerWidget {
  final String? title;
  final bool showBackButton;
  final bool showLanguageToggle;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? titleColor;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = true,
    this.showLanguageToggle = true,
    this.onBackPressed,
    this.actions,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        child: Row(
          children: [
            if (showBackButton)
              KidIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                size: 44,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                iconColor: AppTheme.textPrimary,
              )
            else
              const SizedBox(width: 44),
            const Spacer(),
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? AppTheme.textPrimary,
                ),
              ),
            const Spacer(),
            if (actions != null)
              ...actions!
            else if (showLanguageToggle)
              _LanguageToggle(
                language: language,
                onToggle: () => languageNotifier.toggleLanguage(),
              )
            else
              const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final AppLanguage language;
  final VoidCallback onToggle;

  const _LanguageToggle({
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
              language == AppLanguage.english ? '🇺🇸' : '🇧🇩',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              language == AppLanguage.english ? 'EN' : 'বাং',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final bool showBackButton;

  const Header({
    super.key,
    required this.title,
    this.subtitle,
    required this.color,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          if (showBackButton) const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? AppTheme.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
