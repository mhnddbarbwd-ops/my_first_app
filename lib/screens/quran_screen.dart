import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();

  // بيانات الفهرس الثابتة كاملة لخدمة التنقل بدون اختصار
  final List<Map<String, dynamic>> _surahs = [
    {"name": "الفاتحة", "page": 1, "type": "مكية", "verses": 7},
    {"name": "البقرة", "page": 2, "type": "مدنية", "verses": 286},
    {"name": "آل عمران", "page": 50, "type": "مدنية", "verses": 200},
    {"name": "النساء", "page": 77, "type": "مدنية", "verses": 176},
    {"name": "المائدة", "page": 106, "type": "مدنية", "verses": 120},
    {"name": "الأنعام", "page": 128, "type": "مكية", "verses": 165},
    {"name": "الأعراف", "page": 151, "type": "مكية", "verses": 206},
    {"name": "الأنفال", "page": 177, "type": "مدنية", "verses": 75},
    {"name": "التوبة", "page": 187, "type": "مدنية", "verses": 129},
    {"name": "يونس", "page": 208, "type": "مكية", "verses": 109},
    {"name": "هود", "page": 221, "type": "مكية", "verses": 123},
    {"name": "يوسف", "page": 235, "type": "مكية", "verses": 111},
    {"name": "الرعد", "page": 249, "type": "مدنية", "verses": 43},
    {"name": "إبراهيم", "page": 255, "type": "مكية", "verses": 52},
    {"name": "الحجر", "page": 262, "type": "مكية", "verses": 99},
    {"name": "النحل", "page": 267, "type": "مكية", "verses": 128},
    {"name": "الإسراء", "page": 282, "type": "مكية", "verses": 111},
    {"name": "الكهف", "page": 293, "type": "مكية", "verses": 110},
  ];

  void _navigateToPage(int pageNum) {
    setState(() {
      _currentPage = pageNum;
    });
    Navigator.pop(context); // إغلاق الدرج الجانبي
  }

  void _showAyahTafsir() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.45,
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تفسير الآية المحددة',
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'سيتم عرض نص التفسير والبيان التفصيلي للآية المحددة من خلال الربط المباشر مع قاعدة بيانات المصحف الشريف المرفقة بالمكتبة قريباً.',
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, height: 1.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'المصحف الشريف',
          style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_rounded),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildQuranDrawer(colorScheme),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(colorScheme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: PageviewQuran(
                    initialPageNumber: _currentPage,
                  ),
                ),
              ),
              const SizedBox(height: 80), // مساحة للشريط العائم السفلي
            ],
          ),
          _buildFloatingControlBar(colorScheme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن سورة، آية، أو جزء...',
            hintStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: colorScheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingControlBar(ColorScheme colorScheme) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: colorScheme.primary),
              onPressed: () {
                if (_currentPage < 604) {
                  setState(() => _currentPage++);
                }
              },
            ),
            GestureDetector(
              onTap: _showAyahTafsir,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'الصفحة $_currentPage',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.primary),
              onPressed: () {
                if (_currentPage > 1) {
                  setState(() => _currentPage--);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranDrawer(ColorScheme colorScheme) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'فهرس السور الكريمة',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _surahs.length,
                itemBuilder: (context, index) {
                  final surah = _surahs[index];
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      surah['name'],
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('${surah['type']} - ${surah['verses']} آية'),
                    trailing: Text(
                      'ص ${surah['page']}',
                      style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _navigateToPage(surah['page']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
