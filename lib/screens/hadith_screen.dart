import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final List<Map<String, String>> _hadiths = [
    {"id": "1", "text": "إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى...", "narrator": "عمر بن الخطاب رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "معنى الحديث: أن قبول الأعمال وصحتها مرتبط بالنية الخالصة لله عز وجل، وهي معيار العدالة الباطنة لعمل العبد."},
    {"id": "2", "text": "بينما نحن جلوس عند رسول الله صلى الله عليه وسلم ذات يوم إذ طلع علينا رجل شديد بياض الثياب...", "narrator": "عمر بن الخطاب رضي الله عنه", "source": "مسلم", "grade": "صحيح", "sharh": "قصة جبريل عليه السلام عندما جاء في هيئة رجل ليعلم المسلمين أركان ودعائم دينهم الثلاثة: الإسلام، الإيمان، والإحسان."},
    {"id": "3", "text": "بني الإسلام على خمس: شهادة أن لا إله إلا الله وأن محمداً رسول الله...", "narrator": "عبد الله بن عمر رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "هذه الأركان الخمسة العظيمة هي الهيكل الأساسي والمبنى الذي يقوم عليه دين الإسلام الحنيف وعقيدة المسلم وبدونها يختل إسلامه."},
    {"id": "4", "text": "إن أحدكم يجمع خلقه في بطن أمه أربعين يوماً نطفة ثُمَّ يَكُونُ عَلَقَةً مِثْلَ ذَلِكَ...", "narrator": "عبد الله بن مسعود رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "يوضح الحديث مراحل أطوار خلق الإنسان في الرحم وتقدير رزقه وعمله وأجله وشقاوته أو سعادته وكتابة الملَك بأمر الله."},
    {"id": "5", "text": "من أحدث في أمرنا هذا ما ليس منه فهو رد", "narrator": "عائشة رضي الله عنها", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "التحذير والنهي الصريح من البدع والمحدثات في الدين والعبادات التي تخالف نهج النبي صلى الله عليه وسلم وأصحابه."},
    {"id": "6", "text": "الحلال بين والحرام بين وبينهما مشبهات لا يعلمهن كثير من الناس...", "narrator": "النعمان بن بشير رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "الحث البالغ على الورع والابتعاد عن مواطن الشبهات صيانة وتحصيناً للدين والعرض خوفاً من الوقوع في المعاصي والمحرمات."},
    {"id": "7", "text": "الدين النصيحة، قلنا: لمن يا رسول الله؟ قال: لله ولكتابه ولرسوله ولأئمة المسلمين وعامتهم.", "narrator": "تميم الداري رضي الله عنه", "source": "مسلم", "grade": "صحيح", "sharh": "بيان عظم منزلة النصح والائتمار بالخير للمجتمع والقيادات وعامة الأمة وبأن الدين كله قائم على هذا المفهوم السامي للتعاون."},
    {"id": "8", "text": "أمرت أن أقاتل الناس حتى يشهدوا أن لا إله إلا الله وأن محمداً رسول الله ويقيموا الصلاة...", "narrator": "عبد الله بن عمر رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "صيانة وحرمة دماء المسلمين وأموالهم وأعراضهم متى ما أظهروا شعائر التوحيد والالتزام بأركان وشروط الملة الحنيفية العادلة."},
    {"id": "9", "text": "ما نهيتكم عنه فاجتنبوه، وما أمرتكم به فأتوا منه ما استطعتم فإنما أهلك الذين من قبلكم كثرة مسائلهِم...", "narrator": "أبو هريرة رضي الله عنه", "source": "البخاري ومسلم", "grade": "صحيح", "sharh": "تأسيس قاعدة التيسير الكبرى في التكليف والعبادات بحسب طاقة وقدرة المكلف والتحذير من التنطع والكثرة في الأسئلة الجدلية غير المفيدة."},
    {"id": "10", "text": "إن الله تعالى طيب لا يقبل إلا طيباً، وإن الله أمر المؤمنين بما أمر به المرسلين...", "narrator": "أبو هريرة رضي الله عنه", "source": "مسلم", "grade": "صحيح", "sharh": "الحث الشديد على طلب الكسب والرزق الحلال والابتعاد عن أكل الحرام؛ إذ أن أكل مال الحرام يمنع استجابة الدعاء من رب العباد."},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الحديث الشريف',
          style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _hadiths.length,
        itemBuilder: (ctx, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildHadithCard(_hadiths[i], colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildHadithCard(Map<String, String> h, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book_rounded, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h['narrator']!,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'المصدر: ${h['source']!}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  h['grade']!,
                  style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
            h['text']!,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () => _showDetail(h, colorScheme),
              icon: const Icon(Icons.menu_book_sharp, size: 16),
              label: Text(
                'عرض الشرح والتفصيل',
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                foregroundColor: colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Map<String, String> h, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'متن الحديث الشريف',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        h['text']!,
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, height: 1.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'الشرح والبيان والفوائد المستنبطة',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        h['sharh']!,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 15,
                          height: 1.8,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
