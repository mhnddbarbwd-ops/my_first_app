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
  Map<String, String> _prayerTimes = {};

  // طريقة الحساب الافتراضية (أم القرى – مناسبة لمعظم الدول العربية)
  CalculationMethod _calculationMethod = CalculationMethod.ummalqura;

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
      // التحقق من خدمة الموقع والصلاحيات
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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

      // جلب الموقع الحالي بدقة عالية
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocationName =
            'خط عرض ${position.latitude.toStringAsFixed(3)} ، خط طول ${position.longitude.toStringAsFixed(3)}';
      });

      // حساب مواقيت الصلاة بناءً على الإحداثيات
      _calculatePrayerTimes(position);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculatePrayerTimes(Position position) {
    try {
      final coordinates = Coordinates(position.latitude, position.longitude);
      final today = DateTime.now();

      // استخدام طريقة الحساب المختارة
      final times = PrayerTime.getPrayerTimes(
        today,
        coordinates,
        _calculationMethod,
      );

      if (times != null) {
        setState(() {
          _prayerTimes = {
            'الفجر': times.fajr ?? '--:--',
            'الشروق': times.sunrise ?? '--:--',
            'الظهر': times.dhuhr ?? '--:--',
            'العصر': times.asr ?? '--:--',
            'المغرب': times.maghrib ?? '--:--',
            'العشاء': times.isha ?? '--:--',
          };
          _isLoading = false;
        });
      } else {
        throw 'فشل حساب المواقيت. حاول مجددًا.';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في حساب المواقيت: $e';
        _isLoading = false;
      });
    }
  }

  // تغيير طريقة الحساب (اختياري)
  void _changeCalculationMethod(CalculationMethod? method) {
    if (method != null) {
      setState(() {
        _calculationMethod = method;
        _isLoading = true;
      });
      _determinePosition(); // إعادة الحساب بنفس الموقع مع الطريقة الجديدة
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
            onSelected: _changeCalculationMethod,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: CalculationMethod.ummalqura,
                child: Text('أم القرى'),
              ),
              const PopupMenuItem(
                value: CalculationMethod.muslim_world_league,
                child: Text('رابطة العالم الإسلامي'),
              ),
              const PopupMenuItem(
                value: CalculationMethod.egyptian,
                child: Text('الهيئة المصرية'),
              ),
              const PopupMenuItem(
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
                      // بطاقة الموقع
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
                      // قائمة المواقيت
                      ..._prayerTimes.entries.map((entry) {
                        String name = entry.key;
                        String time = entry.value;
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
                                  Text(name,
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
