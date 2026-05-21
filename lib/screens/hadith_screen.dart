import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// لا تنسَ استدعاء ملف البيانات (تأكد من المسار الصحيح لديك)
import 'package:nafahat/data/hadith_data.dart'; 

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // جلب البيانات من الكلاس الذي أنشأناه
    final hadiths = HadithDatabase.nawawiHadiths; 

    return Scaffold(
      appBar: AppBar(
        title: Text('الأربعين النووية', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: hadiths.length,
        itemBuilder: (ctx, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildHadithCard(context, hadiths[i], colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildHadithCard(BuildContext context, HadithModel h, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.menu_book_rounded, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.title,
                      style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
                    ),
                    Text('رواه: ${h.narrator}', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
          Text(
            h.text,
            style: GoogleFonts.amiri(fontSize: 20, height: 1.9, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(h.grade, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.secondary)),
              ),
              ElevatedButton.icon(
                onPressed: () => _showHadithDetail(context, h, colorScheme),
                icon: const Icon(Icons.auto_stories_rounded, size: 18),
                label: Text('الشرح والبيان', style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHadithDetail(BuildContext context, HadithModel h, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.title, style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text('المصدر: ${h.source}', style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.5))),
                    const SizedBox(height: 24),
                    Text('الفوائد المستنبطة والشرح:', style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w800, color: colorScheme.secondary)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface, 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                      ),
                      child: Text(
                        h.sharh,
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, height: 1.8, color: colorScheme.onSurface.withOpacity(0.85)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}