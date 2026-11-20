import 'package:flutter/material.dart';

/// Transisi halaman FoundIt: slide halus + fade + scale ringan.
Route<dynamic> slideFadeRoute(Widget page) {
  return PageRouteBuilder<dynamic>(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final Animation<Offset> offset = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(curved);
      final Animation<double> scale = Tween<double>(
        begin: 0.985,
        end: 1.0,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: offset,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}

/// Helper untuk push halaman dengan transisi FoundIt.
Future<T?> pushSlide<T>(BuildContext context, Widget page) {
  return Navigator.push<T>(context, slideFadeRoute(page) as Route<T>);
}
