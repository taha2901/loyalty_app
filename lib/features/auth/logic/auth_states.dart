import 'package:flutter/material.dart';
import 'package:loyalty_app/features/auth/data/models/user_model.dart';
import 'package:loyalty_app/features/auth/data/repo/auth_repo.dart';

class AuthProvider with ChangeNotifier {
  final DummyDataRepository _repository = DummyDataRepository();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final user = _repository.getUserByEmail(email);
    
    if (user != null) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update user points (after transaction)
  void updateUserPoints(double newPoints) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(points: newPoints);
      notifyListeners();
    }
  }
}