import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  final List<Map<String, dynamic>> _badges = const [
    {'title': 'قارئ مبتدئ', 'desc': 'قراءة 5 صفحات', 'icon': Icons.auto_stories_rounded, 'unlocked': true},
    {'title': 'قارئ مجتهد', 'desc': 'قراءة 50 صفحة', 'icon': Icons.menu_book_rounded, 'unlocked': true},
    {'title': 'قارئ متمكن', 'desc': 'قراءة 200 صفحة', 'icon': Icons.library_books_rounded, 'unlocked': false},
    {'title': 'المستمر', 'desc': '7 أيام متتالية', 'icon': Icons.local_fire_department_rounded, 'unlocked': true},
    {'title': 'المثابر', 'desc': '30 يوم متتالي', 'icon': Icons.whatshot_rounded, 'unlocked': false},
    {'title': 'العلامة', 'desc': 'إكمال 10 اختبارات', 'icon': Icons.school_rounded, 'unlocked': false},
    {'title': 'الحافظ', 'desc': 'ختم القرآن مرة', 'icon': Icons.emoji_events_rounded, 'unlocked': false},
    {'title': 'المتصدر', 'desc': 'المركز الأول أسبوعياً', 'icon': Icons.workspace_premium_rounded, 'unlocked': false},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('خزنة الأوسمة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, crossAxisSpacing: 14, mainAxisSpacing: 14),
        itemCount: _badges.length,
        itemBuilder: (context, index) {
          final badge = _badges[index];
          final unlocked = badge['unlocked'] as bool;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: unlocked ? colorScheme.surface : colorScheme.surface.withOpacity(0.5),
              border: Border.all(color: unlocked ? Colors.amber.withOpacity(0.4) : Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  badge['icon'],
                  size: 40,
                  color: unlocked ? Colors.amber : Colors.grey.shade400,
                ),
                const SizedBox(height: 10),
                Text(
                  badge['title'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? colorScheme.onSurface : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge['desc'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: unlocked ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey.shade400),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}