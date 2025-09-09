import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forget_password_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/subscription/plans_screen.dart';
import '../screens/subscription/payment_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/classroom_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoginRoute = state.uri.path == '/login';
      final isSignupRoute = state.uri.path == '/signup';
      final isForgetPasswordRoute = state.uri.path == '/forget-password';
      final isOtpRoute = state.uri.path == '/otp';
      final isResetPasswordRoute = state.uri.path == '/reset-password';
      final isPlansRoute = state.uri.path == '/plans';
      final isPaymentRoute = state.uri.path == '/payment';
      // final isHomeRoute = state.uri.path == '/home';

      // If user is authenticated and trying to access auth screens, redirect to home
      if (isAuthenticated &&
          (isLoginRoute ||
              isSignupRoute ||
              isForgetPasswordRoute ||
              isOtpRoute ||
              isResetPasswordRoute)) {
        return '/home';
      }

      // If user is authenticated and tries to access plans or payment, redirect to home
      if (isAuthenticated && (isPlansRoute || isPaymentRoute)) {
        return '/home';
      }

      // If user is not authenticated and trying to access protected routes (except plans and payment), redirect to login
      if (!isAuthenticated &&
          !isLoginRoute &&
          !isSignupRoute &&
          !isForgetPasswordRoute &&
          !isOtpRoute &&
          !isResetPasswordRoute &&
          !isPlansRoute &&
          !isPaymentRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forget-password',
        name: 'forget-password',
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final otp = state.uri.queryParameters['otp'] ?? '';
          return ResetPasswordScreen(email: email, otp: otp);
        },
      ),
      GoRoute(
        path: '/plans',
        name: 'plans',
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/classroom',
        name: 'classroom',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final classId = extra?['id']?.toString() ?? '';
          final className = extra?['name']?.toString() ?? 'الكلاس';
          return ClassroomScreen(classId: classId, className: className);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'الصفحة غير موجودة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الرابط المطلوب غير صحيح',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A84FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('العودة للصفحة الرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
}
