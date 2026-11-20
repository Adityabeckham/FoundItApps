import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:foundit/screens/dashboard/dashboard_screen.dart';
import 'package:foundit/screens/auth/onboarding1_screen.dart';

/// Gerbang autentikasi: tampilkan loading, lalu Onboarding atau Dashboard
/// berdasarkan status login Firebase.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const Onboarding1Screen();
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        return const Onboarding1Screen();
      },
    );
  }
}
