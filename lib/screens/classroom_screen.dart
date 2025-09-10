import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/note_card.dart';
import '../services/api_service.dart';

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
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _videos = [];
  bool _isLoadingVideos = false;

  // Track expansion state for video and exam cards
  final Map<String, bool> _expandedStates = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _isLoadingVideos = true);
    try {
      final videos = await _apiService.listVideos(classId: widget.classId);
      setState(() => _videos = videos);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoadingVideos = false);
    }
  }

  // Build filtered items for current section based on the search query
  Widget _buildCurrentSectionList() {
    final String q = _searchController.text.trim();

    List<Map<String, dynamic>> items;
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
      // الفيديوهات: استخدام البيانات من API
      if (_isLoadingVideos) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF0A84FF)),
        );
      }
      items = _videos
          .map((video) => {
                'id': video['id'],
                'title': video['title'],
                'content':
                    'مدة الفيديو: ${_formatDuration(video['durationSec'] ?? 0)}',
                'url': video['url'],
              })
          .toList();
    } else {
      // الامتحانات: كل عنصر يحتوي أيضاً على اسم ملف PDF افتراضي وموعد نهائي
      items = List.generate(
        3,
        (i) => {
          'title': 'امتحان الوحدة ${i + 1}',
          'content': 'تعليمات عامة ووقت الامتحان (بيانات افتراضية).',
          'pdf': 'exam_unit_${i + 1}.pdf',
          'deadline': '2025-12-${(20 + i).toString().padLeft(2, '0')}',
        },
      );
    }

    if (q.isNotEmpty) {
      items = items
          .where((m) =>
              m['title']!.contains(q) ||
              m['content']!.contains(q) ||
              (m['deadline'] ?? '').toString().contains(q))
          .toList();
    }

    // Render lists per section
    if (_currentIndex == 0 || _currentIndex == 1) {
      // Notes / Files use the same NoteCard look for now
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

    // Videos: expandable cards with video player
    if (_currentIndex == 2) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final video = items[index];
            return _buildVideoCard(video);
          },
        ),
      );
    }

    // Exams: expandable cards showing teacher PDF and a submit button
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final exam = items[index];
          final examKey = 'exam_${exam['title']}';
          final isExpanded = _expandedStates[examKey] ?? false;

          return Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.white10,
              hoverColor: Colors.white10,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
                border: isExpanded
                    ? Border.all(
                        color: const Color(0xFF0A84FF),
                        width: 2,
                      )
                    : Border.all(
                        color: Colors.white.withOpacity(0.08), width: 1),
                gradient: isExpanded
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF4FC3F7).withOpacity(0.1),
                          const Color(0xFF0A84FF).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: ExpansionTile(
                collapsedIconColor: const Color(0xFF0A84FF),
                iconColor: const Color(0xFF0A84FF),
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedStates[examKey] = expanded;
                  });
                },
                title: ShaderMask(
                  shaderCallback: (bounds) => isExpanded
                      ? const LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFF0A84FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds)
                      : const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ).createShader(bounds),
                  child: Text(
                    exam['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam['content']!,
                        style: const TextStyle(
                            color: Color(0xFFB0B0B0), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: Color(0xFF0A84FF)),
                          const SizedBox(width: 6),
                          Text(
                            'آخر موعد: ${exam['deadline']}',
                            style: const TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                children: [
                  // Teacher uploaded PDF (display only)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Color(0xFFE74C3C)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            exam['pdf']!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4FC3F7), Color(0xFF0A84FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PDF',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Submit exam button (student action)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 42,
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: Implement file picker & upload logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('سيتم دعم تسليم الاختبار قريباً')),
                          );
                        },
                        icon: const Icon(Icons.add, color: Color(0xFF0A84FF)),
                        label: const Text(
                          'تسليم الاختبار',
                          style: TextStyle(
                            color: Color(0xFF0A84FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0A84FF),
                          side: const BorderSide(
                              color: Color(0xFF0A84FF), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitles = ['الملاحظات', 'الملفات', 'الفيديوهات', 'الامتحانات'];

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
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: const Color(0xFF0A84FF),
            ),
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
          // Search bar (toggleable)
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
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
              onTap: (i) {
                setState(() => _currentIndex = i);
                if (i == 2) {
                  // Videos tab
                  _loadVideos();
                }
              },
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final videoKey = 'video_${video['id']}';
    final isExpanded = _expandedStates[videoKey] ?? false;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.white10,
        hoverColor: Colors.white10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: isExpanded
              ? Border.all(
                  color: const Color(0xFF0A84FF),
                  width: 2,
                )
              : Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          gradient: isExpanded
              ? LinearGradient(
                  colors: [
                    const Color(0xFF4FC3F7).withOpacity(0.1),
                    const Color(0xFF0A84FF).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFF0A84FF),
          iconColor: const Color(0xFF0A84FF),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedStates[videoKey] = expanded;
            });
          },
          title: ShaderMask(
            shaderCallback: (bounds) => isExpanded
                ? const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF0A84FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds)
                : const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ).createShader(bounds),
            child: Text(
              video['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              video['content']!,
              style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
            ),
          ),
          children: [
            // Video player container
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: Stack(
                children: [
                  // Video thumbnail/placeholder
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.video_collection,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                  // Play button overlay
                  Center(
                    child: GestureDetector(
                      onTap: () => _playVideo(video['url']!),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // Fullscreen button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _playVideoFullscreen(video['url']!),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo(String videoUrl) {
    // TODO: Implement video player
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تشغيل الفيديو: $videoUrl')),
    );
  }

  void _playVideoFullscreen(String videoUrl) {
    // TODO: Implement fullscreen video player
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تشغيل الفيديو في وضع ملء الشاشة: $videoUrl')),
    );
  }
}
