import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:google_fonts/google_fonts.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = PrayerTimes.today();
    final prayers = [
      ('الفجر', today.fajr),
      ('الشروق', today.sunrise),
      ('الظهر', today.dhuhr),
      ('العصر', today.asr),
      ('المغرب', today.maghrib),
      ('العشاء', today.isha),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('اليمن - حضرموت', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18)),
            const SizedBox(height: 30),
            ...prayers.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.$1, style: GoogleFonts.ibmPlexSansArabic(fontSize: 20)),
                  Text(p.$2, style: GoogleFonts.ibmPlexSansArabic(fontSize: 20)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
