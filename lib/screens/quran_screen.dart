import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _currentSurahIndex = 0; // السورة الحالية المعروضة بالمصحف

  // قاعدة بيانات تجريبية ضخمة تحاكي الفهرس والآيات لتشغيل البحث بكفاءة
  final List<Map<String, dynamic>> _surahList = [
    {"id": 1, "name": "الفاتحة", "type": "مكية", "verses": 7, "text": "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ (1) الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (2) الرَّحْمَنِ الرَّحِيمِ (3) مَالِكِ يَوْمِ الدِّينِ (4) إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (5) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (6) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ (7)"},
    {"id": 2, "name": "البقرة", "type": "مدنية", "verses": 286, "text": "الم (1) ذَلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ (2) الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ (3)..."},
    {"id": 3, "name": "آل عمران", "type": "مدنية", "verses": 200, "text": "الم (1) اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ (2) نَزَّلَ عَلَيْكَ الْكِتَابَ بِالْحَقِّ مُصَدِّقًا لِّمَا بَيْنَ يَدَيْهِ..."},
    {"id": 4, "name": "النساء", "type": "مدنية", "verses": 176, "text": "يَا أَيُّهَا النَّاسُ اتَّقُوا رَبَّكُمُ الَّذِي خَلَقَكُم مِّن نَّفْسٍ وَاحِدَةٍ وَخَلَقَ مِنْهَا زَوْجَهَا..."},
    {"id": 112, "name": "الإخلاص", "type": "مكية", "verses": 4, "text": "قُلْ هُوَ اللَّهُ أَحَدٌ (1) اللَّهُ الصَّمَدُ (2) لَمْ يَلِدْ وَلَمْ يُولَدْ (3) وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ (4)"},
    {"id": 113, "name": "الفلق", "type": "مكية", "verses": 5, "text": "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ (1) مِن شَرِّ مَا خَلَقَ (2) وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ (3) وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ (4) وَمِن شَرِّ حَاسِدٍ إِذَا حَسَد(5)"},
    {"id": 114, "name": "الناس", "type": "مكية", "verses": 6, "text": "قُلْ أَعُوذُ بِرَبِّ النَّاسِ (1) مَلِكِ النَّاسِ (2) إِلَٰهِ النَّاسِ (3) مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ (4) الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ (5) مِنَ الْجِنَّةِ وَالنَّاسِ (6)"}
  ];

  String _surahQuery = '';
  String _ayahQuery = '';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  // دوال التنقل بين السور (أزرار اليمين واليسار)
  void _nextSurah() {
    if (_currentSurahIndex < _surahList.length - 1) {
      setState(() {
        _currentSurahIndex++;
      });
    }
  }

  void _previousSurah() {
    if (_currentSurahIndex > 0) {
      setState(() {
        _currentSurahIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('القرآن الكريم', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
          tabs: [
            Tab(child: Text('المصحف القارئ', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold))),
            Tab(child: Text('الفهرس والبحث', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _buildMushafView(colorScheme),
          _buildIndexAndSearchView(colorScheme),
        ],
      ),
    );
  }

  // 1. واجهة قراءة المصحف مع أزرار التنقل الفعالة
  Widget _buildMushafView(ColorScheme colorScheme) {
    final surah = _surahList[_currentSurahIndex];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          color: colorScheme.primary.withOpacity(0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: _currentSurahIndex == 0 ? null : _previousSurah,
                tooltip: 'السورة السابقة',
              ),
              Column(
                children: [
                  Text(
                    'سورة ${surah['name']}',
                    style: GoogleFonts.ibmPlexSansArabic(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  Text(
                    '${surah['type']} • آياتها ${surah['verses']}',
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: _currentSurahIndex == _surahList.length - 1 ? null : _nextSurah,
                tooltip: 'السورة التالية',
              ),
            ],
          ),
        ),
        if (surah['name'] != 'الفاتحة')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.secondary),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
              ),
              child: Text(
                surah['text'],
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(fontSize: 22, height: 2.2, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. واجهة البحث الثنائي والفهرس الكامل
  Widget _buildIndexAndSearchView(ColorScheme colorScheme) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: colorScheme.surface,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: colorScheme.secondary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
              tabs: [
                Tab(child: Text('البحث بالسورة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.bold))),
                Tab(child: Text('البحث بالآيات', style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSurahSearchTab(colorScheme),
                _buildAyahSearchTab(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // تبويب البحث والفهرس للسور
  Widget _buildSurahSearchTab(ColorScheme colorScheme) {
    final filteredSurahs = _surahList.where((s) => s['name'].toString().contains(_surahQuery)).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _surahQuery = val),
            decoration: InputDecoration(
              hintText: 'ابحث عن اسم السورة...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSurahs.length,
            itemBuilder: (ctx, idx) {
              final s = filteredSurahs[idx];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  child: Text('${s['id']}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text('سورة ${s['name']}', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
                subtitle: Text('${s['type']} • آياتها ${s['verses']}'),
                trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                onTap: () {
                  setState(() {
                    _currentSurahIndex = _surahList.indexWhere((element) => element['id'] == s['id']);
                  });
                  _mainTabController.animateTo(0); // العودة التلقائية لعلامة تبويب المصحف
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // تبويب البحث داخل نصوص الآيات
  Widget _buildAyahSearchTab(ColorScheme colorScheme) {
    final filteredAyahs = _surahList.where((s) => s['text'].toString().contains(_ayahQuery)).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _ayahQuery = val),
            decoration: InputDecoration(
              hintText: 'اكتب كلمة أو نصاً من الآية للبحث عنها...',
              prefixIcon: const Icon(Icons.find_in_page_rounded),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _ayahQuery.isEmpty
              ? Center(child: Text('ابدأ بكتابة كلمات الآية المُراد البحث عنها', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))))
              : ListView.builder(
                  itemCount: filteredAyahs.length,
                  itemBuilder: (ctx, idx) {
                    final s = filteredAyahs[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text('وجدت في سورة: ${s['name']}', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(s['text'], maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.amiri(fontSize: 16)),
                        ),
                        onTap: () {
                          setState(() {
                            _currentSurahIndex = _surahList.indexWhere((element) => element['id'] == s['id']);
                          });
                          _mainTabController.animateTo(0);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
