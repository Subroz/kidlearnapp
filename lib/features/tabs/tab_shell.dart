import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/i18n/language_controller.dart';

class TabShell extends ConsumerStatefulWidget {
  final Widget child;

  const TabShell({super.key, required this.child});

  @override
  ConsumerState<TabShell> createState() => _TabShellState();
}

class _TabShellState extends ConsumerState<TabShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/math')) return 1;
    if (location.startsWith('/draw')) return 2;
    if (location.startsWith('/story')) return 3;
    if (location.startsWith('/speak')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/math');
        break;
      case 2:
        context.go('/draw');
        break;
      case 3:
        context.go('/story');
        break;
      case 4:
        context.go('/speak');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: language == AppLanguage.bangla ? 'হোম' : 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => _onItemTapped(0, context),
                  color: AppTheme.primaryPurple,
                ),
                _NavItem(
                  icon: Icons.calculate_rounded,
                  label: language == AppLanguage.bangla ? 'গণিত' : 'Math',
                  isSelected: selectedIndex == 1,
                  onTap: () => _onItemTapped(1, context),
                  color: AppTheme.primaryBlue,
                ),
                _NavItem(
                  icon: Icons.brush_rounded,
                  label: language == AppLanguage.bangla ? 'আঁকা' : 'Draw',
                  isSelected: selectedIndex == 2,
                  onTap: () => _onItemTapped(2, context),
                  color: AppTheme.primaryGreen,
                ),
                _NavItem(
                  icon: Icons.auto_stories_rounded,
                  label: language == AppLanguage.bangla ? 'গল্প' : 'Stories',
                  isSelected: selectedIndex == 3,
                  onTap: () => _onItemTapped(3, context),
                  color: AppTheme.primaryOrange,
                ),
                _NavItem(
                  icon: Icons.mic_rounded,
                  label: language == AppLanguage.bangla ? 'বলা' : 'Speak',
                  isSelected: selectedIndex == 4,
                  onTap: () => _onItemTapped(4, context),
                  color: AppTheme.primaryPink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    if (widget.isSelected) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) {
        if (mounted) _controller.reverse();
      });
      _bounceController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _bounceController.stop();
      _bounceController.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _bounceAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.isSelected ? _bounceAnimation.value : 0),
            child: Transform.scale(
              scale: widget.isSelected ? _scaleAnimation.value : 1.0,
              child: SizedBox(
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? widget.color.withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: widget.color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 26,
                        color: widget.isSelected
                            ? widget.color
                            : AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: widget.isSelected ? 12 : 11,
                        fontWeight:
                            widget.isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: widget.isSelected
                            ? widget.color
                            : AppTheme.textTertiary,
                      ),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
