import 'package:flutter/material.dart';
import '../widgets/note_card.dart';

class ClassroomScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ClassroomScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  int _currentIndex = 0;

  List<Widget> _buildSections() {
    return [
      // الملفات
      Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => NoteCard(
            title: 'ملف رقم ${index + 1}',
            content: 'تفاصيل الملف والوصف المختصر.',
          ),
        ),
      ),
      // الفيديوهات
      Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => NoteCard(
            title: 'فيديو ${index + 1}',
            content: 'شرح الدرس وملاحظات مرتبطة بالفيديو.',
          ),
        ),
      ),
      // الامتحانات
      Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => NoteCard(
            title: 'امتحان الوحدة ${index + 1}',
            content: 'تعليمات عامة ووقت الامتحان (بيانات افتراضية).',
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(widget.className),
        ),
      ),
      body: sections[_currentIndex],
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: const Color(0xFF1C1C1E),
          child: SafeArea(
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF1C1C1E),
              selectedItemColor: const Color(0xFF0A84FF),
              unselectedItemColor: Colors.white70,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder),
                  label: 'الملفات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_collection),
                  label: 'الفيديوهات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'الامتحانات',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
