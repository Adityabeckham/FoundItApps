import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/onboarding1_screen.dart';
import '../screens/onboarding2_screen.dart';
import '../utils/app_transitions.dart';

/// Route table terpusat FoundIt.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case '/onboarding2':
        page = const Onboarding2Screen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/dashboard':
        page = const DashboardScreen();
        break;
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/':
      default:
        page = const Onboarding1Screen();
    }
    return slideFadeRoute(page);
  }
}

