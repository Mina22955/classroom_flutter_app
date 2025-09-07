import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.requestPasswordReset(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      // Navigate to OTP screen with email parameter
      context.go(
          '/otp?email=${Uri.encodeComponent(_emailController.text.trim())}');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'فشل في إرسال رمز التحقق'),
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
          loadingText: 'جاري إرسال رمز التحقق...',
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.go('/login'),
              ),
              title: const Text('نسيت كلمة المرور'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // Icon
                      const Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Color(0xFF0A84FF),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      const Text(
                        'إعادة تعيين كلمة المرور',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Description
                      const Text(
                        'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق لإعادة تعيين كلمة المرور',
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
                      const SizedBox(height: 32),
                      // Send Button
                      CustomButton(
                        text: 'إرسال رمز التحقق',
                        onPressed: _handleRequestReset,
                        isLoading: authProvider.isLoading,
                      ),
                      const SizedBox(height: 24),
                      // Back to Login
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'العودة لتسجيل الدخول',
                          style: TextStyle(
                            color: Color(0xFF0A84FF),
                            fontSize: 16,
                          ),
                        ),
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
