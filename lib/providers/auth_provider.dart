import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _token;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String? get error => _error;

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        _token = response['token'];
        _user = response['user'];
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'فشل في تسجيل الدخول');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Signup
  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (response['success'] == true) {
        _user = response['user'];
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'فشل في إنشاء الحساب');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Request Password Reset
  Future<bool> requestPasswordReset({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.requestPasswordReset(email: email);

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'فشل في إرسال رمز التحقق');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.verifyOtp(
        email: email,
        otp: otp,
      );

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'رمز التحقق غير صحيح');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'فشل في تغيير كلمة المرور');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout errors
    }

    _token = null;
    _user = null;
    _isAuthenticated = false;
    _clearError();
    _setLoading(false);
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
