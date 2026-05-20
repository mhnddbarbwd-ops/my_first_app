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
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;

  static const Map<int, int> _juzStartPages = {
    1: 1,   2: 22,  3: 42,  4: 62,  5: 82,  6: 102,
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
    Navigator.pop(context);
    setState(() => _currentPage = page);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('بحث في القرآن', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: _searchController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'اكتب كلمة أو آية للبحث...',
            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.trim().isNotEmpty) {
                try {
                  final results = searchWords([_searchController.text.trim()]);
                  if (results['result'] != null && (results['result'] as List).isNotEmpty) {
                    final firstMatch = results['result'][0];
                    final surah = firstMatch['suraNumber'] as int;
                    final verse = firstMatch['verseNumber'] as int;
                    final page = getPageNumber(surah, verse);
                    Navigator.pop(ctx);
                    setState(() => _currentPage = page);
                  }
                } catch (_) {}
              }
            },
            child: const Text('بحث'),
          ),
        ],
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
        ),
        actions: [
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
        },
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
              tabs: const [
                Tab(text: 'السور'),
                Tab(text: 'الأجزاء'),
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
}