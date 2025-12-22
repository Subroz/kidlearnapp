import 'package:flutter/material.dart';

enum ModuleType {
  alphabet,
  math,
  draw,
  story,
  speak,
  games,
}

class SectionTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final LinearGradient gradient;
  final IconData icon;
  final String titleEn;
  final String titleBn;

  const SectionTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.gradient,
    required this.icon,
    required this.titleEn,
    required this.titleBn,
  });
}

class SectionThemes {
  static const Map<ModuleType, SectionTheme> themes = {
    ModuleType.alphabet: SectionTheme(
      primary: Color(0xFF7C3AED),
      secondary: Color(0xFF9F67FF),
      background: Color(0xFFF3E8FF),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C3AED), Color(0xFF9F67FF)],
      ),
      icon: Icons.abc_rounded,
      titleEn: 'Alphabet',
      titleBn: 'বর্ণমালা',
    ),
    ModuleType.math: SectionTheme(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF60A5FA),
      background: Color(0xFFDBEAFE),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      ),
      icon: Icons.calculate_rounded,
      titleEn: 'Math',
      titleBn: 'গণিত',
    ),
    ModuleType.draw: SectionTheme(
      primary: Color(0xFF10B981),
      secondary: Color(0xFF34D399),
      background: Color(0xFFD1FAE5),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
      ),
      icon: Icons.brush_rounded,
      titleEn: 'Draw',
      titleBn: 'আঁকা',
    ),
    ModuleType.story: SectionTheme(
      primary: Color(0xFFF59E0B),
      secondary: Color(0xFFFBBF24),
      background: Color(0xFFFEF3C7),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ),
      icon: Icons.auto_stories_rounded,
      titleEn: 'Stories',
      titleBn: 'গল্প',
    ),
    ModuleType.speak: SectionTheme(
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFF472B6),
      background: Color(0xFFFCE7F3),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
      ),
      icon: Icons.mic_rounded,
      titleEn: 'Speak',
      titleBn: 'বলা',
    ),
    ModuleType.games: SectionTheme(
      primary: Color(0xFFEF4444),
      secondary: Color(0xFFF87171),
      background: Color(0xFFFEE2E2),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
      ),
      icon: Icons.sports_esports_rounded,
      titleEn: 'Games',
      titleBn: 'খেলা',
    ),
  };

  static SectionTheme getTheme(ModuleType type) {
    return themes[type]!;
  }
}
