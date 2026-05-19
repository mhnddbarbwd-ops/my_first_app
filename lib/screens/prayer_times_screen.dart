import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_prayer_time_calculator/flutter_prayer_time_calculator.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Map<PrayerTime, String> _times = {};
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _permissionDeniedForever = false;
  String? _errorMessage;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    setState(() { _isLoading = true; _permissionDenied = false; _permissionDeniedForever = false; _errorMessage = null; });

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.deniedForever) {
      setState(() { _permissionDeniedForever = true; _isLoading = false; });
      return;
    }
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        setState(() { _permissionDenied = true; _isLoading = false; });
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() { _permissionDeniedForever = true; _isLoading = false; });
        return;
      }
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _isLoading = false; _errorMessage = 'خدمة الموقع غير مفعلة'; });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      setState(() { _position = position; _calculateTimes(position.latitude, position.longitude); });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = 'تعذر تحديد الموقع. حاول مجدداً.'; });
    }
  }

  void _calculateTimes(double latitude, double longitude) {
    final pt = PrayerTimes();
    final now = DateTime.now();
    final timezoneOffset = now.timeZoneOffset.inHours;
    final times = pt.getTimes(
      date: now,
      latitude: latitude,
      longitude: longitude,
      method: CalculationMethod.makkah,
      asrMethod: AsrMethod.standard,
      timezone: timezoneOffset.toDouble(),
    );
    setState(() { _times = times; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic())), body: const Center(child: CircularProgressIndicator()));
    if (_permissionDenied || _permissionDeniedForever) return _buildDeniedView(colorScheme);
    if (_errorMessage != null || _position == null) return _buildErrorView(colorScheme);
    return _buildTimesView(colorScheme);
  }

  Widget _buildDeniedView(ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic())),
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.location_off_rounded, size: 80, color: colorScheme.error),
        const SizedBox(height: 20),
        Text(_permissionDeniedForever ? 'تم رفض الموقع بشكل دائم' : 'تم رفض الموقع', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18)),
        const SizedBox(height: 10),
        Text(_permissionDeniedForever ? 'اذهب إلى إعدادات الجهاز لمنح الصلاحية' : 'يجب منح صلاحية الموقع لحساب المواقيت', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _permissionDeniedForever ? () => Geolocator.openLocationSettings() : _requestLocation,
          icon: Icon(_permissionDeniedForever ? Icons.settings : Icons.refresh),
          label: Text(_permissionDeniedForever ? 'فتح الإعدادات' : 'إعادة المحاولة'),
        ),
      ]))),
    );
  }

  Widget _buildErrorView(ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic())),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 80, color: colorScheme.error),
        const SizedBox(height: 20),
        Text(_errorMessage ?? 'حدث خطأ', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18)),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: _requestLocation, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
      ])),
    );
  }

  Widget _buildTimesView(ColorScheme colorScheme) {
    final prayers = [
      ('الفجر', _times[PrayerTime.fajr] ?? '--:--', Icons.wb_twilight),
      ('الشروق', _times[PrayerTime.sunrise] ?? '--:--', Icons.sunny),
      ('الظهر', _times[PrayerTime.dhuhr] ?? '--:--', Icons.wb_sunny),
      ('العصر', _times[PrayerTime.asr] ?? '--:--', Icons.wb_cloudy),
      ('المغرب', _times[PrayerTime.maghrib] ?? '--:--', Icons.nights_stay),
      ('العشاء', _times[PrayerTime.isha] ?? '--:--', Icons.bedtime),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic())),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [colorScheme.primary.withOpacity(0.15), colorScheme.secondary.withOpacity(0.08)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: colorScheme.primary.withOpacity(0.25)),
              ),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.location_on_rounded, color: colorScheme.primary, size: 26)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('موقعك الحالي', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                  Text('خط عرض ${_position!.latitude.toStringAsFixed(2)}، خط طول ${_position!.longitude.toStringAsFixed(2)}', style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                ])),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...prayers.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(colors: [colorScheme.surface.withOpacity(0.5), colorScheme.surface.withOpacity(0.25)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1),
                ),
                child: Row(children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: colorScheme.primary.withOpacity(0.1)), child: Icon(p.$3, color: colorScheme.primary, size: 22)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(p.$1, style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface))),
                  Text(p.$2, style: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.primary)),
                ]),
              ),
            ),
          ),
        )),
      ]),
    );
  }
}
