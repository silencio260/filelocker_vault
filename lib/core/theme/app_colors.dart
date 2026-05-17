import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark mode
  static const Color darkBackground = Color(0xFF1A1A1D);
  static const Color darkBackgroundSecondary = Color(0xFF242428);
  static const Color darkSurface = Color(0xFF2D2D32);
  static const Color darkSurfaceElevated = Color(0xFF38383E);
  static const Color darkTextPrimary = Color(0xFFE8E6E3);
  static const Color darkTextSecondary = Color(0xFFB8B6B3);
  static const Color darkTextTertiary = Color(0xFF8A8886);
  static const Color darkTextDisabled = Color(0xFF5A5856);
  static const Color darkDivider = Color(0xFF3D3D42);
  static const Color darkBorder = Color(0xFF4A4A50);
  static const Color darkAccent = Color(0xFF5C9CE6);
  static const Color darkAccentLight = Color(0xFF7AB3F0);

  // Glassmorphic
  static const Color glassDarkBg = Color(0x1AFFFFFF);
  static const Color glassLightBg = Color(0x0D000000);
  static const Color glassDarkBorder = Color(0x33FFFFFF);
  static const Color glassLightBorder = Color(0x1A000000);
  static const Color glassHighlight = Color(0x26FFFFFF);

  // Legacy
  static const Color primaryBackground = Color(0xFF121212);
  static const Color primaryText = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color backgroundLight = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFF262626);
  static const Color surfaceElevated = Color(0xFF2D2D2D);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color error = Color(0xFFE53935);
  static const Color darkError = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF2196F3);
  static const Color darkInfo = Color(0xFF64B5F6);
  static const Color divider = Color(0xFF424242);
  static const Color border = Color(0xFF616161);
  static const Color shadow = Color(0xFF000000);
  static const Color overlay = Color(0x80000000);

  // Light mode
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightBackgroundSecondary = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF424242);
  static const Color lightTextTertiary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFBDBDBD);
  static const Color accent = Color(0xFF1976D2);
  static const Color accentLight = Color(0xFF42A5F5);

  // Adaptive helpers
  static Color background(Brightness b) =>
      b == Brightness.dark ? darkBackground : lightBackground;

  static Color surfaceColor(Brightness b) =>
      b == Brightness.dark ? darkSurface : lightSurface;

  static Color textPrimaryColor(Brightness b) =>
      b == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color accentColor(Brightness b) =>
      b == Brightness.dark ? darkAccent : accent;

  // Gradients
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A1D), Color(0xFF242428)],
  );

  // Color schemes
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: Color(0xFF1976D2),
    primaryContainer: Color(0xFFBBDEFB),
    secondary: Color(0xFF424242),
    secondaryContainer: Color(0xFFE0E0E0),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFE53935),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF212121),
    onError: Color(0xFFFFFFFF),
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF5C9CE6),
    primaryContainer: Color(0xFF2D4A6B),
    secondary: Color(0xFFE8E6E3),
    secondaryContainer: Color(0xFF38383E),
    surface: Color(0xFF2D2D32),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFF1A1A1D),
    onSecondary: Color(0xFF1A1A1D),
    onSurface: Color(0xFFE8E6E3),
    onError: Color(0xFF1A1A1D),
  );

  static const MaterialColor primarySwatch = MaterialColor(
    0xFF121212,
    <int, Color>{
      50: Color(0xFFE8E8E8),
      100: Color(0xFFC6C6C6),
      200: Color(0xFFA0A0A0),
      300: Color(0xFF7A7A7A),
      400: Color(0xFF5E5E5E),
      500: Color(0xFF424242),
      600: Color(0xFF3C3C3C),
      700: Color(0xFF333333),
      800: Color(0xFF2A2A2A),
      900: Color(0xFF121212),
    },
  );
}

extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get textTertiary =>
      isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

  Color get backgroundSecondary => isDarkMode
      ? AppColors.darkBackgroundSecondary
      : AppColors.lightBackgroundSecondary;

  Color get surfaceColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

  Color get borderColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;

  Color get dividerColor =>
      isDarkMode ? AppColors.darkDivider : AppColors.lightDivider;

  Color get accentColor => Theme.of(this).colorScheme.primary;

  Color get accentColorVariant =>
      Theme.of(this).colorScheme.primaryContainer;

  Color get glassBg =>
      isDarkMode ? AppColors.glassDarkBg : AppColors.glassLightBg;

  Color get glassBorder =>
      isDarkMode ? AppColors.glassDarkBorder : AppColors.glassLightBorder;

  Color get glassHighlight => AppColors.glassHighlight;
}
