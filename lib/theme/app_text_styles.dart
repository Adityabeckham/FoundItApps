import 'package:flutter/material.dart';

import 'package:foundit/theme/app_colors.dart';

/// Text style FoundIt. Sumber: Figma > Design System - Foundations > 2. Tipografi.
/// Font: Plus Jakarta Sans (daftarkan di pubspec.yaml, lihat README_THEME.md).
/// Nama mengikuti text style Figma, misalnya "Heading/M 20" menjadi [headingM20].
/// Untuk warna lain gunakan `AppTextStyles.bodyM13.copyWith(color: ...)`.
abstract final class AppTextStyles {
  static const String fontFamily = 'PlusJakartaSans';

  static const TextStyle display32 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingXl24 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingL22 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingM20 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingS17 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleL16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleM14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyL14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyM13 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyS12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelXl15 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelM12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelM12Semi = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelS11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
}

