import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:quran/quran.dart' as quran_lib;
import 'package:nafahat/providers/user_progress_provider.dart';
import 'package:nafahat/screens/quran_challenge_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  double _fontScale = 1.0;
  List<int> _pageHistory = [1]; // لتتبع الصفحات للرجوع

  // نتائج البحث
  List<Map<String, dynamic>> _surahResults = [];
  List<Map<String, dynamic>> _ayahResults = [];
  late TabController _tabController;

  static const Map<int, int> _juzStartPages = {
    1: 1, 2: 22, 3: 42, 4: 62, 5: 82, 6: 102,
    7: 121, 8: 142, 9: 162, 10: 182, 11: 201, 12: 222,
    13: 242, 14: 262, 15: 282, 16: 302, 17: 322, 18: 342,
    19: 362, 20: 382, 21: 402, 22: 422, 23: 442, 24: 462,
    25: 482, 26: 502, 27: 522, 28: 542, 29: 562, 30: 582,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _jumpToPage(int page) {
    // إغلاق أي قائمة مفتوحة أولاً
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    setState(() {
      if (_currentPage != page) {
        _pageHistory.add(page);
        _currentPage = page;
      }
    });
  }

  void _goBack() {
    if (_pageHistory.length > 1) {
      setState(() {
        _pageHistory.removeLast();
        _currentPage = _pageHistory.last;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _surahResults = [];
        _ayahResults = [];
      });
      return;
    }

    setState(() {
      // البحث في السور
      _surahResults = [];
      for (int i = 1; i <= 114; i++) {
        final name = getSurahNameArabic(i); // من qcf_quran
        if (name.contains(query.trim())) {
          _surahResults.add({
            'number': i,
            'name': name,
            'page': getPageNumber(i, 1), // من qcf_quran
          });
        }
      }

      // البحث في الآيات (باستخدام مكتبة quran_lib)
      _ayahResults = [];
      try {
        final results = quran_lib.searchVerses(query.trim());
        for (final r in results) {
          _ayahResults.add({
            'surah': r.surahNumber,
            'verse': r.verseNumber,
            'page': getPageNumber(r.surahNumber, r.verseNumber),
            'surahName': getSurahNameArabic(r.surahNumber),
          });
        }
      } catch (_) {
        // إذا فشل البحث، نترك القائمة فارغة
      }
    });
  }

  void _showSearchDialog() {
    _searchController.clear();
    _surahResults = [];
    _ayahResults = [];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text('بحث في القرآن',
                style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.w900)),
            content: SizedBox(
              width: double.maxFinite,
              height: 450,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    onChanged: (v) {
                      _onSearchChanged(v);
                      setDialogState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'اكتب كلمة للبحث...',
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'السور'),
                      Tab(text: 'الآيات'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // تبويبة السور
                        _surahResults.isEmpty
                            ? Center(
                                child: Text('اكتب اسم سورة',
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: _surahResults.length,
                                itemBuilder: (context, i) {
                                  final s = _surahResults[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      child: Text('${s['number']}'),
                                    ),
                                    title: Text(s['name'],
                                        style: GoogleFonts.ibmPlexSansArabic(
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text('الصفحة: ${s['page']}'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _jumpToPage(s['page'] as int);
                                    },
                                  );
                                },
                              ),
                        // تبويبة الآيات
                        _ayahResults.isEmpty
                            ? Center(
                                child: Text('ابحث عن كلمة في الآيات',
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: _ayahResults.length,
                                itemBuilder: (context, i) {
                                  final a = _ayahResults[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.1),
                                      child: Text('${a['surah']}'),
                                    ),
                                    title: Text(
                                        'سورة ${a['surahName']} - آية ${a['verse']}'),
                                    subtitle: Text('الصفحة: ${a['page']}'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _jumpToPage(a['page'] as int);
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إغلاق')),
            ],
          );
        },
      ),
    );
  }

  // عند الضغط على آية (يتطلب التعامل مع حدث الضغط من المكتبة)
  void _onVerseTapped(int surah, int verse) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('تفسير الآية'),
              onTap: () {
                Navigator.pop(ctx);
                // يمكن إضافة شاشة تفسير هنا لاحقاً
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('مشاركة'),
              onTap: () {
                Navigator.pop(ctx);
                // إضافة مشاركة النص
              },
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('نسخ النص'),
              onTap: () {
                Navigator.pop(ctx);
                // نسخ نص الآية إلى الحافظة
              },
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
        title: Text('القرآن الكريم',
            style: GoogleFonts.ibmPlexSansArabic(
                fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.menu_book_rounded, color: colorScheme.primary),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            if (_pageHistory.length > 1)
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: colorScheme.primary),
                onPressed: _goBack,
                tooltip: 'رجوع للصفحة السابقة',
              ),
          ],
        ),
        actions: [
          // شريط تغيير حجم الخط
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.text_decrease, size: 18, color: colorScheme.primary),
              SizedBox(
                width: 100,
                child: Slider(
                  value: _fontScale,
                  min: 0.6,
                  max: 1.4,
                  divisions: 8,
                  activeColor: colorScheme.primary,
                  onChanged: (val) => setState(() => _fontScale = val),
                ),
              ),
              Icon(Icons.text_increase, size: 18, color: colorScheme.primary),
            ],
          ),
          IconButton(
            icon: Icon(Icons.flag_rounded, color: colorScheme.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      QuranChallengeScreen(initialPage: _currentPage)),
            ),
            tooltip: 'بدء تحدي جديد',
          ),
          IconButton(
            icon: Icon(Icons.search_rounded, color: colorScheme.primary),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(colorScheme),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: PageviewQuran(
          key: ValueKey(_currentPage),
          initialPageNumber: _currentPage,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
              _pageHistory.add(page);
            });
            Provider.of<UserProgressProvider>(context, listen: false)
                .updateReadPages(page);
          },
          // ملاحظة: دعم تكبير الخط حسب المكتبة، إذا كانت المكتبة تدعم textScaleFactor فسنمرره هنا
          // وإلا قد لا يتغير حجم الخط. يمكن تطويره لاحقاً.
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: colorScheme.primary.withOpacity(0.1)),
            child: Center(
              child: Text('فهرس المصحف',
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 114,
              itemBuilder: (context, index) {
                final surahNumber = index + 1;
                final page = getPageNumber(surahNumber, 1);
                final name = getSurahNameArabic(surahNumber);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Text('$surahNumber',
                        style: TextStyle(color: colorScheme.primary)),
                  ),
                  title: Text(name,
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.w600)),
                  subtitle: Text('الصفحة: $page'),
                  onTap: () => _jumpToPage(page),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
