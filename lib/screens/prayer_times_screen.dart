import 'package:flutter/material.dart';
import 'package:aladhan_prayer_times/aladhan_prayer_times.dart';
import 'package:intl/intl.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:google_fonts/google_fonts.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerTimes? _prayerTimes;
  String _currentDate = '';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final times = await AladhanPrayerTimes.fetchPrayerTimes(
        country: 'Yemen',
        city: 'Hadramaut',
      );

      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذر جلب مواقيت الصلاة';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'اليمن - حضرموت',
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 18),
                        ),
                        const SizedBox(height: 30),
                        _buildPrayerTimeTile('الفجر', _prayerTimes?.fajr),
                        _buildPrayerTimeTile('الشروق', _prayerTimes?.sunrise),
                        _buildPrayerTimeTile('الظهر', _prayerTimes?.dhuhr),
                        _buildPrayerTimeTile('العصر', _prayerTimes?.asr),
                        _buildPrayerTimeTile('المغرب', _prayerTimes?.maghrib),
                        _buildPrayerTimeTile('العشاء', _prayerTimes?.isha),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeTile(String prayerName, String? time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(prayerName, style: GoogleFonts.ibmPlexSansArabic(fontSize: 20)),
          Text(time ?? '--:--', style: GoogleFonts.ibmPlexSansArabic(fontSize: 20)),
        ],
      ),
    );
  }
}