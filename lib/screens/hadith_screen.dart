import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith_nawawi/hadith_nawawi.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<Hadith> _hadiths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }

  Future<void> _loadHadiths() async {
    try {
      final data = await HadithNawawi().getAll();
      setState(() { _hadiths = data; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('الأحاديث', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _hadiths.length,
            itemBuilder: (ctx, i) {
              final h = _hadiths[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [colorScheme.surface.withOpacity(0.5), colorScheme.surface.withOpacity(0.25)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.narrator ?? '', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(h.text ?? '', style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, height: 1.5, color: colorScheme.onSurface)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
