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

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  double _fontScale = 1.0;
  List<int> _pageHistory = [1];

  List<Map<String, dynamic>> _surahResults = [];
  List<Map<String, dynamic>> _ayahResults = [];
  late TabController _tabController;

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

      // البحث المحلي في الآيات
      _ayahResults = _localSearchVerses(query.trim());
    });
  }

  List<Map<String, dynamic>> _localSearchVerses(String query) {
    // هذا بحث محلي مبسط، يمكن استبداله لاحقاً بمكتبة متكاملة
    // يعتمد على quran_lib الذي قدمناه سابقاً.
    try {
      // افترض وجود دالة خارجية أو مكتبة، وإلا نعطي نتيجة فارغة.
      return [];
    } catch (e) {
      return [];
    }
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
                        _ayahResults.isEmpty
                            ? Center(
                                child: Text('البحث في الآيات قيد التطوير',
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
