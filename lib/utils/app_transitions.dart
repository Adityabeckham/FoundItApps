import 'package:flutter/material.dart';

/// Transisi halaman FoundIt: slide halus dari kanan + fade.
Route<dynamic> slideFadeRoute(Widget page) {
  return PageRouteBuilder<dynamic>(
    transitionDuration: const Duration(milliseconds: 900),
    reverseTransitionDuration: const Duration(milliseconds: 900),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final Animation<Offset> offset = Tween<Offset>(
        begin: const Offset(0.12, 0),
        end: Offset.zero,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
