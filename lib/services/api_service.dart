import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'https://class-room-backend-nodejs.vercel.app';

  // Mock delay to simulate network requests
  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل في تسجيل الدخول: ${response.body}');
    }
  }

  // Create pending user (new signup flow)
  Future<Map<String, dynamic>?> createPendingUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String planId,
  }) async {
    try {
      print('Creating pending user with email: $email');
      print('API URL: $baseUrl/api/auth/pending');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/pending'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'planId': planId,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // contains pendingId
      } else {
        print(
            'Error creating pending user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception creating pending user: $e');
      return null;
    }
  }

  // Get available plans
  Future<List<dynamic>> getPlans() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/plans/'));
      print('Plans API Response Status: ${response.statusCode}');
      print('Plans API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The API returns { "plans": [...] }, so we need to extract the plans array
        if (data is Map<String, dynamic> && data.containsKey('plans')) {
          return data['plans'] as List<dynamic>;
        } else if (data is List) {
          return data;
        }
      }
      print('Error: Invalid response format or status code');
      return [];
    } catch (e) {
      print('Error fetching plans: $e');
      return [];
    }
  }

  // Create Stripe checkout session
  Future<String?> createCheckoutSession({
    required String pendingId,
    required String planId,
  }) async {
    try {
      print(
          'Creating checkout session with pendingId: $pendingId, planId: $planId');
      print('API URL: $baseUrl/api/payment/create-checkout-session');

      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/create-checkout-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pendingId': pendingId, 'planId': planId}),
      );

      print('Checkout session response status: ${response.statusCode}');
      print('Checkout session response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url']; // Stripe checkout URL
      } else {
        print(
            'Error creating checkout session: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception creating checkout session: $e');
      return null;
    }
  }

  // Check signup status
  Future<Map<String, dynamic>?> checkSignupStatus(String pendingId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/status/$pendingId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.body}');
      return null;
    }
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

  // Legacy getPlans method (keeping for backward compatibility)
  Future<List<Map<String, dynamic>>> getPlansLegacy() async {
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

  // ---------------- Dashboard Integration Stubs ----------------
  // These methods model how the app will talk to the teacher dashboard
  // in the future. They currently return mocked responses.

  // Content models
  Future<List<Map<String, dynamic>>> listNotes(
      {required String classId}) async {
    await _mockDelay();
    return [
      {
        'id': 'n1',
        'title': 'ملاحظة عامة',
        'content': 'يرجى مراجعة ملخص الدرس الأول',
        'createdAt': DateTime.now().toIso8601String(),
      }
    ];
  }

  Future<List<Map<String, dynamic>>> listVideos(
      {required String classId}) async {
    await _mockDelay();
    return [
      {
        'id': 'v1',
        'title': 'شرح الوحدة الأولى - الرياضيات',
        'url': 'https://example.com/video1.mp4',
        'durationSec': 1245, // 20:45
      },
      {
        'id': 'v2',
        'title': 'شرح الوحدة الثانية - الفيزياء',
        'url': 'https://example.com/video2.mp4',
        'durationSec': 900, // 15:00
      },
      {
        'id': 'v3',
        'title': 'مراجعة شاملة للفصل الأول',
        'url': 'https://example.com/video3.mp4',
        'durationSec': 1800, // 30:00
      },
      {
        'id': 'v4',
        'title': 'حل التمارين العملية',
        'url': 'https://example.com/video4.mp4',
        'durationSec': 720, // 12:00
      },
      {
        'id': 'v5',
        'title': 'شرح النظريات الأساسية',
        'url': 'https://example.com/video5.mp4',
        'durationSec': 1080, // 18:00
      },
    ];
  }

  Future<List<Map<String, dynamic>>> listExams(
      {required String classId}) async {
    await _mockDelay();
    return [
      {
        'id': 'e1',
        'title': 'امتحان الوحدة 1',
        'pdfUrl': 'https://example.com/exams/e1.pdf',
        'deadline': '2025-12-20',
      }
    ];
  }

  // Upload endpoints (teacher)
  Future<Map<String, dynamic>> uploadPdf({
    required String classId,
    required String filePath,
    required String title,
  }) async {
    await _mockDelay();
    return {
      'success': true,
      'id': 'pdf_${DateTime.now().millisecondsSinceEpoch}',
      'url':
          'https://example.com/pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf',
    };
  }

  Future<Map<String, dynamic>> createExam({
    required String classId,
    required String title,
    required String pdfUrl,
    required String deadline,
  }) async {
    await _mockDelay();
    return {
      'success': true,
      'id': 'e_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Student submission
  Future<Map<String, dynamic>> submitExam({
    required String classId,
    required String examId,
    required String filePath,
  }) async {
    await _mockDelay();
    return {
      'success': true,
      'submissionId': 's_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'received',
    };
  }
}
