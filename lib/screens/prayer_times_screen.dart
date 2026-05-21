import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _isLoading = true;
  String _locationText = 'جاري تحديد الموقع...';
  Map<String, String> _prayerTimes = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  Future<void> _loadTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // --- GPS ---
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'GPS غير مفعل. لا يمكن حساب المواقيت.';

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'تم رفض صلاحية الموقع.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'صلاحية الموقع مرفوضة بشكل دائم.';
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = pos.latitude;
      final lng = pos.longitude;
      final tzOffset = (lng / 15).round(); // تقريب المنطقة الزمنية

      // --- اسم المكان ---
      String place = 'موقعك الحالي';
      try {
        final pm = await placemarkFromCoordinates(lat, lng);
        if (pm.isNotEmpty) {
          place = '${pm.first.locality ?? ''}, ${pm.first.country ?? ''}';
        }
      } catch (_) {}
      _locationText = place;

      // --- حساب المواقيت فلكيًا ---
      final times = _computePrayerTimes(lat, lng, tzOffset);

      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ---------------------- الخوارزمية الفلكية ----------------------
  Map<String, String> _computePrayerTimes(double lat, double lng, int tzOffset) {
    final date = DateTime.now();
    final jd = _julianDate(date.year, date.month, date.day);
    final d = jd - 2451545.0;

    final g = (357.529 + 0.98560028 * d) % 360;
    final q = (280.459 + 0.98564736 * d) % 360;
    final L = (q + 1.915 * _sin(g) + 0.020 * _sin(2 * g)) % 360;
    final R = 1.00014 - 0.01671 * _cos(g) - 0.00014 * _cos(2 * g);
    final e = 23.439 - 0.00000036 * d;

    double sunEq, delta, haFajr, haIsha;
    double haSunrise = _hourAngle(90.833, e, decl(L, e), lat, true); // الشروق
    double haDhuhr = _hourAngle(0, e, decl(L, e), lat, false); // الظهر
    double haAsrShafii = _hourAngleAsr(lat, decl(L, e), 1);
    double haMaghrib = _hourAngle(90.833, e, decl(L, e), lat, false); // المغرب

    // زوايا الفجر والعشاء (تختلف حسب الطريقة: هنا أم القرى التقريبي)
    haFajr = _hourAngle(108, e, decl(L, e), lat, true); // 18.5 درجة لأم القرى
    haIsha = _hourAngle(108, e, decl(L, e), lat, false); // 18.5 درجة

    double noon = (720 - 4 * lng - _equationOfTime(d) + tzOffset * 60) / 1440;
    double sunrise = noon - haSunrise * 4 / 1440;
    double sunset = noon + haSunrise * 4 / 1440;
    double fajr = noon - haFajr * 4 / 1440;
    double isha = noon + haIsha * 4 / 1440;
    double dhuhr = noon;
    double asr = noon + haAsrShafii * 4 / 1440;
    double maghrib = sunset;

    return {
      'الفجر': _fmtTime(fajr),
      'الشروق': _fmtTime(sunrise),
      'الظهر': _fmtTime(dhuhr),
      'العصر': _fmtTime(asr),
      'المغرب': _fmtTime(maghrib),
      'العشاء': _fmtTime(isha),
    };
  }

  double _hourAngle(double angle, double e, double delta, double lat, bool isRise) {
    final num = _cos(angle) - _sin(lat) * _sin(delta);
    final den = _cos(lat) * _cos(delta);
    final val = num / den;
    if (val > 1 || val < -1) return isRise ? 0 : 180;
    return (isRise ? 360 - _acos(val) : _acos(val)) / 15;
  }

  double _hourAngleAsr(double lat, double delta, int shadowLength) {
    final num = _sin(_acot(shadowLength + _tan((lat - delta).abs()))) - _sin(lat) * _sin(delta);
    final den = _cos(lat) * _cos(delta);
    final val = num / den;
    if (val > 1 || val < -1) return 0;
    return _acos(val) / 15;
  }

  double decl(double L, double e) {
    return _asin(_sin(e) * _sin(L));
  }

  double _equationOfTime(double d) {
    final g = (357.529 + 0.98560028 * d) % 360;
    final q = (280.459 + 0.98564736 * d) % 360;
    final L = (q + 1.915 * _sin(g) + 0.020 * _sin(2 * g)) % 360;
    final e = 23.439 - 0.00000036 * d;
    final y = _tan(e / 2) * _tan(e / 2);
    return 4 * _toDeg(y * _sin(2 * L) - 2 * 0.01671 * _sin(g) + 4 * 0.01671 * y * _sin(g) * _cos(2 * L) - 0.5 * y * y * _sin(4 * L) - 1.25 * 0.01671 * 0.01671 * _sin(2 * g));
  }

  double _julianDate(int year, int month, int day) {
    if (month <= 2) { year -= 1; month += 12; }
    final A = (year / 100).floor();
    final B = 2 - A + (A / 4).floor();
    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + B - 1524.5;
  }

  String _fmtTime(double fraction) {
    final totalMinutes = (fraction * 24 * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  double _sin(dynamic x) => sin(_toRad(x));
  double _cos(dynamic x) => cos(_toRad(x));
  double _tan(dynamic x) => tan(_toRad(x));
  double _asin(double x) => asin(x.clamp(-1, 1));
  double _acos(double x) => acos(x.clamp(-1, 1));
  double _acot(double x) => pi / 2 - atan(x);
  double _toRad(dynamic x) => (x is double ? x : x.toDouble()) * pi / 180;
  double _toDeg(dynamic x) => (x is double ? x : x.toDouble()) * 180 / pi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('مواقيت الصلاة',
            style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTimes,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('جاري حساب المواقيت...',
                      style: GoogleFonts.ibmPlexSansArabic()),
                ],
              ),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(_error!, textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 18, color: colorScheme.error)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.my_location_rounded, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_locationText,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._prayerTimes.entries.map((e) {
                        final name = e.key;
                        final time = e.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.primary.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, color: colorScheme.secondary),
                                  const SizedBox(width: 12),
                                  Text(name,
                                      style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text(time,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.primary)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
