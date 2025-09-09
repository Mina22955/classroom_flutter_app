import 'package:flutter/material.dart';
import '../widgets/profile_info_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock student data
    final Map<String, dynamic> student = {
      'name': 'محمد أحمد',
      'phone': '+966500000000',
      'email': 'student@example.com',
      'active': true,
      'renewal': '2025-12-31',
    };

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: const Color(0xFF1C1C1E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileInfoRow(
                      label: 'الاسم',
                      value: student['name'],
                    ),
                    const Divider(color: Colors.white10),
                    ProfileInfoRow(
                      label: 'رقم الهاتف',
                      value: student['phone'],
                    ),
                    const Divider(color: Colors.white10),
                    ProfileInfoRow(
                      label: 'البريد الإلكتروني',
                      value: student['email'],
                    ),
                    const Divider(color: Colors.white10),
                    ProfileInfoRow(
                      label: 'الحالة',
                      value: student['active'] ? 'نشط' : 'غير نشط',
                      valueColor:
                          student['active'] ? Colors.greenAccent : Colors.red,
                      trailing: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: student['active'] ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    ProfileInfoRow(
                      label: 'تاريخ التجديد',
                      value: student['renewal'],
                      valueColor: const Color(0xFFB0B0B0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
