import 'package:flutter/material.dart';

/// State autentikasi pengguna (mock untuk MVP, akan diganti Firebase Auth di issue #4).
class AuthProvider extends ChangeNotifier {
  String? _userName;
  bool _isLoading = false;

  String? get userName => _userName;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userName != null;

  void signIn(String name) {
    _isLoading = true;
    notifyListeners();
    _userName = name;
    _isLoading = false;
    notifyListeners();
  }

  void signOut() {
    _userName = null;
    notifyListeners();
  }
}
