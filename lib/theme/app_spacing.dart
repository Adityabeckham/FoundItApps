import 'package:flutter/material.dart';

/// Skala spacing FoundIt (padding dan jarak antar elemen), dalam logical pixel.
/// Sumber: Figma > Design System - Foundations > 4. Spacing.
abstract final class AppSpacing {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;

  /// Padding horizontal standar layar (sesuai layout prototype 390 px).
  static const double screenH = s20;
}

/// Skala radius sudut.
/// Sumber: Figma > Design System - Foundations > 3. Radius.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 12;
  static const double md = 14; // input
  static const double lg = 16; // thumbnail
  static const double xl = 20; // kartu
  static const double xxl = 24; // blok besar
  static const double full = 999; // tombol, chip, badge (pill)

  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius xxlAll = BorderRadius.circular(xxl);
  static final BorderRadius fullAll = BorderRadius.circular(full);
}

