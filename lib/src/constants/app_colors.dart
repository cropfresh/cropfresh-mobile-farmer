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

  // ============================================
  // DARK THEME COLORS (WCAG Accessible)
  // ============================================
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceContainer = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);
  
  // Dark theme primary (lighter for dark background)
  static const Color darkPrimary = Color(0xFFFFB74D);
  static const Color darkOnPrimary = Color(0xFF4E2600);
  static const Color darkPrimaryContainer = Color(0xFF7A4400);
  static const Color darkOnPrimaryContainer = Color(0xFFFFDDB3);
  
  // Dark theme secondary
  static const Color darkSecondary = Color(0xFF81C784);
  static const Color darkOnSecondary = Color(0xFF003910);
  static const Color darkSecondaryContainer = Color(0xFF005319);
  static const Color darkOnSecondaryContainer = Color(0xFFA5F3A6);
  
  // Dark theme error
  static const Color darkError = Color(0xFFF2B8B5);
  static const Color darkOnError = Color(0xFF601410);
  static const Color darkErrorContainer = Color(0xFF8C1D18);
  static const Color darkOnErrorContainer = Color(0xFFF9DEDC);

  // ============================================
  // COLOR SCHEME GENERATORS
  // ============================================
  
  /// Generate light theme ColorScheme
  static ColorScheme get lightColorScheme => const ColorScheme.light(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceContainerHigh,
    error: error,
    errorContainer: errorContainer,
    onError: onError,
    onErrorContainer: onErrorContainer,
    outline: outline,
    outlineVariant: outlineVariant,
  );
  
  /// Generate dark theme ColorScheme
  static ColorScheme get darkColorScheme => const ColorScheme.dark(
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceContainerHighest: darkSurfaceContainerHigh,
    error: darkError,
    errorContainer: darkErrorContainer,
    onError: darkOnError,
    onErrorContainer: darkOnErrorContainer,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
  );
}
