import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:aladhan_prayer_times/aladhan_prayer_times.dart';

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

  String _currentCountry = 'Saudi Arabia';
  String _currentCity = 'Makkah';

  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

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
      // محاولة الحصول على الدولة والمدينة من GPS
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'خدمة GPS غير مفعلة. سيتم استخدام الإعداد اليدوي.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'صلاحية الموقع مرفوضة. الرجاء إدخال الدولة والمدينة يدويًا.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'صلاحية الموقع مرفوضة دائمًا. استخدم الإدخال اليدوي.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // تحويل الإحداثيات إلى عنوان (دولة ومدينة)
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentCountry = place.country ?? 'Saudi Arabia';
        _currentCity = place.locality ?? place.subAdministrativeArea ?? 'Makkah';
      }
    } catch (e) {
      // في حال فشل GPS، نعتمد على القيم اليدوية
      _errorMessage = '';
    }

    setState(() {
      _locationLabel = 'الدولة: $_currentCountry\nالمدينة: $_currentCity';
    });

    // جلب المواقيت من API الأذان
    await _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final times = await AladhanPrayerTimes.getPrayerTimes(
        country: _currentCountry,
        city: _currentCity,
      );

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
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل جلب المواقيت: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _manualUpdate() async {
    _countryController.text = _currentCountry;
    _cityController.text = _currentCity;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحديد الدولة والمدينة',
            style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'الدولة (بالإنجليزية)'),
            ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'المدينة (بالإنجليزية)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تحديث'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _currentCountry = _countryController.text.trim();
        _currentCity = _cityController.text.trim();
        _isLoading = true;
        _locationLabel = 'الدولة: $_currentCountry\nالمدينة: $_currentCity';
      });
      await _fetchPrayerTimes();
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
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
            icon: const Icon(Icons.edit_location_alt),
            onPressed: _manualUpdate,
            tooltip: 'تغيير الدولة والمدينة',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchLocationAndTimes,
            tooltip: 'تحديث تلقائي بالموقع',
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
                  Text('جاري تحميل المواقيت...',
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
                        Icon(Icons.error_outline,
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
