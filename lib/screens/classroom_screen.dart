import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  // Default section: ملاحظات
  int _currentIndex = 0;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build filtered items for current section based on the search query
  Widget _buildCurrentSectionList() {
    final String q = _searchController.text.trim();

    List<Map<String, String>> items;
    if (_currentIndex == 0) {
      // الملاحظات (حائط ملاحظات - قراءة فقط)
      items = [
        {
          'title': 'ملاحظة من المعلم',
          'content': 'أحسنتم في واجب الدرس الماضي. الرجاء مراجعة سؤال 3 جيداً.'
        },
        {
          'title': 'تنبيه',
          'content':
              'سيتم إجراء اختبار قصير في الحصة القادمة على الوحدة الأولى.'
        },
        {
          'title': 'مراجعة',
          'content': 'اقرأ الملخص المرفق في الملفات قبل مشاهدة الفيديو التالي.'
        },
      ];
    } else if (_currentIndex == 1) {
      // الملفات
      items = List.generate(
          6,
          (i) => {
                'title': 'ملف رقم ${i + 1}',
                'content': 'تفاصيل الملف والوصف المختصر.',
              });
    } else if (_currentIndex == 2) {
      // الفيديوهات
      items = List.generate(
          5,
          (i) => {
                'title': 'فيديو ${i + 1}',
                'content': 'شرح الدرس وملاحظات مرتبطة بالفيديو.',
              });
    } else {
      // الامتحانات
      items = List.generate(
          3,
          (i) => {
                'title': 'امتحان الوحدة ${i + 1}',
                'content': 'تعليمات عامة ووقت الامتحان (بيانات افتراضية).',
              });
    }

    if (q.isNotEmpty) {
      items = items
          .where((m) => m['title']!.contains(q) || m['content']!.contains(q))
          .toList();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => NoteCard(
          title: items[index]['title']!,
          content: items[index]['content']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionsTitleOnly = [
      'الملاحظات',
      'الملفات',
      'الفيديوهات',
      'الامتحانات'
    ];
    final sectionTitles = ['الملاحظات', 'الملفات', 'الفيديوهات', 'الامتحانات'];
    final sectionIcons = [
      Icons.sticky_note_2,
      Icons.folder,
      Icons.video_collection,
      Icons.assignment
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0A84FF)),
          onPressed: () => context.pop(),
        ),
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            widget.className,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0A84FF)),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Section indicator
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(4, (index) {
                      final isSelected = _currentIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _currentIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0A84FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  sectionIcons[index],
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFB0B0B0),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  sectionTitles[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFFB0B0B0),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          // Search bar (toggleable)
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'ابحث في ${sectionTitles[_currentIndex]}...',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF0A84FF)),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide:
                          BorderSide(color: Color(0xFF0A84FF), width: 1.2),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide:
                          BorderSide(color: Color(0xFF0A84FF), width: 1.5),
                    ),
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ),
          if (_showSearch) const SizedBox(height: 8),
          // Content
          Expanded(child: _buildCurrentSectionList()),
        ],
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            border: Border(
              top: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF0A84FF),
              unselectedItemColor: const Color(0xFFB0B0B0),
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.sticky_note_2_outlined),
                  activeIcon: Icon(Icons.sticky_note_2),
                  label: 'الملاحظات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_outlined),
                  activeIcon: Icon(Icons.folder),
                  label: 'الملفات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_collection_outlined),
                  activeIcon: Icon(Icons.video_collection),
                  label: 'الفيديوهات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
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
