import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith_nawawi/hadith_nawawi.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('الأحاديث', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: HadithListWidget(
        locale: const Locale('ar'),
      ),
    );
  }
}