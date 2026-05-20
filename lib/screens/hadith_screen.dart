import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  // كتابة الأحاديث الأولى من الأربعين النووية بنصوصها الكاملة التامة دون اختزال
  final List<Map<String, String>> _hadiths = [
    {
      "id": "1",
      "title": "الحديث الأول: إنما الأعمال بالنيات",
      "text": "عَنْ أَمِيرِ الْمُؤْمِنِينَ أَبِي حَفْصٍ عُمَرَ بْنِ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُ قَالَ: سَمِعْتُ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقُولُ: «إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ لِدُنْيَا يُصِيبُهَا أَوْ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ».",
      "narrator": "رواه أمير المؤمنين عمر بن الخطاب رضي الله عنه",
      "source": "صحيح البخاري وصحيح مسلم",
      "grade": "متفق عليه",
      "sharh": "هذا الحديث عظيم النفع وقاعده من قواعد الإسلام العريضة، قال عنه الشافعي: يدخل في سبعين باباً من الفقه. وفيه وجوب إخلاص النية لله سبحانه وتعالى في جميع العبادات الظاهرة والباطنة وتبيان أن الثواب والقبول منوطان تماماً بالنية الصادقة المخلصة."
    },
    {
      "id": "2",
      "title": "الحديث الثاني: مراتب الدين (الإسلام، الإيمان، الإحسان)",
      "text": "عَنْ عُمَرَ رَضِيَ اللَّهُ عَنْهُ أَيْضًا قَالَ: «بَيْنَمَا نَحْنُ جُلُوسٌ عِنْدَ رَسُولِ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ ذَاتَ يَوْمٍ، إِذْ طَلَعَ عَلَيْنَا رَجُلٌ شَدِيدُ بَيَاضِ الثِّيَابِ، شَدِيدُ سَوَادِ الشَّعَرِ، لَا يُرَى عَلَيْهِ أَثَرُ السَّفَرِ، وَلَا يَعْرِفُهُ مِنَّا أَحَدٌ، حَتَّى جَلَسَ إِلَى النَّبِيِّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، فَأَسْنَدَ رُكْبَتَيْهِ إِلَى رُكْبَتَيْهِ، وَوَضَعَ كَفَّيْهِ عَلَى فَخِذَيْهِ، وَقَالَ: يَا مُحَمَّدُ أَخْبِرْنِي عَنِ الْإِسْلَامِ، فَقَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: الْإِسْلَامُ أَنْ تَشْهَدَ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَتُقِيمَ الصَّلَاةَ، وَتُؤْتِيَ الزَّكَاةَ، وَتَصُومَ رَمَضَانَ، وَتَحُجَّ الْبَيْتَ إِنِ اسْتَطَعْتَ إِلَيْهِ سَبِيلًا. قَالَ: صَدَقْتَ. فَعَجِبْنَا لَهُ يَسْأَلُهُ وَيُصَدِّقُهُ! قَالَ: فَأَخْبِرْنِي عَنِ الْإِيمَانِ، قَالَ: أَنْ تُؤْمِنَ بِاللَّهِ، وَمَلَائِكَتِهِ، وَكُتُبِهِ، وَرُسُلِهِ، وَالْيَوْمِ الْآخِرِ، وَتُؤْمِنَ بِالْقَدَرِ خَيْرِهِ وَشَرِّهِ. قَالَ: صَدَقْتَ. قَالَ: فَأَخْبِرْنِي عَنِ الْإِحْسَانِ، قَالَ: أَنْ تَعْبُدَ اللَّهَ كَأَنَّكَ تَرَاهُ، فَإِنْ لَمْ تَكُنْ تَرَاهُ فَإِنَّهُ يَرَاكَ. قَالَ: فَأَخْبِرْنِي عَنِ السَّاعَةِ، قَالَ: مَا الْمَسْؤُولُ عَنْهَا بِأَعْلَمَ مِنَ السَّائِلِ. قَالَ: فَأَخْبِرْنِي عَنْ أَمَارَاتِهَا، قَالَ: أَنْ تَلِدَ الْأَمَةُ رَبَّتَهَا، وَأَنْ تَرَى الْحُفَاةَ الْعُرَاةَ الْعَالَةَ رِعَاءَ الشَّاءِ يَتَطَاوَلُونَ فِي الْبُنْيَانِ. ثُمَّ انْطَلَقَ فَلَبِثْتُ مَلِيًّا، ثُمَّ قَالَ: يَا عُمَرُ أَتَدْرِي مَنِ السَّائِلُ؟ قُلْتُ: اللَّهُ وَرَسُولُهُ أَعْلَمُ. قَالَ: فَإِنَّهُ جِبْرِيلُ أَتَاكُمْ يُعَلِّمُكُمْ دِينَكُمْ».",
      "narrator": "رواه عمر بن الخطاب رضي الله عنه",
      "source": "صحيح مسلم",
      "grade": "صحيح",
      "sharh": "يُعرف هذا بحديث أم السنة، لاشتماله على مجمل أحكام الدين عقيدةً وعملاً ومراقبة ظاهرية وباطنية، وتأسيس قواعد الإسلام الخمس وأركان الإيمان الستة ومفهوم الإحسان المطلق."
    },
    {
      "id": "3",
      "title": "الحديث الثالث: أركان الإسلام الخمسة",
      "text": "عَنْ أَبِي عَبْدِ الرَّحْمَنِ عَبْدِ اللَّهِ بْنِ عُمَرَ بْنِ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُمَا قَالَ: سَمِعْت رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقُولُ: «بُنِيَ الْإِسْلَامُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلَاةِ، وَإِيتَاءِ الزَّكَاةِ، وَحَجِّ الْبَيْتِ، وَصَوْمِ رَمَضَانَ».",
      "narrator": "رواه عبد الله بن عمر رضي الله عنهما",
      "source": "رواه البخاري ومسلم",
      "grade": "متفق عليه",
      "sharh": "يشير الحديث إلى تمثيل الإسلام بالبناء العظيم المستند على هذه الدعائم الأساسية التي لا يقوم كيان الإسلام بدونها في معتقد الفرد الموحد."
    }
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('الأربعين النووية كاملة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _hadiths.length,
        itemBuilder: (ctx, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.bookmark_added_rounded, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h['title']!,
                      style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.primary),
                    ),
                    Text(h['narrator']!, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
          Text(
            h['text']!,
            style: GoogleFonts.amiri(fontSize: 19, height: 2.0, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المصدر: ${h['source']!}', style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
              ElevatedButton.icon(
                onPressed: () => _showHadithDetail(h, colorScheme),
                icon: const Icon(Icons.read_more_rounded, size: 16),
                label: Text('الشرح الفقهي والبيان', style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary.withOpacity(0.12),
                  foregroundColor: colorScheme.secondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHadithDetail(Map<String, String> h, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الفوائد المستنبطة والشرح العام', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.primary)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        h['sharh']!,
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, height: 1.8, color: colorScheme.onSurface.withOpacity(0.8)),
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
