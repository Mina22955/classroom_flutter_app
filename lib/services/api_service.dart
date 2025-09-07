import 'dart:async';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Mock delay to simulate network requests
  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await _mockDelay();

    // Mock validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('جميع الحقول مطلوبة');
    }

    if (!email.contains('@')) {
      throw Exception('البريد الإلكتروني غير صحيح');
    }

    // Mock successful login
    return {
      'success': true,
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': '1',
        'name': 'مستخدم تجريبي',
        'email': email,
        'phone': '+966501234567',
      },
    };
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _mockDelay();

    // Mock validation
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      throw Exception('جميع الحقول مطلوبة');
    }

    if (!email.contains('@')) {
      throw Exception('البريد الإلكتروني غير صحيح');
    }

    if (password.length < 6) {
      throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }

    // Mock successful signup
    return {
      'success': true,
      'message': 'تم إنشاء الحساب بنجاح',
      'user': {
        'id': '1',
        'name': name,
        'email': email,
        'phone': phone,
      },
    };
  }

  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    await _mockDelay();

    if (email.isEmpty || !email.contains('@')) {
      throw Exception('البريد الإلكتروني غير صحيح');
    }

    // Mock OTP generation
    const otp = '123456';

    return {
      'success': true,
      'message': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      'otp': otp, // In real app, this would be sent via email
    };
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await _mockDelay();

    if (otp.isEmpty || otp.length != 6) {
      throw Exception('رمز التحقق غير صحيح');
    }

    // Mock OTP verification (accepts 123456)
    if (otp != '123456') {
      throw Exception('رمز التحقق غير صحيح');
    }

    return {
      'success': true,
      'message': 'تم التحقق من الرمز بنجاح',
    };
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _mockDelay();

    if (newPassword.length < 6) {
      throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }

    // Mock password reset
    return {
      'success': true,
      'message': 'تم تغيير كلمة المرور بنجاح',
    };
  }

  // Subscription Methods
  Future<List<Map<String, dynamic>>> getPlans() async {
    await _mockDelay();

    return [
      {
        'id': '1',
        'name': 'الخطة الشهرية',
        'price': 29.99,
        'currency': 'SAR',
        'duration': 'شهر',
        'features': [
          'وصول كامل للمحتوى',
          'دعم فني 24/7',
          'تحديثات مستمرة',
          'إشعارات فورية',
        ],
        'popular': false,
      },
      {
        'id': '2',
        'name': 'الخطة النصف سنوية',
        'price': 149.99,
        'currency': 'SAR',
        'duration': '6 أشهر',
        'features': [
          'وصول كامل للمحتوى',
          'دعم فني 24/7',
          'تحديثات مستمرة',
          'إشعارات فورية',
          'خصم 20%',
        ],
        'popular': true,
      },
      {
        'id': '3',
        'name': 'الخطة السنوية',
        'price': 249.99,
        'currency': 'SAR',
        'duration': 'سنة',
        'features': [
          'وصول كامل للمحتوى',
          'دعم فني 24/7',
          'تحديثات مستمرة',
          'إشعارات فورية',
          'خصم 30%',
          'ميزات حصرية',
        ],
        'popular': false,
      },
    ];
  }

  Future<Map<String, dynamic>> payWithStripe({
    required String planId,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    await _mockDelay();

    // Mock validation
    if (cardNumber.isEmpty ||
        expiryDate.isEmpty ||
        cvv.isEmpty ||
        cardholderName.isEmpty) {
      throw Exception('جميع بيانات البطاقة مطلوبة');
    }

    if (cardNumber.length < 16) {
      throw Exception('رقم البطاقة غير صحيح');
    }

    if (cvv.length < 3) {
      throw Exception('رمز الأمان غير صحيح');
    }

    // Mock successful payment
    return {
      'success': true,
      'message': 'تم الدفع بنجاح',
      'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'subscriptionId': 'sub_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Utility Methods
  Future<void> logout() async {
    await _mockDelay();
    // Mock logout - clear token, etc.
  }
}
