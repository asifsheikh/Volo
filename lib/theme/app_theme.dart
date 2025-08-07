import 'package:flutter/material.dart';

/// Centralized theme configuration for the Volo app
/// This file contains all colors, typography, and design tokens
/// Updated for WCAG AA accessibility compliance
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============================================================================
  // COLOR PALETTE - ACCESSIBILITY COMPLIANT
  // ============================================================================

  /// Primary brand color - Teal (darkened for better contrast)
  /// Changed from #059393 to #047C7C for WCAG AA compliance
  static const Color primary = Color(0xFF047C7C);
  
  /// Secondary color - Light gray for secondary actions
  static const Color secondary = Color(0xFF9CA3AF);
  
  /// Destructive color - Red for errors and warnings
  static const Color destructive = Color(0xFFDC2626);
  
  /// Success color - Darkened green for better contrast
  /// Changed from #10B981 to #059669 for WCAG AA compliance
  static const Color success = Color(0xFF059669);
  
  /// Warning color - Darkened orange for better contrast
  /// Changed from #F59E0B to #D97706 for WCAG AA compliance
  static const Color warning = Color(0xFFD97706);

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================

  /// Primary background color used throughout the app
  static const Color background = Color(0xFFF7F8FA);
  
  /// Card background color
  static const Color cardBackground = Colors.white;
  
  /// Surface background color for elevated elements
  static const Color surfaceBackground = Colors.white;

  // ============================================================================
  // TEXT COLORS - ACCESSIBILITY COMPLIANT
  // ============================================================================

  /// Primary text color - Dark gray (excellent contrast: 14.68:1)
  static const Color textPrimary = Color(0xFF1F2937);
  
  /// Secondary text color - Medium gray (good contrast: 4.83:1)
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// Tertiary text color - Now using secondary text color for accessibility
  /// Changed from #9CA3AF (2.54:1) to #6B7280 (4.83:1) for WCAG AA compliance
  static const Color textTertiary = Color(0xFF6B7280);
  
  /// Text color for buttons with colored backgrounds
  static const Color textOnPrimary = Colors.white;
  
  /// Text color for disabled states
  static const Color textDisabled = Color(0xFF9CA3AF);

  // ============================================================================
  // BORDER COLORS
  // ============================================================================

  /// Primary border color
  static const Color borderPrimary = Color(0xFFE5E7EB);
  
  /// Secondary border color
  static const Color borderSecondary = Color(0xFFD1D5DB);
  
  /// Focus border color - Updated to match new primary
  static const Color borderFocus = Color(0xFF047C7C);

  // ============================================================================
  // SHADOW COLORS
  // ============================================================================

  /// Primary shadow color
  static const Color shadowPrimary = Color(0x1A000000); // 10% opacity
  
  /// Secondary shadow color
  static const Color shadowSecondary = Color(0x0D000000); // 5% opacity

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  /// Font family used throughout the app
  static const String fontFamily = 'Inter';

  /// Text styles for different use cases
  /// Updated to ensure minimum 18pt for primary buttons to leverage 3:1 ratio allowance
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.2,
    color: textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.2,
    color: textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.2,
    color: textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18, // Minimum size for primary buttons to meet 3:1 ratio
    height: 1.3,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
    color: textPrimary,
  );

  static final TextStyle bodyMediumSecondary = bodyMedium.copyWith(
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: textSecondary, // Now uses secondary text color for better contrast
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.3,
    color: textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.2,
    color: textSecondary, // Now uses secondary text color for better contrast
  );

  static const TextStyle linkStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.4,
    color: primary,
    decoration: TextDecoration.underline,
  );

  // ============================================================================
  // BUTTON STYLES - ACCESSIBILITY COMPLIANT
  // ============================================================================

  /// Primary button style - Uses 18pt+ text for 3:1 ratio compliance
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    textStyle: titleLarge, // Uses 18pt text for accessibility compliance
  );

  /// Secondary button style
  static ButtonStyle get secondaryButton => ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: textPrimary,
    side: const BorderSide(color: borderPrimary, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    textStyle: titleMedium,
  );

  /// Disabled button style
  static ButtonStyle get disabledButton => ElevatedButton.styleFrom(
    backgroundColor: secondary,
    foregroundColor: textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    textStyle: titleMedium,
  );

  /// Destructive button style
  static ButtonStyle get destructiveButton => ElevatedButton.styleFrom(
    backgroundColor: destructive,
    foregroundColor: textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    textStyle: titleMedium,
  );

  // ============================================================================
  // INPUT FIELD STYLES
  // ============================================================================

  /// Input decoration for text fields
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: cardBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderPrimary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderPrimary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderFocus, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: destructive),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: bodyMedium.copyWith(color: textTertiary), // Now uses accessible tertiary color
  );

  // ============================================================================
  // CARD STYLES
  // ============================================================================

  /// Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: shadowPrimary,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Elevated card decoration
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: shadowSecondary,
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ============================================================================
  // SPACING
  // ============================================================================

  /// Standard spacing values
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// Standard border radius values
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;

  // ============================================================================
  // COMPLETE THEME - ACCESSIBILITY COMPLIANT
  // ============================================================================

  /// Complete Material theme for the app
  static ThemeData get theme => ThemeData(
    // Color scheme - Updated with accessibility-compliant colors
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      error: destructive,
      surface: surfaceBackground,
      background: background,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onError: textOnPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    
    // Scaffold background
    scaffoldBackgroundColor: background,
    
    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      titleTextStyle: headlineSmall,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primary,
      unselectedItemColor: textTertiary, // Now uses accessible tertiary color
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius16),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderPrimary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderPrimary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: destructive),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: bodyMedium.copyWith(color: textTertiary), // Now uses accessible tertiary color
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButton,
    ),
    
    // Text theme
    textTheme: const TextTheme(
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
    ),
    
    // Font family
    fontFamily: fontFamily,
  );
} 