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
  String _locationName = '';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
      _permissionDeniedForever = false;
    });

    // 1. التحقق من حالة صلاحية الموقع
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // المستخدم رفض الصلاحية بشكل دائم
      setState(() {
        _permissionDeniedForever = true;
        _isLoading = false;
      });
      return;
    }

    if (permission == LocationPermission.denied) {
      // طلب الصلاحية لأول مرة أو بعد رفض سابق
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _permissionDenied = true;
          _isLoading = false;
        });
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _permissionDeniedForever = true;
          _isLoading = false;
        });
        return;
      }
    }

    // 2. الصلاحية ممنوحة، جلب الموقع
    await _getLocationAndCalculate();
  }

  Future<void> _getLocationAndCalculate() async {
    try {
      // التحقق من تفعيل خدمة الموقع في الجهاز
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('يرجى تفعيل خدمة الموقع من إعدادات الجهاز'),
              action: SnackBarAction(
                label: 'فتح الإعدادات',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _locationName = 'موقعك الحالي';
      _calculateTimes(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحديد موقعك. حاول مجدداً.')),
        );
      }
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

    setState(() {
      _times = times;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('مواقيت الصلاة',
            style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _permissionDenied || _permissionDeniedForever
              ? _buildPermissionDeniedView(colorScheme)
              : _buildPrayerTimesView(colorScheme),
    );
  }

  Widget _buildPermissionDeniedView(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.error.withOpacity(0.1),
              ),
              child: Icon(Icons.location_off_rounded,
                  size: 50, color: colorScheme.error),
            ),
            const SizedBox(height: 24),
            Text(
              _permissionDeniedForever
                  ? 'تم رفض الوصول إلى الموقع بشكل دائم'
                  : 'تم رفض الوصول إلى الموقع',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _permissionDeniedForever
                  ? 'يرجى الذهاب إلى إعدادات الجهاز ومنح صلاحية الموقع للتطبيق'
                  : 'يجب منح صلاحية الموقع لحساب مواقيت الصلاة بدقة',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            if (_permissionDeniedForever)
              _buildGlassButton(
                context,
                icon: Icons.settings_rounded,
                label: 'فتح إعدادات الجهاز',
                onTap: () => Geolocator.openLocationSettings(),
                colorScheme: colorScheme,
              )
            else
              _buildGlassButton(
                context,
                icon: Icons.my_location_rounded,
                label: 'إعادة طلب الصلاحية',
                onTap: _requestLocationPermission,
                colorScheme: colorScheme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesView(ColorScheme colorScheme) {
    final prayers = [
      ('الفجر', _times[PrayerTime.fajr] ?? '--:--', Icons.wb_twilight),
      ('الشروق', _times[PrayerTime.sunrise] ?? '--:--', Icons.sunny),
      ('الظهر', _times[PrayerTime.dhuhr] ?? '--:--', Icons.wb_sunny),
      ('العصر', _times[PrayerTime.asr] ?? '--:--', Icons.wb_cloudy),
      ('المغرب', _times[PrayerTime.maghrib] ?? '--:--', Icons.nights_stay),
      ('العشاء', _times[PrayerTime.isha] ?? '--:--', Icons.bedtime),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقة الموقع
        _buildLocationCard(colorScheme),
        const SizedBox(height: 20),
        // بطاقات المواقيت الزجاجية
        ...prayers.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPrayerCard(p.$1, p.$2, p.$3, colorScheme),
            )),
      ],
    );
  }

  Widget _buildLocationCard(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.15),
                colorScheme.secondary.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
                color: colorScheme.primary.withOpacity(0.25), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.location_on_rounded,
                    color: colorScheme.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الموقع الحالي',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 2),
                    Text(_locationName,
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _requestLocationPermission,
                icon: Icon(Icons.my_location_rounded,
                    color: colorScheme.primary, size: 26),
                tooltip: 'تحديث الموقع',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard(
      String name, String time, IconData icon, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                colorScheme.surface.withOpacity(0.5),
                colorScheme.surface.withOpacity(0.25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
                color: colorScheme.primary.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(name,
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
              ),
              Text(time,
                  style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.2),
                colorScheme.primary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
                color: colorScheme.primary.withOpacity(0.3), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: colorScheme.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}