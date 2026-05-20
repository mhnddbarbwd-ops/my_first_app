import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> _paths = [
    {'title': 'السيرة النبوية المبكرة', 'levels': 5, 'progress': 0.6, 'icon': Icons.mosque_rounded, 'color': const Color(0xFF2E7D32)},
    {'title': 'قصص الأنبياء', 'levels': 8, 'progress': 0.2, 'icon': Icons.auto_stories_rounded, 'color': const Color(0xFF1565C0)},
    {'title': 'القرآن وعلومه', 'levels': 10, 'progress': 0.0, 'icon': Icons.menu_book_rounded, 'color': const Color(0xFFE65100)},
    {'title': 'الفقه الإسلامي', 'levels': 12, 'progress': 0.0, 'icon': Icons.gavel_rounded, 'color': const Color(0xFF6A1B9A)},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('رحلة المعرفة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _paths.length,
        itemBuilder: (context, index) {
          final path = _paths[index];
          final color = path['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: [color.withOpacity(0.1), colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(path['icon'], color: color, size: 28),
                ),
                title: Text(path['title'], style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: path['progress'] as double, minHeight: 8, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(color)),
                    ),
                    const SizedBox(height: 4),
                    Text('${path['levels']} مراحل • ${((path['progress'] as double) * 100).toInt()}%', style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, color: color),
              ),
            ),
          );
        },
      ),
    );
  }
}