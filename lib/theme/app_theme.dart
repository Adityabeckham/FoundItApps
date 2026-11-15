import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// ThemeData FoundIt. Pasang di `MaterialApp(theme: AppTheme.light)`.
/// Komponen Material (tombol, input, chip, kartu, app bar, bottom nav)
/// otomatis mengikuti token Figma, jadi widget tidak perlu mengatur warna sendiri.
abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnBrand,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      outline: AppColors.border,
    );

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: const BorderSide(color: AppColors.border, width: 1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.bgScreen,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display32,
        headlineLarge: AppTextStyles.headingXl24,
        headlineMedium: AppTextStyles.headingL22,
        headlineSmall: AppTextStyles.headingM20,
        titleLarge: AppTextStyles.headingS17,
        titleMedium: AppTextStyles.titleL16,
        titleSmall: AppTextStyles.titleM14,
        bodyLarge: AppTextStyles.bodyL14,
        bodyMedium: AppTextStyles.bodyM13,
        bodySmall: AppTextStyles.bodyS12,
        labelLarge: AppTextStyles.labelXl15,
        labelMedium: AppTextStyles.labelM12,
        labelSmall: AppTextStyles.labelS11,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgScreen,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingS17,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnBrand,
          disabledBackgroundColor: AppColors.bgAccentSoft,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s14,
          ),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelXl15,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s14,
          ),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelXl15,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s14,
          vertical: AppSpacing.s14,
        ),
        hintStyle: AppTextStyles.bodyM13.copyWith(color: AppColors.textMuted),
        errorStyle: AppTextStyles.bodyS12.copyWith(color: AppColors.error),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
        showCheckmark: false,
        labelStyle:
            AppTextStyles.labelM12Semi.copyWith(color: AppColors.textSecondary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s4,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: AppTextStyles.caption10,
        unselectedLabelStyle: AppTextStyles.caption10,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

