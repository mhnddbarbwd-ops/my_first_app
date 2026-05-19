import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  // بيانات الأحاديث الأربعين النووية (مضمنة)
  static const List<Map<String, String>> _hadiths = [
    {
      "narrator": "عن أمير المؤمنين أبي حفص عمر بن الخطاب رضي الله عنه",
      "text": "إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى..."
    },
    {
      "narrator": "عن عمر رضي الله عنه أيضاً",
      "text": "بينما نحن جلوس عند رسول الله صلى الله عليه وسلم ذات يوم، إذ طلع علينا رجل شديد بياض الثياب..."
    },
    {
      "narrator": "عن أبي عبد الرحمن عبد الله بن عمر بن الخطاب رضي الله عنهما",
      "text": "بني الإسلام على خمس: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة..."
    },
    // ... يمكن إضافة باقي الأحاديث
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('الأحاديث', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hadiths.length,
        itemBuilder: (ctx, i) {
          final h = _hadiths[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [colorScheme.surface.withOpacity(0.5), colorScheme.surface.withOpacity(0.25)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h['narrator'] ?? '', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(h['text'] ?? '', style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, height: 1.5, color: colorScheme.onSurface)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}