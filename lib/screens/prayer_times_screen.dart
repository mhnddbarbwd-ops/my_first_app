import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _isLoading = true;
  String _locationText = 'جاري تحديد الموقع...';
  String? _error;

  // الإعدادات
  CalculationMethod _selectedMethod = CalculationMethod.umm_al_qura;
  Madhab _selectedMadhab = Madhab.shafi;
  double? _currentLat;
  double? _currentLng;

  // مواقيت الصلاة والعداد
  PrayerTimes? _prayerTimes;
  Timer? _timer;
  String _timeUntilNext = '--:--:--';
  Prayer _nextPrayerEnum = Prayer.none;
  String _nextPrayerName = '';

  // مشغل الصوت
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPrayer;
  bool _isAdhanPlaying = false;

  // تتبع آخر صلاة تم تشغيل الأذان لها لتجنب التكرار
  String? _lastTriggeredPrayer;
  DateTime? _lastTriggeredDate;

  final Map<String, CalculationMethod> _calculationMethods = {
    'تقويم أم القرى (مكة / اليمن / الخليج)': CalculationMethod.umm_al_qura,
    'رابطة العالم الإسلامي': CalculationMethod.muslim_world_league,
    'الهيئة المصرية العامة للمساحة': CalculationMethod.egyptian,
    'جامعة العلوم الإسلامية (كراتشي)': CalculationMethod.karachi,    'الاتحاد الإسلامي بأمريكا الشمالية': CalculationMethod.north_america,
    'دبي / الإمارات': CalculationMethod.dubai,
    'الكويت': CalculationMethod.kuwait,
    'قطر': CalculationMethod.qatar,
  };

  @override
  void initState() {
    super.initState();
    _loadTimesFromGPS();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsProvider>().addListener(_onSettingsChanged);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    if (mounted) {
      context.read<SettingsProvider>().removeListener(_onSettingsChanged);
    }
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

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
        throw 'صلاحية الموقع مرفوضة. استخدم البحث اليدوي.';
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
          final city = pm.first.locality ?? pm.first.administrativeArea ?? '';
          final country = pm.first.country ?? '';
          place = city.isNotEmpty && country.isNotEmpty ? '$city، $country' : country;
        }
      } catch (_) {}

      _locationText = place;
      _calculateAdhanTimes();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
        _locationText = '$city، $country';
        _calculateAdhanTimes();
      } else {
        throw 'لم يتم العثور على الموقع.';
      }
    } catch (e) {
      setState(() {
        _error = 'تعذر العثور على الموقع، يرجى كتابة الاسم بشكل صحيح (مثال: صنعاء، اليمن).';
        _isLoading = false;      });
    }
  }

  void _calculateAdhanTimes() {
    if (_currentLat == null || _currentLng == null) return;

    final coordinates = Coordinates(_currentLat!, _currentLng!);
    final params = _selectedMethod.getParameters();
    params.madhab = _selectedMadhab;

    final pt = PrayerTimes.today(coordinates, params);

    setState(() {
      _prayerTimes = pt;
      _isLoading = false;
      _lastTriggeredPrayer = null;
    });

    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (_prayerTimes == null || _currentLat == null || _currentLng == null) return;

    final now = DateTime.now();
    DateTime? nextTime;

    if (_prayerTimes!.nextPrayer() == Prayer.none) {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowParams = _selectedMethod.getParameters();
      tomorrowParams.madhab = _selectedMadhab;
      final tomorrowPt = PrayerTimes(
        Coordinates(_currentLat!, _currentLng!),
        DateComponents.from(tomorrow),
        tomorrowParams,
      );
      nextTime = tomorrowPt.fajr;
      _nextPrayerEnum = Prayer.fajr;
      _nextPrayerName = 'الفجر';
    } else {
      nextTime = _prayerTimes!.timeForPrayer(_prayerTimes!.nextPrayer());      _nextPrayerEnum = _prayerTimes!.nextPrayer();
      _nextPrayerName = _getArabicPrayerName(_nextPrayerEnum);
    }

    if (nextTime != null) {
      final diff = nextTime.difference(now);
      if (diff.isNegative) {
        _calculateAdhanTimes();
      } else {
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        
        if (diff.inSeconds <= 2 && diff.inSeconds >= 0) {
          _triggerAdhanIfEnabled(_nextPrayerName);
        }
        
        if (mounted) {
          setState(() {
            _timeUntilNext = '$hours:$minutes:$seconds';
          });
        }
      }
    }
  }

  Future<void> _triggerAdhanIfEnabled(String prayerName) async {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    
    if (!settings.prayerNotifications[prayerName]!) return;
    
    final today = DateTime.now();
    if (_lastTriggeredPrayer == prayerName && 
        _lastTriggeredDate?.day == today.day && 
        _lastTriggeredDate?.month == today.month && 
        _lastTriggeredDate?.year == today.year) {
      return;
    }
    
    await _playAdhanAudio(settings.getMuazzinAudioPath());
    
    _lastTriggeredPrayer = prayerName;
    _lastTriggeredDate = today;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [              Icon(Icons.mosque, color: Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: 12),
              Expanded(child: Text('🕌 حان وقت صلاة $prayerName', style: GoogleFonts.ibmPlexSansArabic())),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _playAdhanAudio(String audioPath) async {
    if (_isAdhanPlaying) return;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(audioPath));
      _isAdhanPlaying = true;
      
      // ✅ تم التعديل: استخدام onPlayerComplete (الطريقة الصحيحة في audioplayers 6.x)
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isAdhanPlaying = false;
          });
        }
      });
      
      // ✅ تم التعديل: استخدام onPlayerError بدلاً من onError (في الإصدار 6.x)
      _audioPlayer.onPlayerError.listen((event) {
        if (mounted) {
          setState(() {
            _isAdhanPlaying = false;
          });
        }
        debugPrint('❌ خطأ في تشغيل الأذان: ${event.message}');
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAdhanPlaying = false;
        });
      }
      debugPrint('❌ خطأ في تشغيل الأذان: $e');
    }
  }

  Widget _buildAdhanControls() {    if (!_isAdhanPlaying) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            'جاري تشغيل الأذان...',
            style: GoogleFonts.ibmPlexSansArabic(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.stop_circle_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _audioPlayer.stop(),
          ),
        ],
      ),
    );
  }

  String _getArabicPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'الفجر';
      case Prayer.sunrise: return 'الشروق';
      case Prayer.dhuhr: return 'الظهر';
      case Prayer.asr: return 'العصر';
      case Prayer.maghrib: return 'المغرب';
      case Prayer.isha: return 'العشاء';
      case Prayer.none: return '';
    }
  }

  void _showSettingsSheet() {
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    showModalBottomSheet(      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('إعدادات الموقع والمواقيت',
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 24),

                    Text('البحث اليدوي:', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: countryController,
                            decoration: InputDecoration(
                              hintText: 'الدولة (اليمن)',
                              prefixIcon: const Icon(Icons.flag_rounded),
                              filled: true,                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: cityController,
                            decoration: InputDecoration(
                              hintText: 'المدينة (صنعاء)',
                              prefixIcon: const Icon(Icons.location_city_rounded),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (countryController.text.isNotEmpty && cityController.text.isNotEmpty) {
                            Navigator.pop(context);
                            _searchLocationManually(cityController.text.trim(), countryController.text.trim());
                          }
                        },
                        child: Text('تحديث الموقع', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),

                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                    Text('طريقة الحساب الفلكي:', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(                        child: DropdownButton<CalculationMethod>(
                          isExpanded: true,
                          value: _selectedMethod,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                          items: _calculationMethods.entries.map((e) {
                            return DropdownMenuItem(
                              value: e.value,
                              child: Text(e.key, style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => _selectedMethod = val);
                              setState(() {
                                _selectedMethod = val;
                                _calculateAdhanTimes();
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text('المذهب الفقهي (لصلاة العصر):', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Madhab>(
                          isExpanded: true,
                          value: _selectedMadhab,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                          items: const [
                            DropdownMenuItem(value: Madhab.shafi, child: Text('شافعي، مالكي، حنبلي (الجمهور)')),
                            DropdownMenuItem(value: Madhab.hanafi, child: Text('حنفي')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => _selectedMadhab = val);
                              setState(() {
                                _selectedMadhab = val;
                                _calculateAdhanTimes();
                              });
                            }
                          },                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
        title: Text('مواقيت الصلاة', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'إعدادات المواقيت',
            onPressed: _showSettingsSheet,
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
                  Text('جاري التجهيز...', style: GoogleFonts.ibmPlexSansArabic()),
                ],
              ),
            )
          : _error != null
              ? _buildErrorView(colorScheme)
              : _buildMainContent(theme),
    );
  }

  Widget _buildErrorView(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: colorScheme.error.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.ibmPlexSansArabic(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showSettingsSheet,
              icon: const Icon(Icons.search_rounded),
              label: Text('البحث يدوياً', style: GoogleFonts.ibmPlexSansArabic()),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    if (_prayerTimes == null) return const SizedBox();

    final prayers = [
      {'enum': Prayer.fajr, 'name': 'الفجر', 'time': _prayerTimes!.fajr, 'icon': Icons.nightlight_round},
      {'enum': Prayer.sunrise, 'name': 'الشروق', 'time': _prayerTimes!.sunrise, 'icon': Icons.wb_twilight_rounded},
      {'enum': Prayer.dhuhr, 'name': 'الظهر', 'time': _prayerTimes!.dhuhr, 'icon': Icons.wb_sunny_rounded},
      // ✅ تم التعديل: partly_cloudy_day غير موجود، استبدلناه بـ cloud_queue
      {'enum': Prayer.asr, 'name': 'العصر', 'time': _prayerTimes!.asr, 'icon': Icons.cloud_queue},
      {'enum': Prayer.maghrib, 'name': 'المغرب', 'time': _prayerTimes!.maghrib, 'icon': Icons.brightness_6_rounded},
      {'enum': Prayer.isha, 'name': 'العشاء', 'time': _prayerTimes!.isha, 'icon': Icons.brightness_3_rounded},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
              ],            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded, color: theme.colorScheme.onPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(_locationText, style: GoogleFonts.ibmPlexSansArabic(color: theme.colorScheme.onPrimary, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 24),
                Text('الصلاة القادمة', style: GoogleFonts.ibmPlexSansArabic(color: theme.colorScheme.onPrimary.withOpacity(0.8), fontSize: 16)),
                const SizedBox(height: 4),
                Text(_nextPrayerName, style: GoogleFonts.ibmPlexSansArabic(color: theme.colorScheme.onPrimary, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, color: theme.colorScheme.onPrimary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _timeUntilNext,
                        style: GoogleFonts.ibmPlexSansArabic(color: theme.colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _buildAdhanControls(),
          const SizedBox(height: 16),
          
          ...prayers.map((p) {
            final prayerEnum = p['enum'] as Prayer;
            final isNext = prayerEnum == _nextPrayerEnum;
            final timeDate = p['time'] as DateTime;
            final formattedTime = DateFormat('hh:mm a', 'ar').format(timeDate);
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isNext ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isNext ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: isNext ? [
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                ] : [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isNext ? theme.colorScheme.onPrimary.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          p['icon'] as IconData,
                          color: isNext ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        p['name'] as String,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 18,
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                          color: isNext ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formattedTime,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isNext ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                    ),                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}