import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentPage = 1;
  String? _searchError;
  bool _isSearching = false;

  // الصفحات الأولى لكل جزء (مأخوذة من بيانات موثقة)
  static const Map<int, int> _juzStartPages = {
    1: 1,   2: 22,  3: 42,  4: 62,  5: 82,  6: 102,
    7: 121, 8: 142, 9: 162, 10: 182, 11: 201, 12: 222,
    13: 242, 14: 262, 15: 282, 16: 302, 17: 322, 18: 342,
    19: 362, 20: 382, 21: 402, 22: 422, 23: 442, 24: 462,
    25: 482, 26: 502, 27: 522, 28: 542, 29: 562, 30: 582,
  };

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _jumpToPage(int page) {
    _pageController.jumpToPage(page - 1);
    setState(() => _currentPage = page);
    Navigator.pop(context); // إغلاق الدرج
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchError = 'الرجاء إدخال نص للبحث');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = searchWords(query.trim());
      if (results['result'] != null && (results['result'] as List).isNotEmpty) {
        final firstMatch = results['result'][0];
        final surah = firstMatch['suraNumber'] as int;
        final verse = firstMatch['verseNumber'] as int;
        final page = getPageNumber(surah, verse);
        _jumpToPage(page);
        setState(() => _searchError = null);
      } else {
        setState(() => _searchError = 'لم يتم العثور على نتائج');
      }
    } catch (e) {
      setState(() => _searchError = 'حدث خطأ أثناء البحث');
    }
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'القرآن الكريم',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_book_rounded, color: colorScheme.primary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'فهرس السور والأجزاء',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: colorScheme.primary),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'بحث في القرآن',
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(colorScheme),
      body: Stack(
        children: [
          PageviewQuran(
            initialPageNumber: 1,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
          ),
          // زر الانتقال إلى الصفحة السابقة
          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.35,
            child: _buildNavButton(Icons.arrow_back_ios_rounded, () {
              if (_currentPage > 1) _jumpToPage(_currentPage - 1);
            }),
          ),
          // زر الانتقال إلى الصفحة التالية
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height * 0.35,
            child: _buildNavButton(Icons.arrow_forward_ios_rounded, () {
              if (_currentPage < 604) _jumpToPage(_currentPage + 1);
            }),
          ),
          // شريط التقدم في الأسفل
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: colorScheme.surface.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'صفحة $_currentPage من 604',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildNavigationDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  'فهرس المصحف',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
              tabs: [
                Tab(text: 'السور', child: Text('السور', style: GoogleFonts.ibmPlexSansArabic())),
                Tab(text: 'الأجزاء', child: Text('الأجزاء', style: GoogleFonts.ibmPlexSansArabic())),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSurahList(colorScheme),
                  _buildJuzList(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList(ColorScheme colorScheme) {
    return ListView.builder(
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
    );
  }

  Widget _buildJuzList(ColorScheme colorScheme) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final page = _juzStartPages[juzNumber] ?? 1;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.secondary.withOpacity(0.1),
            child: Text('$juzNumber', style: TextStyle(color: colorScheme.secondary)),
          ),
          title: Text('الجزء $juzNumber', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
          subtitle: Text('الصفحة: $page'),
          onTap: () => _jumpToPage(page),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('بحث في القرآن', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'اكتب كلمة أو آية للبحث...',
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
              ),
            ),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_searchError!, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _isSearching
                ? null
                : () => _performSearch(_searchController.text),
            child: _isSearching
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('بحث'),
          ),
        ],
      ),
    );
  }
}