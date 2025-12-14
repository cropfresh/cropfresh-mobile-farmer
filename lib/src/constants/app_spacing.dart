/// CropFresh Design System Spacing (Material Design 3)
/// Based on 8dp grid system for consistent visual rhythm
class AppSpacing {
  AppSpacing._();

  // ============================================
  // BASE UNIT (8dp grid)
  // ============================================
  static const double unit = 8.0;

  // ============================================
  // SPACING SCALE
  // ============================================
  static const double xxs = 4.0;   // Half unit
  static const double xs = 8.0;    // 1 unit
  static const double sm = 12.0;   // 1.5 units
  static const double md = 16.0;   // 2 units
  static const double lg = 24.0;   // 3 units
  static const double xl = 32.0;   // 4 units
  static const double xxl = 48.0;  // 6 units

  // ============================================
  // SCREEN PADDING
  // ============================================
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 24.0;

  // ============================================
  // CARD & CONTAINER
  // ============================================
  static const double cardPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double cardElevation = 2.0;

  // ============================================
  // SECTION SPACING
  // ============================================
  static const double sectionGap = 24.0;
  static const double itemGap = 12.0;

  // ============================================
  // TOUCH TARGETS (WCAG 2.2 / MD3)
  // ============================================
  static const double minTouchTarget = 48.0;
  static const double recommendedTouchTarget = 56.0;

  // ============================================
  // BOTTOM NAVIGATION (MD3 Spec)
  // ============================================
  static const double bottomNavHeight = 80.0;
  static const double bottomNavIconSize = 24.0;

  // ============================================
  // FAB (Floating Action Button)
  // ============================================
  static const double fabSize = 56.0;
  static const double fabExtendedHeight = 56.0;
  static const double fabMargin = 16.0;

  // ============================================
  // TYPOGRAPHY LEADING
  // ============================================
  static const double headlineSpacing = 8.0;
  static const double bodyLineHeight = 1.5;
}
