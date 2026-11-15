import 'package:flutter/material.dart';

/// Token warna FoundIt.
/// Sumber: Figma > Design System - Foundations > 1. Warna (koleksi "Color").
/// Nama konstanta mengikuti nama variabel Figma, misalnya
/// `color/text/secondary` menjadi [AppColors.textSecondary].
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF1D61F2);
  static const Color primaryPressed = Color(0xFF0051D5);

  // Background
  static const Color bgScreen = Color(0xFFF6F8FF);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgSubtle = Color(0xFFEAEDFF);
  static const Color bgAccentSoft = Color(0xFFDBE1FF);
  static const Color bgHighlight = Color(0xFFF0F5FF);
  static const Color bgInverse = Color(0xFF0B1A30);

  // Text
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF516070);
  static const Color textMuted = Color(0xFF8A94A6);
  static const Color textOnBrand = Color(0xFFFFFFFF);
  static const Color textOnBrandSoft = Color(0xFFBFDBFE);
  static const Color textBrand = Color(0xFF1D61F2);
  static const Color textWarning = Color(0xFF92400E);

  // Border dan ikon
  static const Color border = Color(0xFFE2E7FF);
  static const Color borderBrand = Color(0xFF1D61F2);
  static const Color iconMuted = Color(0xFF8A94A6);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);

  // Kategori barang (pasangan latar dan ikon/teks)
  static const Color categoryOrangeBg = Color(0xFFFDE8D4);
  static const Color categoryOrangeFg = Color(0xFFC2570C);
  static const Color categoryPurpleBg = Color(0xFFEDE4FF);
  static const Color categoryPurpleFg = Color(0xFF7C3AED);
  static const Color categoryGreenBg = Color(0xFFE2F5E9);
  static const Color categoryGreenFg = Color(0xFF16A34A);
  static const Color categoryBlueBg = Color(0xFFDBE1FF);
  static const Color categoryBlueFg = Color(0xFF1D61F2);

  // Peta
  static const Color mapUserLocation = Color(0xFF0EA5E9);
}

