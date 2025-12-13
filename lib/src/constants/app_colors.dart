import 'package:flutter/material.dart';

/// CropFresh Design System Colors (Material Design 3)
/// Based on UX Design Specification - M3 2025 Edition
class AppColors {
  AppColors._();
  
  // ============================================
  // PRIMARY PALETTE (Orange - Energy, Harvest, Action)
  // ============================================
  static const Color primary = Color(0xFFF57C00);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFFFE0B2);
  static const Color onPrimaryContainer = Color(0xFFE65100);
  
  // ============================================
  // SECONDARY PALETTE (Green - Growth, Trust, Nature)
  // ============================================
  static const Color secondary = Color(0xFF2E7D32);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFC8E6C9);
  static const Color onSecondaryContainer = Color(0xFF002105);
  
  // ============================================
  // SURFACE PALETTE
  // ============================================
  static const Color surface = Color(0xFFFFF8E1);      // Warm Cream - Organic, paper-like
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFFFFBF5);
  static const Color onSurface = Color(0xFF1C1B1F);    // Near black
  static const Color onSurfaceVariant = Color(0xFF49454F);  // Medium grey
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  
  // ============================================
  // ERROR PALETTE
  // ============================================
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  
  // ============================================
  // STATE COLORS (For interactive elements)
  // ============================================
  static Color primarySelected = primary.withValues(alpha: 0.12);
  static Color secondarySelected = secondary.withValues(alpha: 0.12);
  static Color hoverOverlay = primary.withValues(alpha: 0.08);
  static Color pressedOverlay = primary.withValues(alpha: 0.12);
  static Color disabledOverlay = onSurface.withValues(alpha: 0.12);
  
  // ============================================
  // LEGACY ALIASES (For backward compatibility)
  // ============================================
  static const Color orange = primary;
  static const Color green = secondary;
  static const Color cream = surface;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  
  // ============================================
  // GRADIENTS (Premium feel)
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF57C00), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFF57C00), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
