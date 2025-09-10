import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String studentName;
  final bool isSubscribed;
  final String renewalDate;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.studentName,
    required this.isSubscribed,
    required this.renewalDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          color: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Base multi-stop gradient to enhance gradation
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2A2A2E),
                          Color(0xFF242428),
                          Color(0xFF1F1F23),
                          Color(0xFF1A1A1E),
                        ],
                        stops: [0.0, 0.38, 0.72, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Subtle overlay to create melting/soft blend
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                              Colors.black.withOpacity(0.13),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // diagonal soft band (mimics melting/gradation streak)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-0.8, -0.2),
                            end: Alignment(0.6, 1.0),
                            colors: [
                              Colors.white.withOpacity(0.025),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFFFFFFF).withOpacity(0.07),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Status at top-left
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSubscribed ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSubscribed ? 'نشط' : 'غير مفعل',
                          style: TextStyle(
                            color: isSubscribed
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const SizedBox(height: 4),
                              Text(
                                'تجديد: $renewalDate',
                                style: const TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow removed per request
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
