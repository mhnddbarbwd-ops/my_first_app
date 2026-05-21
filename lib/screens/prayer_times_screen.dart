import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

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

  // إعدادات افتراضية (يمكن تغييرها من الواجهة)
  CalculationMethod _selectedMethod = CalculationMethod.umm_al_qura;
  Madhab _selectedMadhab = Madhab.shafi;
  double? _currentLat;
  double? _currentLng;

  final Map<String, CalculationMethod> _calculationMethods = {
    'تقويم أم القرى (مكة / اليمن / الخليج)': CalculationMethod.umm_al_qura,
    'رابطة العالم الإسلامي': CalculationMethod.muslim_world_league,
    'الهيئة المصرية العامة للمساحة': CalculationMethod.egyptian,
    'جامعة العلوم الإسلامية (كراتشي)': CalculationMethod.karachi,
    'الاتحاد الإسلامي بأمريكا الشمالية': CalculationMethod.north_america,
    'دبي / الإمارات': CalculationMethod.dubai,
    'الكويت': CalculationMethod.kuwait,
    'قطر': CalculationMethod.qatar,
  };

  @override
  void initState() {
    super.initState();
    _loadTimesFromGPS();
  }

  // 1. تحديد الموقع تلقائياً عبر GPS
  Future<void> _loadTimesFromGPS() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'GPS غير مفعل. قم بتفعيله أو أدخل الموقع يدوياً.';

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'تم رفض صلاحية الموقع.';
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'صلاحية الموقع مرفوضة بشكل دائم. استخدم البحث اليدوي.';
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentLat = pos.latitude;
      _currentLng = pos.longitude;

      String place = 'موقعك الحالي';
      try {
        final pm = await placemarkFromCoordinates(_currentLat!, _currentLng!);
        if (pm.isNotEmpty) {
          place = '${pm.first.locality ?? pm.first.administrativeArea ?? ''}, ${pm.first.country ?? ''}';
        }
      } catch (_) {}
      
      _locationText = place.trim() == ',' ? 'موقع محدد عبر GPS' : place;
      _calculateAdhanTimes();
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 2. البحث عن مدينة ودولة يدوياً (بدون GPS)
  Future<void> _searchLocationManually(String city, String country) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final query = '$city, $country';
      final locations = await locationFromAddress(query);
      
      if (locations.isNotEmpty) {
        _currentLat = locations.first.latitude;
        _currentLng = locations.first.longitude;
        _locationText = '$city, $country';
        _calculateAdhanTimes();
      } else {
        throw 'لم يتم العثور على الموقع. تأكد من صحة اسم المدينة والدولة.';
      }
    } catch (e) {
      setState(() {
        _error = 'تعذر العثور على الموقع، يرجى كتابة الاسم بشكل صحيح (مثال: صنعاء، اليمن).';
        _isLoading = false;
      });
    }
  }

  // 3. حساب المواقيت باستخدام مكتبة Adhan الدقيقة
  void _calculateAdhanTimes() {
    if (_currentLat == null || _currentLng == null) return;

    final coordinates = Coordinates(_currentLat!, _currentLng!);
    final params = _selectedMethod.getParameters();
    params.madhab = _selectedMadhab;

    final prayerTimes = PrayerTimes.today(coordinates, params);

    // استخدام intl لتنسيق الوقت بصيغة 12 ساعة مع (ص/م) بالعربية
    String formatTime(DateTime time) {
      return DateFormat('hh:mm a', 'ar').format(time);
    }

    setState(() {
      _prayerTimes = {
        'الفجر': formatTime(prayerTimes.fajr),
        'الشروق': formatTime(prayerTimes.sunrise),
        'الظهر': formatTime(prayerTimes.dhuhr),
        'العصر': formatTime(prayerTimes.asr),
        'المغرب': formatTime(prayerTimes.maghrib),
        'العشاء': formatTime(prayerTimes.isha),
      };
      _isLoading = false;
    });
  }

  // 4. نافذة منبثقة لضبط الموقع والإعدادات
  void _showSettingsDialog() {
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('إعدادات المواقيت', 
                  style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('البحث اليدوي عن الموقع:', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: countryController,
                      decoration: const InputDecoration(
                        labelText: 'الدولة (مثال: اليمن)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'المدينة (مثال: عدن)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (countryController.text.isNotEmpty && cityController.text.isNotEmpty) {
                            Navigator.pop(context);
                            _searchLocationManually(cityController.text.trim(), countryController.text.trim());
                          }
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('بحث عن الموقع'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('طريقة الحساب:', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
                    DropdownButton<CalculationMethod>(
                      isExpanded: true,
                      value: _selectedMethod,
                      items: _calculationMethods.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.value,
                          child: Text(e.key, style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _selectedMethod = val);
                          setState(() {
                            _selectedMethod = val;
                            _calculateAdhanTimes();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('المذهب الفقهي (لصلاة العصر):', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
                    DropdownButton<Madhab>(
                      isExpanded: true,
                      value: _selectedMadhab,
                      items: const [
                        DropdownMenuItem(value: Madhab.shafi, child: Text('شافعي، مالكي، حنبلي (الجمهور)')),
                        DropdownMenuItem(value: Madhab.hanafi, child: Text('حنفي')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _selectedMadhab = val);
                          setState(() {
                            _selectedMadhab = val;
                            _calculateAdhanTimes();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إغلاق', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

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
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'إعدادات الموقع والحساب',
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'استخدام الموقع الحالي',
            onPressed: _loadTimesFromGPS,
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
                  Text('جاري حساب المواقيت بدقة...',
                      style: GoogleFonts.ibmPlexSansArabic()),
                ],
              ),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexSansArabic(fontSize: 16, color: colorScheme.error)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showSettingsDialog,
                          icon: const Icon(Icons.settings),
                          label: Text('تحديد الموقع يدوياً', style: GoogleFonts.ibmPlexSansArabic()),
                        )
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // بطاقة الموقع الحالي
                      InkWell(
                        onTap: _showSettingsDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_locationText,
                                    style: GoogleFonts.ibmPlexSansArabic(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              Icon(Icons.edit_location_alt_rounded, color: colorScheme.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // قائمة مواقيت الصلاة
                      ..._prayerTimes.entries.map((e) {
                        final name = e.key;
                        final time = e.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
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
                                          fontSize: 18, fontWeight: FontWeight.bold)),
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
