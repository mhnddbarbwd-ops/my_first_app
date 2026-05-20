import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
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
      ),
      body: const PageviewQuran(
        initialPageNumber: 1,
      ),
    );
  }
}