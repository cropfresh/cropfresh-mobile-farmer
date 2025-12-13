import 'package:flutter/animation.dart';

/// Material Design 3 (2025 Edition) Animation Constants
/// Based on UX Design Specification and modern Android best practices
class AnimationConstants {
  AnimationConstants._();

  // ============================================
  // DURATION TOKENS (M3 Motion System)
  // ============================================
  
  /// Short duration for micro-interactions (button press, toggles)
  static const Duration durationShort = Duration(milliseconds: 150);
  
  /// Medium duration for most transitions (page transitions, reveals)
  static const Duration durationMedium = Duration(milliseconds: 300);
  
  /// Long duration for complex animations (success celebrations)
  static const Duration durationLong = Duration(milliseconds: 500);
  
  /// Extra long for dramatic effects (onboarding complete)
  static const Duration durationExtraLong = Duration(milliseconds: 800);
  
  /// Splash animation duration
  static const Duration durationSplash = Duration(milliseconds: 1200);
  
  // ============================================
  // SPRING CURVES (Expressive Motion)
  // ============================================
  
  /// Standard easing for most animations
  static const Curve curveStandard = Curves.easeOutCubic;
  
  /// Emphasized easing for important transitions
  static const Curve curveEmphasized = Curves.easeOutQuart;
  
  /// Decelerate easing for entering elements
  static const Curve curveDecelerate = Curves.decelerate;
  
  /// Elastic curve for playful animations (success states)
  static const Curve curveElastic = Curves.elasticOut;
  
  /// Bouncy curve for selection feedback
  static const Curve curveBounce = Curves.bounceOut;
  
  /// Spring curve for natural feel
  static const Curve curveSpring = Curves.easeOutBack;
  
  // ============================================
  // STAGGER DELAYS (For lists and grids)
  // ============================================
  
  /// Delay between staggered list items
  static const Duration staggerDelay = Duration(milliseconds: 50);
  
  /// Delay for grid items (shorter for dense grids)
  static const Duration staggerDelayGrid = Duration(milliseconds: 30);
  
  // ============================================
  // SCALE VALUES
  // ============================================
  
  /// Button press scale down
  static const double scalePressed = 0.95;
  
  /// Selection pulse scale up
  static const double scalePulse = 1.05;
  
  /// Logo initial scale for splash
  static const double scaleLogoStart = 0.6;
  
  // ============================================
  // FADE VALUES
  // ============================================
  
  /// Disabled state opacity
  static const double opacityDisabled = 0.38;
  
  /// Subtle hint opacity
  static const double opacityHint = 0.6;
}
