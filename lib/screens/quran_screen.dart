import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quran_tajwid/flutter_quran_tajwid.dart';  // 🆕
import 'package:nafahat/providers/user_progress_provider.dart';
import 'package:nafahat/screens/quran_challenge_screen.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late TabController _searchTabController;
  int _currentPage = 1;

  List<Map<String, dynamic>> _surahResults = [];
  List<Map<String, dynamic>> _ayahResults = [];

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
    _searchTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTabController.dispose();
    super.dispose();
  }

  void _jumpToPage(int page) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() => _currentPage = page);
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
      _surahResults = [];
      for (int i = 1; i <= 114; i++) {
        final name = getSurahNameArabic(i);
        if (name.contains(query.trim())) {
          _surahResults.add({'number': i, 'name': name, 'page': getPageNumber(i, 1)});
        }
      }

      try {
        final results = searchWords(query.trim());
        if (results['result'] != null && (results['result'] as List).isNotEmpty) {
          _ayahResults = (results['result'] as List).map<Map<String, dynamic>>((r) {
            final surah = r['suraNumber'] as int;
            final verse = r['verseNumber'] as int;
            final page = getPageNumber(surah, verse);
            return {
              'surah': surah,
              'verse': verse,
              'page': page,
              'surahName': getSurahNameArabic(surah),
            };
          }).toList();
        }
      } catch (_) {
        _ayahResults = [];
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
            title: Text('بحث في القرآن', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
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
                      hintText: 'اكتب كلمة أو حرف للبحث...',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _searchTabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'السور'),
                      Tab(text: 'الآيات'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _searchTabController,
                      children: [
                        _surahResults.isEmpty
                            ? Center(child: Text('اكتب للبحث عن سورة', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: _surahResults.length,
                                itemBuilder: (context, i) {
                                  final s = _surahResults[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text('${s['number']}'),
                                    ),
                                    title: Text(s['name'], style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
                                    subtitle: Text('الصفحة: ${s['page']}'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _jumpToPage(s['page'] as int);
                                    },
                                  );
                                },
                              ),
                        _ayahResults.isEmpty
                            ? Center(child: Text('اكتب للبحث في الآيات', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: _ayahResults.length,
                                itemBuilder: (context, i) {
                                  final a = _ayahResults[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                      child: Text('${a['surah']}'),
                                    ),
                                    title: Text('سورة ${a['surahName']} - آية ${a['verse']}'),
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
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
            ],
          );
        },
      ),
    );
  }

  // 🆕 إظهار فقاعة "معلم التجويد"
  void _showTajweedBubble() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.spellcheck, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text('معلم التجويد', style: GoogleFonts.ibmPlexSansArabic(fontSize: 24, fontWeight: FontWeight.w900, color: colorScheme.primary)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'راجع قراءتك مباشرة. اقرأ الآية وسيُصححها الذكاء الاصطناعي فوراً.\nالكلمات الصحيحة تظهر باللون الأخضر، والأخطاء باللون الأحمر.',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.7), height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TajweedScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text('ابدأ جلسة التصحيح', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(height: 20),
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
        title: Text('القرآن الكريم', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_book_rounded, color: colorScheme.primary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // 🆕 زر معلم التجويد
          IconButton(
            icon: Icon(Icons.spellcheck, color: colorScheme.primary),
            onPressed: _showTajweedBubble,
            tooltip: 'معلم التجويد',
          ),
          IconButton(
            icon: Icon(Icons.flag_rounded, color: colorScheme.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuranChallengeScreen(initialPage: _currentPage)),
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
      body: PageviewQuran(
        initialPageNumber: _currentPage,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          Provider.of<UserProgressProvider>(context, listen: false).updateReadPages(page);
        },
      ),
    );
  }

  Widget _buildNavigationDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1)),
            child: Center(
              child: Text('فهرس المصحف', style: GoogleFonts.ibmPlexSansArabic(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.primary)),
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
                    child: Text('$surahNumber', style: TextStyle(color: colorScheme.primary)),
                  ),
                  title: Text(name, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
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