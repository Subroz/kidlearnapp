import 'package:flutter/services.dart';

class Haptics {
  /// Light haptic feedback for subtle interactions
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for standard interactions
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for significant actions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click feedback
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibration pattern for success
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Vibration pattern for error
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Vibration pattern for celebration
  static void celebrate() {
    Future.delayed(Duration.zero, () => HapticFeedback.mediumImpact());
    Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.lightImpact());
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.mediumImpact());
  }
}
