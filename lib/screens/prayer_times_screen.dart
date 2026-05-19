import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_prayer_time_calculator/flutter_prayer_time_calculator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

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
  int _selectedTab = 0; // 0 = مواقيت، 1 = بوصلة

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
      date: now, latitude: latitude, longitude: longitude,
      method: CalculationMethod.makkah, asrMethod: AsrMethod.standard,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTab == 0 ? 'مواقيت الصلاة' : 'بوصلة القبلة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent, elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(children: [
              Expanded(child: _buildTab('مواقيت الصلاة', 0, colorScheme)),
              const SizedBox(width: 10),
              Expanded(child: _buildTab('بوصلة القبلة', 1, colorScheme)),
            ]),
          ),
        ),
      ),
      body: _selectedTab == 0 ? _buildPrayerTimes(colorScheme) : _buildQiblaCompass(colorScheme),
    );
  }

  Widget _buildTab(String text, int index, ColorScheme colorScheme) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? colorScheme.primary : Colors.transparent, width: 3)),
        ),
        child: Text(text, textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? colorScheme.primary : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildQiblaCompass(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text('اتجه نحو القبلة', style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 30),
          SizedBox(
            width: 280, height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // البوصلة الدائرية
                StreamBuilder<QiblahDirection>(
                  stream: FlutterQiblah.qiblahStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final qiblahDirection = snapshot.data!;
                    return Transform.rotate(
                      angle: qiblahDirection.qiblah * (3.14159 / 180) * -1,
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _CompassPainter(),
                      ),
                    );
                  },
                ),
                // أيقونة الكعبة في المنتصف
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                    boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.4), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          StreamBuilder<QiblahDirection>(
            stream: FlutterQiblah.qiblahStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return Text(
                '${snapshot.data!.qiblah.toStringAsFixed(1)}°',
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 24, fontWeight: FontWeight.w900, color: colorScheme.primary),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimes(ColorScheme colorScheme) {
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
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                IconButton(onPressed: _requestLocation, icon: Icon(Icons.my_location_rounded, color: colorScheme.primary, size: 26), tooltip: 'تحديث الموقع'),
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
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
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
      ],
    );
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
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // الدائرة الخارجية
    final outerPaint = Paint()
      ..color = const Color(0xFF1B5E20).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, outerPaint);

    // علامات الاتجاهات
    final directionPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;

    // الشمال (مثلث)
    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius + 15)
      ..lineTo(center.dx - 12, center.dy - radius + 45)
      ..lineTo(center.dx + 12, center.dy - radius + 45)
      ..close();
    canvas.drawPath(northPath, directionPaint);

    // الجنوب (دائرة صغيرة)
    canvas.drawCircle(Offset(center.dx, center.dy + radius - 25), 5, directionPaint);

    // الشرق والغرب (خطوط)
    final smallPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx + radius - 25, center.dy), 4, smallPaint);
    canvas.drawCircle(Offset(center.dx - radius + 25, center.dy), 4, smallPaint);

    // خط القبلة (أخضر)
    final qiblaPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx, center.dy - radius + 10),
      qiblaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}