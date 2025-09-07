import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/plans');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'فشل في تسجيل الدخول'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          loadingText: 'جاري تسجيل الدخول...',
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      // Logo/Title
                      const Icon(
                        Icons.school,
                        size: 80,
                        color: Color(0xFF0A84FF),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'مرحباً بك',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'سجل دخولك للوصول إلى حسابك',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'البريد الإلكتروني',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFFB0B0B0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'البريد الإلكتروني مطلوب';
                          }
                          if (!value.contains('@')) {
                            return 'البريد الإلكتروني غير صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'كلمة المرور',
                        obscureText: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFFB0B0B0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'كلمة المرور مطلوبة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Login Button
                      CustomButton(
                        text: 'تسجيل الدخول',
                        onPressed: _handleLogin,
                        isLoading: authProvider.isLoading,
                      ),
                      const SizedBox(height: 24),
                      // Forgot Password Link
                      TextButton(
                        onPressed: () => context.go('/forget-password'),
                        child: const Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: Color(0xFF0A84FF),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ليس لديك حساب؟ ',
                            style: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/signup'),
                            child: const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                color: Color(0xFF0A84FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
