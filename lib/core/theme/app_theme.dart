import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF5C9CE6);
  static const _primaryLight = Color(0xFF1976D2);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? _primary : _primaryLight;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final colorScheme =
        isDark ? AppColors.darkColorScheme : AppColors.lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primarySwatch: AppColors.primarySwatch,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: _buildTextTheme(textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: textColor),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightTextPrimary,
        contentTextStyle: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackground,
        selectedItemColor: primary,
        unselectedItemColor:
            isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBackgroundSecondary,
        selectedColor: primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: textColor),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
          color: textColor, fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: TextStyle(
          color: textColor, fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(
          color: textColor, fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(
          color: textColor, fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(
          color: textColor, fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(
          color: textColor, fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          color: textColor, fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(
          color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(
          color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(
          color: textColor, fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(
          color: textColor, fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(
          color: textColor, fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(
          color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(
          color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(
          color: textColor, fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}
