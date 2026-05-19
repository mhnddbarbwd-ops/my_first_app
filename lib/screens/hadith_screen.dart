import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dorar_hadith/dorar_hadith.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final DorarHadith _dorar = DorarHadith();
  List<Hadith> _hadiths = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchHadiths();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchHadiths() async {
    try {
      final result = await _dorar.search('', page: _currentPage, perPage: _perPage);
      setState(() {
        _hadiths = result.data;
        _isLoading = false;
        _hasMore = result.data.length >= _perPage;
      });
    } catch (e) {
      // فشل الاتصال، نعرض أحاديثاً مضمّنة
      _useLocalHadiths();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    _currentPage++;
    try {
      final result = await _dorar.search('', page: _currentPage, perPage: _perPage);
      setState(() {
        _hadiths.addAll(result.data);
        _hasMore = result.data.length >= _perPage;
      });
    } catch (e) {
      // التوقف عن التحميل
      setState(() => _hasMore = false);
    }
  }

  void _useLocalHadiths() {
    // أحاديث مضمّنة احتياطياً (الأربعين النووية)
    setState(() {
      _hadiths = [
        Hadith(id: '1', text: 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى...', narrator: 'عمر بن الخطاب رضي الله عنه', source: 'البخاري ومسلم', grade: 'صحيح'),
        Hadith(id: '2', text: 'بينما نحن جلوس عند رسول الله صلى الله عليه وسلم...', narrator: 'عمر بن الخطاب رضي الله عنه', source: 'مسلم', grade: 'صحيح'),
        Hadith(id: '3', text: 'بني الإسلام على خمس: شهادة أن لا إله إلا الله...', narrator: 'عبد الله بن عمر رضي الله عنه', source: 'البخاري ومسلم', grade: 'صحيح'),
        Hadith(id: '4', text: 'إن أحدكم يجمع خلقه في بطن أمه أربعين يوماً نطفة...', narrator: 'عبد الله بن مسعود رضي الله عنه', source: 'البخاري ومسلم', grade: 'صحيح'),
        Hadith(id: '5', text: 'من أحدث في أمرنا هذا ما ليس منه فهو رد', narrator: 'عائشة رضي الله عنها', source: 'البخاري ومسلم', grade: 'صحيح'),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('الأحاديث النبوية', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _hadiths.length + (_hasMore ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i >= _hadiths.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                final h = _hadiths[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHadithCard(h, colorScheme),
                );
              },
            ),
    );
  }

  Widget _buildHadithCard(Hadith hadith, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [colorScheme.surface.withOpacity(0.5), colorScheme.surface.withOpacity(0.25)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الراوي والمصدر
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: colorScheme.primary.withOpacity(0.1)),
                  child: Icon(Icons.person_rounded, color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(hadith.narrator ?? 'عن النبي ﷺ', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.primary)),
                  if (hadith.source != null) Text(hadith.source!, style: TextStyle(fontSize: 11, color: Colors.grey)),
                ])),
                if (hadith.grade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: hadith.grade == 'صحيح' ? Colors.green.shade50 : Colors.orange.shade50,
                    ),
                    child: Text(hadith.grade!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: hadith.grade == 'صحيح' ? Colors.green : Colors.orange)),
                  ),
              ]),
              const SizedBox(height: 12),
              // متن الحديث
              Text(hadith.text ?? '', style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, height: 1.6, color: colorScheme.onSurface)),
              const SizedBox(height: 12),
              // زر عرض المزيد
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showHadithDetail(hadith, colorScheme),
                  icon: Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
                  label: Text('معنى الحديث', style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHadithDetail(Hadith hadith, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('متن الحديث', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.primary)),
                  const SizedBox(height: 12),
                  Text(hadith.text ?? '', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, height: 1.8, color: colorScheme.onSurface)),
                  const SizedBox(height: 24),
                  if (hadith.sharh != null) ...[
                    Text('شرح الحديث', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.primary)),
                    const SizedBox(height: 12),
                    Text(hadith.sharh!, style: GoogleFonts.ibmPlexSansArabic(fontSize: 15, height: 1.7, color: colorScheme.onSurface.withOpacity(0.8))),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}