import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _showPassword = false;

  bool get showPassword => _showPassword;
  void setShowPassword(bool value) {
    _showPassword = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
