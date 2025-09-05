import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
      );
      
      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      }
      
      _setError('Registration failed');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      
      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      }
      
      _setError('Login failed');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _currentUser = null;
      _clearError();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
    
    _setLoading(false);
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final user = await _authService.verifyToken();
      _currentUser = user;
      _clearError();
    } catch (e) {
      // Token is invalid or expired
      _currentUser = null;
      await _authService.logout();
    }
    
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    required String username,
    required String email,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = await _authService.updateProfile(
        username: username,
        email: email,
      );
      
      if (updatedUser != null) {
        _currentUser = updatedUser;
        _setLoading(false);
        return true;
      }
      
      _setError('Profile update failed');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount({
    required String password,
    required bool deleteChats,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _authService.deleteAccount(
        password: password,
        deleteChats: deleteChats,
      );
      
      if (success) {
        _currentUser = null;
        _setLoading(false);
        return true;
      }
      
      _setError('Account deletion failed');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  void _clearError() {
    _error = null;
  }
}