import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    final success = await subscriptionProvider.processPayment(
      cardNumber: _cardNumberController.text.trim(),
      expiryDate: _expiryDateController.text.trim(),
      cvv: _cvvController.text.trim(),
      cardholderName: _cardholderNameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(subscriptionProvider.paymentSuccess ?? 'تم الدفع بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(subscriptionProvider.error ?? 'فشل في معالجة الدفع'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        final selectedPlan = subscriptionProvider.selectedPlan;

        if (selectedPlan == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.go('/plans'),
              ),
              title: const Text('الدفع الإلكتروني'),
            ),
            body: const Center(
              child: Text(
                'لم يتم اختيار خطة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        return LoadingOverlay(
          isLoading: subscriptionProvider.isPaymentProcessing,
          loadingText: 'جاري معالجة الدفع...',
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.go('/plans'),
              ),
              title: const Text('الدفع الإلكتروني'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Selected Plan Summary
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF0A84FF).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedPlan['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (selectedPlan['popular'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF8E44AD),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: const Text(
                                      'الأكثر شعبية',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${selectedPlan['price']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${selectedPlan['currency']}',
                                  style: const TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '/ ${selectedPlan['duration']}',
                                  style: const TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Payment Form Title
                      const Text(
                        'معلومات الدفع',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أدخل بيانات بطاقتك الائتمانية',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Card Number Field
                      CustomTextField(
                        controller: _cardNumberController,
                        hintText: 'رقم البطاقة',
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        prefixIcon: const Icon(
                          Icons.credit_card,
                          color: Color(0xFFB0B0B0),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رقم البطاقة مطلوب';
                          }
                          if (value.length < 16) {
                            return 'رقم البطاقة يجب أن يكون 16 رقم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Expiry Date and CVV Row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _expiryDateController,
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'تاريخ الانتهاء مطلوب';
                                }
                                if (value.length != 4) {
                                  return 'تاريخ الانتهاء غير صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _cvvController,
                              hintText: 'CVV',
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'CVV مطلوب';
                                }
                                if (value.length < 3) {
                                  return 'CVV غير صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Cardholder Name Field
                      CustomTextField(
                        controller: _cardholderNameController,
                        hintText: 'اسم حامل البطاقة',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFFB0B0B0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'اسم حامل البطاقة مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Mock data hint
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E44AD).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8E44AD).withOpacity(0.3),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بيانات تجريبية للاختبار:',
                              style: TextStyle(
                                color: Color(0xFF8E44AD),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'رقم البطاقة: 4242424242424242\nتاريخ الانتهاء: 12/25\nCVV: 123',
                              style: TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Pay Button
                      CustomButton(
                        text: 'إتمام الدفع',
                        onPressed: _handlePayment,
                        isLoading: subscriptionProvider.isPaymentProcessing,
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
