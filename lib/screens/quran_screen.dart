import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:nafahat/providers/user_progress_provider.dart';
import 'package:nafahat/screens/quran_challenge_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;

  List<Map<String, dynamic>> _surahResults = [];

  static const Map<int, int> _juzStartPages = {
    1: 1, 2: 22, 3: 42, 4: 62, 5: 82, 6: 102,
    7: 121, 8: 142, 9: 162, 10: 182, 11: 201, 12: 222,
    13: 242, 14: 262, 15: 282, 16: 302, 17: 322, 18: 342,
    19: 362, 20: 382, 21: 402, 22: 422, 23: 442, 24: 462,
    25: 482, 26: 502, 27: 522, 28: 542, 29: 562, 30: 582,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _jumpToPage(int page) {
    // إغلاق أي قائمة مفتوحة (درج أو حوار)
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context); // إغلاق الدرج
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context); // إغلاق مربع البحث
    }
    // تغيير الصفحة الحالية
    setState(() {
      _currentPage = page;
    });
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _surahResults = [];
      });
      return;
    }

    setState(() {
      _surahResults = [];
      for (int i = 1; i <= 114; i++) {
        final name = getSurahNameArabic(i);
        if (name.contains(query.trim())) {
          _surahResults.add({
            'number': i,
            'name': name,
            'page': getPageNumber(i, 1),
          });
        }
      }
    });
  }

  void _showSearchDialog() {
    _searchController.clear();
    _surahResults = [];
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
                      hintText: 'اكتب اسم سورة للبحث...',
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _surahResults.isEmpty
                        ? Center(
                            child: Text('اكتب للبحث عن سورة',
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
                                  Navigator.pop(ctx);   // إغلاق الحوار أولاً
                                  _jumpToPage(s['page'] as int);
                                },
                              );
                            },
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
        leading: IconButton(
          icon: Icon(Icons.menu_book_rounded, color: colorScheme.primary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
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
      // ✅ الحل: إجبار إعادة بناء المصحف عند تغيير الصفحة
      body: PageviewQuran(
        key: ValueKey(_currentPage),   // <-- هذا السطر يحل مشكلة الانتقال
        initialPageNumber: _currentPage,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          Provider.of<UserProgressProvider>(context, listen: false)
              .updateReadPages(page);
        },
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
