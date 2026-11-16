// File: main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding1_screen.dart';
import 'screens/onboarding2_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_transitions.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FoundItApp());
}

// Widget utama aplikasi FoundIt.
class FoundItApp extends StatelessWidget {
  const FoundItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoundIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      onGenerateRoute: (settings) {
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
          case '/':
          default:
            page = const Onboarding1Screen();
        }
        return slideFadeRoute(page);
      },
    );
  }
}
