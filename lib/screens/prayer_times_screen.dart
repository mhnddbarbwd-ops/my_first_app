import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_prayer_time_calculator/flutter_prayer_time_calculator.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  String _currentLocationName = 'جاري تحديد الموقع...';
  Map<PrayerTime, String> _prayerTimes = {};

  final PrayerTimes _pt = PrayerTimes();

  // طريقة الحساب الافتراضية (أم القرى)
  CalculationMethod _method = CalculationMethod.makkah;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'الرجاء تفعيل خدمات الموقع (GPS) في إعدادات الهاتف.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'تم رفض صلاحية الوصول للموقع. لا يمكن حساب المواقيت تلقائيًا.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'صلاحيات الموقع مرفوضة بشكل دائم. يرجى تفعيلها من إعدادات النظام.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocationName =
            'خط عرض ${position.latitude.toStringAsFixed(3)} ، خط طول ${position.longitude.toStringAsFixed(3)}';
      });

      // حساب إزاحة المنطقة الزمنية (تقريبية)
      final int timezoneOffset =
          (position.longitude / 15).round(); // كل 15 درجة = ساعة

      // استدعاء المكتبة المثبتة مسبقًا
      _pt.setMethod(_method);
      final Map<PrayerTime, String> times = _pt.getTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        timezone: timezoneOffset,
        format: TimeFormat.twentyFourHour,
      );

      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeMethod(CalculationMethod? method) {
    if (method != null && method != _method) {
      setState(() {
        _method = method;
        _isLoading = true;
      });
      _determinePosition();
    }
  }

  // الحصول على اسم الصلاة بالعربية
  String _getPrayerName(PrayerTime pt) {
    switch (pt) {
      case PrayerTime.fajr:
        return 'الفجر';
      case PrayerTime.sunrise:
        return 'الشروق';
      case PrayerTime.dhuhr:
        return 'الظهر';
      case PrayerTime.asr:
        return 'العصر';
      case PrayerTime.maghrib:
        return 'المغرب';
      case PrayerTime.isha:
        return 'العشاء';
      case PrayerTime.midnight:
        return 'منتصف الليل';
      default:
        return pt.displayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('مواقيت الصلاة',
            style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _determinePosition,
            tooltip: 'تحديث الموقع والمواقيت',
          ),
          PopupMenuButton<CalculationMethod>(
            icon: const Icon(Icons.tune),
            tooltip: 'طريقة الحساب',
            onSelected: _changeMethod,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: CalculationMethod.makkah,
                child: Text('أم القرى'),
              ),
              PopupMenuItem(
                value: CalculationMethod.mwl,
                child: Text('رابطة العالم الإسلامي'),
              ),
              PopupMenuItem(
                value: CalculationMethod.egypt,
                child: Text('الهيئة المصرية'),
              ),
              PopupMenuItem(
                value: CalculationMethod.karachi,
                child: Text('كراتشي'),
              ),
            ],
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
                  Text('جاري تحديد الموقع وحساب المواقيت...',
                      style: GoogleFonts.ibmPlexSansArabic(
                          color: colorScheme.primary)),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_rounded,
                            size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_errorMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 16, color: colorScheme.error)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _determinePosition,
                          icon: const Icon(Icons.my_location),
                          label: Text('إعادة المحاولة',
                              style: GoogleFonts.ibmPlexSansArabic()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
                            Icon(Icons.my_location_rounded,
                                color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_currentLocationName,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._prayerTimes.entries.map((entry) {
                        final prayerName = _getPrayerName(entry.key);
                        final time = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    colorScheme.primary.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      color: colorScheme.secondary),
                                  const SizedBox(width: 12),
                                  Text(prayerName,
                                      style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
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
