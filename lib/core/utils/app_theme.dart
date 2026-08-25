/// App Theme & Design System
/// Centralizes all color tokens, typography, and adaptive theme helpers.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Color constants
// ---------------------------------------------------------------------------

class AppColors {
  AppColors._();

  // Brand palette
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A882);
  static const Color primaryLight = Color(0xFF4DFFCE);

  static const Color accent = Color(0xFFFF6B2B);
  static const Color accentLight = Color(0xFFFF9A63);

  // Dark theme surfaces
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF131929);
  static const Color bgCardLight = Color(0xFF1C2438);

  // Light theme surfaces
  static const Color bgLight = Color(0xFFF2F4F8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardLightBorder = Color(0xFFE2E8F0);

  // Dark theme text
  static const Color textPrimary = Color(0xFFE8EAF0);
  static const Color textSecondary = Color(0xFF8892B0);
  static const Color textDisabled = Color(0xFF4A5568);

  // Light theme text
  static const Color textOnLight = Color(0xFF1A202C);
  static const Color textSecondaryOnLight = Color(0xFF718096);
  static const Color textDisabledOnLight = Color(0xFFA0AEC0);

  // Status
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFBB00);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF4FC3F7);

  // Gauge
  static const Color gaugeBackground = Color(0xFF1A2035);
  static const Color gaugeRing = Color(0xFF1E3045);
  static const Color gaugeLow = Color(0xFF00D4AA);
  static const Color gaugeMid = Color(0xFFFFBB00);
  static const Color gaugeHigh = Color(0xFFFF4757);

  // HUD (always dark — for windshield projection)
  static const Color hudGreen = Color(0xFF39FF14);
}

// ---------------------------------------------------------------------------
// Adaptive color extension
// ---------------------------------------------------------------------------

extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bgColor => isDark ? AppColors.bgDark : AppColors.bgLight;
  Color get cardColor => isDark ? AppColors.bgCard : AppColors.cardWhite;
  Color get cardBorderColor =>
      isDark ? AppColors.bgCardLight : AppColors.cardLightBorder;
  Color get textPrimaryColor =>
      isDark ? AppColors.textPrimary : AppColors.textOnLight;
  Color get textSecondaryColor =>
      isDark ? AppColors.textSecondary : AppColors.textSecondaryOnLight;
  Color get textDisabledColor =>
      isDark ? AppColors.textDisabled : AppColors.textDisabledOnLight;

  /// Resolved primary color — slightly darker in light mode for contrast.
  Color get primaryColor => isDark ? AppColors.primary : AppColors.primaryDark;
}

// ---------------------------------------------------------------------------
// ThemeData
// ---------------------------------------------------------------------------

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          primaryContainer: Color(0xFF004D3A),
          secondary: AppColors.accent,
          surface: AppColors.bgCard,
          surfaceContainerHighest: AppColors.bgDark,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.bgCardLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.bgDark,
        cardTheme: CardThemeData(
          color: AppColors.bgCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.bgCard,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? const IconThemeData(color: AppColors.primary)
                  : const IconThemeData(color: AppColors.textSecondary)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.primary,
            fontSize: 72,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 48,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          labelLarge: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.bgDark,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textDisabled),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.bgCardLight),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.accent,
          thumbColor: AppColors.accent,
        ),
        iconTheme:
            const IconThemeData(color: AppColors.textSecondary, size: 24),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryDark,
          primaryContainer: Color(0xFFB3F0E0),
          secondary: AppColors.accent,
          surface: AppColors.cardWhite,
          surfaceContainerHighest: AppColors.bgLight,
          onSurface: AppColors.textOnLight,
          onSurfaceVariant: AppColors.textSecondaryOnLight,
          outline: AppColors.cardLightBorder,
          error: AppColors.error,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.bgLight,
        cardTheme: CardThemeData(
          color: AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardLightBorder, width: 1),
          ),
          elevation: 0,
          shadowColor: Colors.black12,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardWhite,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textOnLight,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: AppColors.textOnLight),
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.cardWhite,
          indicatorColor: AppColors.primaryDark.withValues(alpha: 0.12),
          iconTheme: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? const IconThemeData(color: AppColors.primaryDark)
                  : const IconThemeData(color: AppColors.textSecondaryOnLight)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                color: states.contains(WidgetState.selected)
                    ? AppColors.primaryDark
                    : AppColors.textSecondaryOnLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardWhite,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.textSecondaryOnLight,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 72,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
          ),
          displayMedium: TextStyle(
            color: AppColors.textOnLight,
            fontSize: 48,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textOnLight,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textOnLight,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: AppColors.textOnLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: AppColors.textOnLight, fontSize: 16),
          bodyMedium:
              TextStyle(color: AppColors.textSecondaryOnLight, fontSize: 14),
          labelLarge: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primaryDark
                  : Colors.grey.shade400),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primaryDark.withValues(alpha: 0.35)
                  : Colors.grey.shade300),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.accent,
          thumbColor: AppColors.accent,
        ),
        iconTheme: const IconThemeData(
            color: AppColors.textSecondaryOnLight, size: 24),
        dividerTheme: const DividerThemeData(
            color: AppColors.cardLightBorder, thickness: 1),
      );
}
