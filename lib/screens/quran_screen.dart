import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:nafahat/providers/user_progress_provider.dart';
import 'package:nafahat/screens/quran_challenge_screen.dart';
import 'package:flutter/services.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  
  int _currentPage = 1;
  double _zoomLevel = 1.0; // متغير التحكم في حجم الخط/الصفحة
  List<Map<String, dynamic>> _surahResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _jumpToPage(int page) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context); // إغلاق الدرج فقط
    }
    setState(() {
      _currentPage = page;
      _zoomLevel = 1.0; // إعادة الحجم للطبيعي عند تغيير الصفحة
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('البحث في السور',
                style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      hintText: 'اسم السورة...',
                      hintStyle: GoogleFonts.ibmPlexSansArabic(),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _surahResults.isEmpty
                        ? Center(
                            child: Text('اكتب اسم السورة للبحث',
                                style: GoogleFonts.ibmPlexSansArabic(color: Colors.grey)))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _surahResults.length,
                            itemBuilder: (context, i) {
                              final s = _surahResults[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Text('${s['number']}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                ),
                                title: Text(s['name'],
                                    style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
                                subtitle: Text('صفحة: ${s['page']}', style: GoogleFonts.ibmPlexSansArabic()),
                                onTap: () {
                                  Navigator.of(ctx).pop(); // إغلاق مربع البحث فقط بشكل آمن
                                  _jumpToPage(s['page'] as int);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // خيارات الآيات / الصفحة عند الضغط المطول
  void _showPageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text('خيارات الصفحة $_currentPage', 
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: Text('حفظ كعلامة توقف', style: GoogleFonts.ibmPlexSansArabic()),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حفظ الصفحة $_currentPage في العلامات', style: GoogleFonts.ibmPlexSansArabic())),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text('نسخ محتوى الصفحة', style: GoogleFonts.ibmPlexSansArabic()),
                onTap: () {
                  // هنا يتم وضع كود استخراج النص إذا كانت الحزمة تدعمه، أو نسخ الرابط
                  Clipboard.setData(ClipboardData(text: 'القرآن الكريم - صفحة $_currentPage'));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم النسخ', style: GoogleFonts.ibmPlexSansArabic())),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text('مشاركة', style: GoogleFonts.ibmPlexSansArabic()),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'challenge':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QuranChallengeScreen(initialPage: _currentPage)),
        );
        break;
      case 'zoom_in':
        setState(() {
          if (_zoomLevel < 2.5) _zoomLevel += 0.2;
        });
        break;
      case 'zoom_out':
        setState(() {
          if (_zoomLevel > 1.0) _zoomLevel -= 0.2;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('القرآن',
            style: GoogleFonts.ibmPlexSansArabic(
                fontWeight: FontWeight.bold, fontSize: 22, color: colorScheme.primary)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(), // زر العودة فقط
        actions: [
          IconButton(
            icon: Icon(Icons.format_list_bulleted_rounded, color: colorScheme.primary),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: Icon(Icons.search_rounded, color: colorScheme.primary),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'challenge',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Text('تحدي جديد', style: GoogleFonts.ibmPlexSansArabic()),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'zoom_in',
                child: Row(
                  children: [
                    Icon(Icons.zoom_in, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Text('تكبير الخط', style: GoogleFonts.ibmPlexSansArabic()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'zoom_out',
                child: Row(
                  children: [
                    Icon(Icons.zoom_out, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Text('تصغير الخط', style: GoogleFonts.ibmPlexSansArabic()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildNavigationDrawer(colorScheme),
      body: SafeArea(
        child: GestureDetector(
          onLongPress: _showPageOptions,
          child: Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              // التحكم برمجياً عبر المتغير الخاص بنا
              transformationController: TransformationController(
                Matrix4.identity()..scale(_zoomLevel),
              ),
              child: PageviewQuran(
                key: ValueKey(_currentPage),
                initialPageNumber: _currentPage,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _zoomLevel = 1.0; // إعادة الحجم عند تغيير الصفحة
                  });
                  Provider.of<UserProgressProvider>(context, listen: false).updateReadPages(page);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.05)),
            child: Center(
              child: Text('الفهرس',
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 114,
              itemBuilder: (context, index) {
                final surahNumber = index + 1;
                final page = getPageNumber(surahNumber, 1);
                final name = getSurahNameArabic(surahNumber);
                return ListTile(
                  leading: Text('$surahNumber',
                      style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary, fontSize: 16)),
                  title: Text(name,
                      style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600)),
                  trailing: Text('ص $page', style: GoogleFonts.ibmPlexSansArabic(color: Colors.grey)),
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
