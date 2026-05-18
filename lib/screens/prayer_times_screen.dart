import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_prayer_time_calculator/flutter_prayer_time_calculator.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Map<PrayerTime, String> _times = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateTimes();
  }

  void _calculateTimes() {
    final pt = PrayerTimes();
    final now = DateTime.now();
    // جلب المنطقة الزمنية للجهاز الحالي
    final timezoneOffset = now.timeZoneOffset.inHours;

    final times = pt.getTimes(
      date: now,
      latitude: 15.9477,
      longitude: 48.7866,
      method: CalculationMethod.makkah,
      asrMethod: AsrMethod.standard,
      timezone: timezoneOffset.toDouble(), // تمت إضافة هذا السطر
    );

    setState(() {
      _times = times;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prayers = [
      ('الفجر', _times[PrayerTime.fajr] ?? '--:--'),
      ('الشروق', _times[PrayerTime.sunrise] ?? '--:--'),
      ('الظهر', _times[PrayerTime.dhuhr] ?? '--:--'),
      ('العصر', _times[PrayerTime.asr] ?? '--:--'),
      ('المغرب', _times[PrayerTime.maghrib] ?? '--:--'),
      ('العشاء', _times[PrayerTime.isha] ?? '--:--'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('حضرموت - اليمن',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSansArabic(fontSize: 18)),
                const SizedBox(height: 30),
                ...prayers.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        child: ListTile(
                          title: Text(p.$1,
                              style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 20)),
                          trailing: Text(p.$2,
                              style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 20)),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
