import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/plans');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'فشل في إنشاء الحساب'),
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
          loadingText: 'جاري إنشاء الحساب...',
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.go('/login'),
              ),
              title: const Text('إنشاء حساب جديد'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Title
                      const Text(
                        'انضم إلينا',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أنشئ حسابك للبدء في رحلتك التعليمية',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Name Field
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'اسم المستخدم',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFFB0B0B0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'اسم المستخدم مطلوب';
                          }
                          if (value.length < 2) {
                            return 'اسم المستخدم يجب أن يكون حرفين على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                      // Phone Field
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: Color(0xFFB0B0B0),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رقم الهاتف مطلوب';
                          }
                          if (value.length < 9) {
                            return 'رقم الهاتف غير صحيح';
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
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: 'تأكيد كلمة المرور',
                        obscureText: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFFB0B0B0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'تأكيد كلمة المرور مطلوب';
                          }
                          if (value != _passwordController.text) {
                            return 'كلمة المرور غير متطابقة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      // Sign Up Button
                      CustomButton(
                        text: 'إنشاء حساب',
                        onPressed: _handleSignUp,
                        isLoading: authProvider.isLoading,
                      ),
                      const SizedBox(height: 24),
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'لديك حساب بالفعل؟ ',
                            style: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(
                              'تسجيل الدخول',
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
