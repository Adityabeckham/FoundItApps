import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/item_report.dart';
import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'screens/auth_gate.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();
  NotificationService.onSelectNotification = _openDetailFromPayload;
  final String? launchPayload = NotificationService.takeLaunchPayload();
  runApp(const FoundItApp());
  if (launchPayload != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openDetailFromPayload(launchPayload);
    });
  }
}

void _openDetailFromPayload(String payload) {
  final ItemReport? item = NotificationService.decodePayload(payload);
  if (item == null) return;
  navigatorKey.currentState?.pushNamed('/detail', arguments: item);
}

// Widget utama aplikasi FoundIt.
class FoundItApp extends StatelessWidget {
  const FoundItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ItemProvider>(create: (_) => ItemProvider()),
      ],
      child: MaterialApp(
        title: 'FoundIt',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
