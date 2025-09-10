import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/plan_card.dart';
import '../../widgets/loading_overlay.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).loadPlans();
    });
  }

  Future<void> _handleNext() async {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    if (subscriptionProvider.selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار خطة أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    // Simulate navigation delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      context.go('/payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        return LoadingOverlay(
          isLoading: subscriptionProvider.isLoading,
          loadingText: 'جاري تحميل الخطط...',
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              title: const Text('خطط الأسعار'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          const Text(
                            'اختر خطتك المناسبة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ابدأ رحلتك التعليمية معنا',
                            style: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Plans List
                          if (subscriptionProvider.plans.isEmpty &&
                              !subscriptionProvider.isLoading)
                            const Center(
                              child: Text(
                                'لا توجد خطط متاحة حالياً',
                                style: TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else
                            ...subscriptionProvider.plans
                                .map((plan) => PlanCard(
                                      plan: plan,
                                      isSelected: subscriptionProvider
                                              .selectedPlan?['id'] ==
                                          plan['id'],
                                      onTap: () {
                                        subscriptionProvider.selectPlan(plan);
                                      },
                                    ))
                                .toList(),
                          const SizedBox(height: 24),
                          // Error message
                          if (subscriptionProvider.error != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Text(
                                subscriptionProvider.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom section with next button
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Selected plan summary
                        if (subscriptionProvider.selectedPlan != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A84FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF0A84FF).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subscriptionProvider
                                          .selectedPlan!['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${subscriptionProvider.selectedPlan!['price']} ${subscriptionProvider.selectedPlan!['currency']} / ${subscriptionProvider.selectedPlan!['duration']}',
                                      style: const TextStyle(
                                        color: Color(0xFFB0B0B0),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF0A84FF),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Next button
                        CustomButton(
                          text: 'التالي',
                          onPressed: _handleNext,
                          isLoading: _isNavigating,
                          backgroundColor:
                              subscriptionProvider.selectedPlan != null
                                  ? const Color(0xFF0A84FF)
                                  : const Color(0xFF1C1C1E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
