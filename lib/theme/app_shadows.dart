import 'package:flutter/material.dart';

/// Bayangan FoundIt. Sumber: Figma > Design System - Foundations > 5. Bayangan.
/// Pakai pada `BoxDecoration(boxShadow: AppShadows.barUp)`.
abstract final class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 10),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 20), blurRadius: 25),
  ];

  /// Bottom nav dan footer tombol.
  static const List<BoxShadow> barUp = [
    BoxShadow(color: Color(0x140A1A30), offset: Offset(0, -4), blurRadius: 16),
  ];

  /// Bottom sheet (filter, Lost Around Me).
  static const List<BoxShadow> sheetUp = [
    BoxShadow(color: Color(0x240A1A30), offset: Offset(0, -6), blurRadius: 24),
  ];

  /// Pin peta.
  static const List<BoxShadow> brandGlow = [
    BoxShadow(color: Color(0x591D61F2), offset: Offset(0, 4), blurRadius: 10),
  ];
}

