import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  String _locationLabel = 'جاري تحديد الموقع...';
  Map<String, String> _prayerTimes = {};

  // طريقة الحساب الافتراضية (أم القرى)
  CalculationMethod _calcMethod = CalculationMethod.umm_al_qura;

  // وقت التعديل (مكة المكرمة)
  Madhab _madhhab = Madhab.shafi;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndTimes();
  }

  Future<void> _fetchLocationAndTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. التحقق من خدمة الموقع وصلاحياته
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

      // 2. جلب الإحداثيات الحقيقية
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. تحديث وصف الموقع
      setState(() {
        _locationLabel = 'دولة/منطقة: حسب إحداثيات GPS';
      });

      // 4. حساب المواقيت بالإحداثيات الفعلية
      _calculateTimes(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateTimes(double lat, double lng) {
    try {
      // إعداد الإحداثيات
      final coordinates = Coordinates(lat, lng);

      // تحضير معاملات الحساب
      final params = _calcMethod.getParameters();
      final dateComponents = DateComponents.fromDateTime(DateTime.now());

      // حساب أوقات الصلاة
      final todayPrayers = PrayerTimes(
        coordinates: coordinates,
        date: dateComponents,
        calculationParameters: params,
        madhab: _madhhab,
      );

      // تنسيق النتائج
      setState(() {
        _prayerTimes = {
          'الفجر': _formatTime(todayPrayers.fajr!),
          'الشروق': _formatTime(todayPrayers.sunrise!),
          'الظهر': _formatTime(todayPrayers.dhuhr!),
          'العصر': _formatTime(todayPrayers.asr!),
          'المغرب': _formatTime(todayPrayers.maghrib!),
          'العشاء': _formatTime(todayPrayers.isha!),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل حساب المواقيت: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _changeMethod(CalculationMethod? method) {
    if (method != null && method != _calcMethod) {
      setState(() {
        _calcMethod = method;
        _isLoading = true;
      });
      _fetchLocationAndTimes();
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
            onPressed: _fetchLocationAndTimes,
            tooltip: 'تحديث المواقيت',
          ),
          PopupMenuButton<CalculationMethod>(
            icon: const Icon(Icons.tune),
            tooltip: 'اختيار طريقة الحساب',
            onSelected: _changeMethod,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: CalculationMethod.umm_al_qura,
                child: Text('أم القرى (مكة)'),
              ),
              PopupMenuItem(
                value: CalculationMethod.muslim_world_league,
                child: Text('رابطة العالم الإسلامي'),
              ),
              PopupMenuItem(
                value: CalculationMethod.egyptian,
                child: Text('الهيئة المصرية'),
              ),
              PopupMenuItem(
                value: CalculationMethod.karachi,
                child: Text('جامعة العلوم كراتشي'),
              ),
              PopupMenuItem(
                value: CalculationMethod.dubai,
                child: Text('دبي'),
              ),
              PopupMenuItem(
                value: CalculationMethod.kuwait,
                child: Text('الكويت'),
              ),
              PopupMenuItem(
                value: CalculationMethod.qatar,
                child: Text('قطر'),
              ),
              PopupMenuItem(
                value: CalculationMethod.singapore,
                child: Text('سنغافورة'),
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
                          onPressed: _fetchLocationAndTimes,
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
                              child: Text(_locationLabel,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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
