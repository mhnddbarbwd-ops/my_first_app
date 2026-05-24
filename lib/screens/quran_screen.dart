import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:nafahat/providers/user_progress_provider.dart';
// ✅ تم حذف: import 'package:flutter/services.dart'; (غير ضروري لأن material.dart يغطيه)
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadLastSavedPage(); 
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLastSavedPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = prefs.getInt('last_quran_page') ?? 1;
      _isLoading = false; 
    });
  }

  Future<void> _saveCurrentPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_quran_page', page);
  }

  void _jumpToPage(int page) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {      Navigator.pop(context); 
    }
    setState(() {
      _currentPage = page;
    });
    _saveCurrentPage(page);
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _surahResults = []);
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
                      setDialogState(() {});                    },
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
                                  Navigator.of(ctx).pop(); 
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

  // القائمة المنبثقة العصرية عند الضغط المطول
  void _showPageOptions() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text('خيارات الصفحة $_currentPage', 
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOptionItem(context, Icons.menu_book_rounded, 'تفسير', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('سيتم إضافة مكتبة التفسير قريباً', style: GoogleFonts.ibmPlexSansArabic())));
                  }),
                  _buildOptionItem(context, Icons.volume_up_rounded, 'استماع', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('سيتم تشغيل صوت السورة قريباً', style: GoogleFonts.ibmPlexSansArabic())));
                  }),
                  _buildOptionItem(context, Icons.bookmark_add_rounded, 'حفظ', () {
                    _saveCurrentPage(_currentPage);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ الصفحة كعلامة توقف', style: GoogleFonts.ibmPlexSansArabic())));
                  }),
                  _buildOptionItem(context, Icons.share_rounded, 'مشاركة', () {
                    Navigator.pop(context);                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('القرآن الكريم',
            style: GoogleFonts.ibmPlexSansArabic(
                fontWeight: FontWeight.bold, fontSize: 22, color: colorScheme.primary)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu_book_rounded, color: colorScheme.primary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: colorScheme.primary),
            onPressed: _showSearchDialog,
          ),
          const BackButton(), 
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildModernDrawer(colorScheme),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SafeArea(
              child: GestureDetector(
                onLongPress: _showPageOptions,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.5,
                    clipBehavior: Clip.none,
                    child: PageviewQuran(
                      key: ValueKey(_currentPage), 
                      initialPageNumber: _currentPage,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                        _saveCurrentPage(page); 
                        Provider.of<UserProgressProvider>(context, listen: false).updateReadPages(page);
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildModernDrawer(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(                colors: isDark 
                    ? [colorScheme.surface, colorScheme.primary.withOpacity(0.2)]
                    : [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_stories_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text('فهرس السور',
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: 114,
              separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.2), height: 1),
              itemBuilder: (context, index) {
                final surahNumber = index + 1;
                final page = getPageNumber(surahNumber, 1);
                final name = getSurahNameArabic(surahNumber);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.star_border_rounded, size: 40, color: colorScheme.primary.withOpacity(0.5)),
                      Text('$surahNumber',
                          style: GoogleFonts.ibmPlexSansArabic(
                              color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  title: Text(name,
                      style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600, fontSize: 18)),
                  trailing: Container(                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('ص $page', 
                      style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                  ),
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