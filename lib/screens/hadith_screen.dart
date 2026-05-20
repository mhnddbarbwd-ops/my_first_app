import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final List<Map<String, String>> _hadiths = [
    {"id": "1", "text": "إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى...", "narrator": "عمر بن الخطاب رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "معنى الحديث: أن قبول الأعمال وصحتها مرتبط بالنية الخالصة لله."},
    {"id": "2", "text": "بينما نحن جلوس عند رسول الله صلى الله عليه وسلم...", "narrator": "عمر بن الخطاب رضي الله عنه", "source": "مسلم", "grade": "صحيح", "sharh": "قصة جبريل عليه السلام عندما جاء ليعلم المسلمين أمور دينهم."},
    {"id": "3", "text": "بني الإسلام على خمس: شهادة أن لا إله إلا الله...", "narrator": "عبد الله بن عمر رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "هذه الأركان الخمسة هي أساس الإسلام."},
    {"id": "4", "text": "إن أحدكم يجمع خلقه في بطن أمه أربعين يوماً نطفة...", "narrator": "عبد الله بن مسعود رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "مراحل خلق الإنسان وتقدير رزقه وعمله وهو في بطن أمه."},
    {"id": "5", "text": "من أحدث في أمرنا هذا ما ليس منه فهو رد", "narrator": "عائشة رضي الله عنها", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "التحذير من البدع في الدين."},
    {"id": "6", "text": "الحلال بين والحرام بين...", "narrator": "النعمان بن بشير رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "ضرورة الابتعاد عن الشبهات."},
    {"id": "7", "text": "الدين النصيحة...", "narrator": "تميم الداري رضي الله عنه", "source": "مسلم", "grade": "صحيح", "sharh": "النصيحة لله ولكتابه ولرسوله ولأئمة المسلمين وعامتهم."},
    {"id": "8", "text": "أمرت أن أقاتل الناس حتى يشهدوا أن لا إله إلا الله...", "narrator": "عبد الله بن عمر رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "حرمة دم المسلم وماله."},
    {"id": "9", "text": "ما نهيتكم عنه فاجتنبوه، وما أمرتكم به فأتوا منه ما استطعتم...", "narrator": "أبو هريرة رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "التيسير في التكليف."},
    {"id": "10", "text": "إن الله طيب لا يقبل إلا طيباً...", "narrator": "أبو هريرة رضي الله عنه", "source": "مسلم", "grade": "صحيح", "sharh": "الحث على الكسب الحلال."},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الأحاديث النبوية',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hadiths.length,
        itemBuilder: (ctx, i) {
          final h = _hadiths[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHadithCard(h, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildHadithCard(Map<String, String> h, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.surface.withOpacity(0.6),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(Icons.person_rounded, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h['narrator']!,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          h['source']!,
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green.withOpacity(0.1),
                    ),
                    child: Text(
                      h['grade']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                h['text']!,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 16,
                  height: 1.6,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showDetail(h, colorScheme),
                  icon: Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
                  label: Text(
                    'معنى الحديث',
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(Map<String, String> h, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.65,
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'متن الحديث',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      h['text']!,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 18,
                        height: 1.8,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'شرح الحديث',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      h['sharh']!,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 15,
                        height: 1.7,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
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