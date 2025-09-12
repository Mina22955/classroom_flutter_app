import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _token;
  String? _error;
  String? _pendingId;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String? get error => _error;
  String? get pendingId => _pendingId;

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

  // Legacy signup method (for backward compatibility)
  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Use the new pending user flow (with default plan)
      final response = await _apiService.createPendingUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        planId: '68c480b976422a6a54f3fa72', // Default plan ID
      );

      if (response != null && response['pendingId'] != null) {
        _pendingId = response['pendingId'];
        await _secureStorage.write(key: 'pendingId', value: _pendingId!);
        _setLoading(false);
        return true;
      } else {
        _setError('فشل في إنشاء الحساب المؤقت');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Create pending user (new signup flow)
  Future<bool> createPendingUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String planId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('AuthProvider: Creating pending user...');
      final response = await _apiService.createPendingUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        planId: planId,
      );

      print('AuthProvider: Response received: $response');

      if (response != null && response['pendingId'] != null) {
        _pendingId = response['pendingId'];
        await _secureStorage.write(key: 'pendingId', value: _pendingId!);
        print('AuthProvider: Pending ID stored: $_pendingId');
        _setLoading(false);
        return true;
      } else {
        final errorMsg = response?['message'] ?? 'فشل في إنشاء الحساب المؤقت';
        print('AuthProvider: Error - $errorMsg');
        _setError(errorMsg);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('AuthProvider: Exception - $e');
      _setError('خطأ في الاتصال: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Get plans
  Future<List<Map<String, dynamic>>> getPlans() async {
    try {
      final plans = await _apiService.getPlans();
      return plans.cast<Map<String, dynamic>>();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Create checkout session
  Future<String?> createCheckoutSession(String planId) async {
    if (_pendingId == null) {
      _setError('معرف المستخدم المؤقت غير موجود');
      return null;
    }

    try {
      return await _apiService.createCheckoutSession(
        pendingId: _pendingId!,
        planId: planId,
      );
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Check signup status
  Future<bool> checkSignupStatus() async {
    if (_pendingId == null) {
      _setError('معرف المستخدم المؤقت غير موجود');
      return false;
    }

    try {
      final response = await _apiService.checkSignupStatus(_pendingId!);
      if (response != null && response['activated'] == true) {
        // User is activated, clear pending ID and redirect to login
        await _secureStorage.delete(key: 'pendingId');
        _pendingId = null;
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Load pending ID from storage
  Future<void> loadPendingId() async {
    _pendingId = await _secureStorage.read(key: 'pendingId');
    notifyListeners();
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

  // Update Profile (mock local update)
  Future<void> updateProfile({
    String? name,
    String? phone,
  }) async {
    // In real app, call _apiService.updateProfile and await response
    _user = {
      ...?_user,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
    };
    notifyListeners();
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
