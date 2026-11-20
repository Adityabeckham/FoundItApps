import 'package:flutter/material.dart';

import 'package:foundit/screens/chat/chat_list_screen.dart';
import 'package:foundit/screens/dashboard/dashboard_screen.dart';
import 'package:foundit/screens/reports/detail_report_screen.dart';
import 'package:foundit/screens/reports/filter_search_screen.dart';
import 'package:foundit/screens/reports/reports_list_screen.dart';
import 'package:foundit/screens/auth/login_screen.dart';
import 'package:foundit/screens/map/map_screen.dart';
import 'package:foundit/screens/notifications/notifications_screen.dart';
import 'package:foundit/screens/profile/profile_screen.dart';
import 'package:foundit/models/item_report.dart';
import 'package:foundit/screens/auth/onboarding1_screen.dart';
import 'package:foundit/screens/auth/onboarding2_screen.dart';
import 'package:foundit/screens/reports/report_form_screen.dart';
import 'package:foundit/utils/app_transitions.dart';

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
      case '/report':
        page = const ReportFormScreen();
        break;
      case '/map':
        page = const MapScreen();
        break;
      case '/chat':
        page = const ChatListScreen();
        break;
      case '/filter-search':
        page = const FilterSearchScreen();
        break;
      case '/all-reports':
        page = const ReportsListScreen(mine: false, title: 'Semua Laporan');
        break;
      case '/my-reports':
        page = const ReportsListScreen(mine: true, title: 'Laporan Saya');
        break;
      case '/notifications':
        page = const NotificationsScreen();
        break;
      case '/detail':
        page = DetailReportScreen(
          report: settings.arguments as ItemReport?,
        );
        break;
      case '/':
      default:
        page = const Onboarding1Screen();
    }
    return slideFadeRoute(page);
  }
}



