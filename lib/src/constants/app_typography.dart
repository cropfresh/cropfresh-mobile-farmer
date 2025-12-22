import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CropFresh Design System Typography (Material Design 3)
/// 
/// Consistent typography scale with:
/// - Clear size hierarchy for titles, subtitles, body
/// - Noto Sans for Indic language support
/// - WCAG-compliant line heights and contrast
/// - Minimum 14sp for body text (accessibility)
class AppTypography {
  AppTypography._();

  // ============================================
  // BASE FONT FAMILY
  // ============================================
  static String get fontFamily => GoogleFonts.notoSans().fontFamily ?? 'NotoSans';

  // ============================================
  // DISPLAY STYLES (Largest - Hero sections)
  // ============================================
  static TextStyle get displayLarge => GoogleFonts.notoSans(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle get displayMedium => GoogleFonts.notoSans(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get displaySmall => GoogleFonts.notoSans(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============================================
  // HEADLINE STYLES (Page titles)
  // ============================================
  static TextStyle get headlineLarge => GoogleFonts.notoSans(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get headlineMedium => GoogleFonts.notoSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle get headlineSmall => GoogleFonts.notoSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============================================
  // TITLE STYLES (Section headers, cards)
  // ============================================
  static TextStyle get titleLarge => GoogleFonts.notoSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle get titleMedium => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get titleSmall => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============================================
  // BODY STYLES (Main content - min 14sp)
  // ============================================
  static TextStyle get bodyLarge => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============================================
  // LABEL STYLES (Buttons, chips, captions)
  // ============================================
  static TextStyle get labelLarge => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => GoogleFonts.notoSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ============================================
  // TEXT THEME GENERATOR
  // ============================================
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // ============================================
  // CONVENIENCE METHODS
  // ============================================
  
  /// Get bold variant of any style
  static TextStyle bold(TextStyle style) => style.copyWith(
    fontWeight: FontWeight.w700,
  );

  /// Get semibold variant of any style
  static TextStyle semiBold(TextStyle style) => style.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// Get light variant of any style
  static TextStyle light(TextStyle style) => style.copyWith(
    fontWeight: FontWeight.w300,
  );

  /// Apply color to style
  static TextStyle withColor(TextStyle style, Color color) => style.copyWith(
    color: color,
  );
}
