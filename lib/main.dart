import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'theme/app_theme.dart';
import 'utils/app_router.dart';

void main() {
  runApp(const FoundItApp());
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
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
