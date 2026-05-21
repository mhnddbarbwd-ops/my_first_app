import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nafahat/services/hadith_service.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<Map<String, dynamic>> _hadiths = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }

  Future<void> _loadHadiths() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await HadithService.getRandomHadiths(count: 10);
      if (results.isNotEmpty) {
        _hadiths = results;
      } else {
        _error = 'لم يتم العثور على أحاديث. حاول مجدداً.';
      }
    } catch (e) {
      _error = 'فشل الاتصال بالإنترنت أو استنفذت حد الـ API اليومي.';
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('الأحاديث النبوية',
            style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadHadiths,
            tooltip: 'أحاديث جديدة',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('جاري جلب الأحاديث من الإنترنت...',
                      style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.primary)),
                ],
              ),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, color: colorScheme.error)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadHadiths,
                          icon: const Icon(Icons.refresh),
                          label: Text('إعادة المحاولة', style: GoogleFonts.ibmPlexSansArabic()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: _hadiths.length,
                  itemBuilder: (ctx, i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildHadithCard(_hadiths[i], colorScheme, isDark),
                    );
                  },
                ),
    );
  }

  Widget _buildHadithCard(Map<String, dynamic> h, ColorScheme colorScheme, bool isDark) {
    // استخراج البيانات من JSON الخاص بـ hadithapi.com
    final hadithNumber = h['hadithNumber']?.toString() ?? '';
    final text = h['hadithText'] ?? h['text'] ?? 'لا يوجد نص';
    final book = h['book'] ?? '';
    final chapter = h['chapter']?.toString() ?? '';
    final narrator = h['narrator'] ?? '';
    final grade = h['grade'] ?? 'غير محدد';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surface, colorScheme.primary.withOpacity(0.08)]
              : [Colors.white, colorScheme.primary.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withOpacity(0.15)
              : colorScheme.primary.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.1 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة: رقم الحديث + اسم الكتاب
            Row(
              children: [
                // دائرة رقم الحديث
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    hadithNumber.isNotEmpty ? '#$hadithNumber' : '',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (chapter.isNotEmpty)
                        Text(
                          chapter,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                // درجة الحديث
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: grade.contains('صحيح')
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    grade,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: grade.contains('صحيح') ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            // فاصل فاخر
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0),
                      colorScheme.primary.withOpacity(0.2),
                      colorScheme.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            // نص الحديث
            Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: GoogleFonts.amiri(
                fontSize: 20,
                height: 2.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // الراوي
            if (narrator.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.person_rounded, size: 16, color: colorScheme.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'رواه: $narrator',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // زر المشاركة
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  // يمكن إضافة مشاركة لاحقاً
                },
                icon: Icon(Icons.share_rounded, size: 18, color: colorScheme.secondary),
                label: Text('مشاركة', style: GoogleFonts.ibmPlexSansArabic(color: colorScheme.secondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
