import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class PrayerTimeService {
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._internal();

  final FlutterLocalNotificationsPlugin _notifications = flutterLocalNotificationsPlugin;
  Timer? _dailyScheduler;
  bool _isInitialized = false;

  static const String _keyLastScheduledDate = 'prayer_last_scheduled_date';
  static const String _keyUserLat = 'prayer_user_lat';
  static const String _keyUserLng = 'prayer_user_lng';

  Future<void> init() async {
    if (_isInitialized) return;
    
    tz.initializeTimeZones();
    await _scheduleTodaysPrayers();
    
    _dailyScheduler = Timer.periodic(const Duration(hours: 24), (timer) async {
      await _scheduleTodaysPrayers();
    });
    
    _isInitialized = true;
  }

  Future<Coordinates?> _getUserCoordinates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      double? lat = prefs.getDouble(_keyUserLat);
      double? lng = prefs.getDouble(_keyUserLng);
      
      if (lat != null && lng != null) {
        return Coordinates(lat, lng);
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||           permission == LocationPermission.deniedForever) {
        return null;
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      await prefs.setDouble(_keyUserLat, position.latitude);
      await prefs.setDouble(_keyUserLng, position.longitude);
      
      return Coordinates(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  Future<void> _scheduleTodaysPrayers() async {
    final coordinates = await _getUserCoordinates();
    if (coordinates == null) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastScheduled = prefs.getString(_keyLastScheduledDate);
    if (lastScheduled == todayStr) return;

    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(coordinates, params);

    final prayers = [
      {'name': 'الفجر', 'time': prayerTimes.fajr, 'key': 'fajr_notif'},
      {'name': 'الشروق', 'time': prayerTimes.sunrise, 'key': 'shuruq_notif'},
      {'name': 'الظهر', 'time': prayerTimes.dhuhr, 'key': 'dhuhr_notif'},
      {'name': 'العصر', 'time': prayerTimes.asr, 'key': 'asr_notif'},
      {'name': 'المغرب', 'time': prayerTimes.maghrib, 'key': 'maghrib_notif'},
      {'name': 'العشاء', 'time': prayerTimes.isha, 'key': 'isha_notif'},
    ];

    for (var prayer in prayers) {
      await _scheduleSinglePrayer(
        prayer['name'] as String,
        prayer['time'] as DateTime,
        prayer['key'] as String,
      );
    }

    await prefs.setString(_keyLastScheduledDate, todayStr);  }

  Future<void> _scheduleSinglePrayer(String prayerName, DateTime prayerTime, String prefsKey) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(prefsKey) ?? true;
    
    if (!isEnabled) return;

    final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    
    if (scheduledDate.isBefore(now)) return;

    final selectedMuazzin = prefs.getString('muazzin') ?? 'علي الملا';
    final soundResourceName = _getSoundResourceName(selectedMuazzin);

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات الأذان ومواقيت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundResourceName),
      enableVibration: true,
      enableLights: true,
      visibility: NotificationVisibility.public,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      prayerName.hashCode,
      '🕌 حان وقت صلاة $prayerName',
      'اللهم صل على محمد وآل محمد',
      scheduledDate,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // دالة مساعدة: تحويل اسم المؤذن إلى اسم ملف الصوت في res/raw/
  // ملاحظة: لا تضيف .mp3 أو أي مسار، فقط اسم الملف بالأحرف الإنجليزية الصغيرة
  String _getSoundResourceName(String selectedMuazzin) {
    final muazzinFiles = {
      'ناصر القطامي': 'adhan_nasser',
      'عمر هشام العربي': 'adhan_omar',
      'علي الملا': 'adhan_ali',      'مروان قصاص': 'adhan_marwan',
    };
    return muazzinFiles[selectedMuazzin] ?? 'adhan_ali';
  }

  Future<void> reschedule() async {
    await _notifications.cancelAll();
    _isInitialized = false;
    await init();
  }

  void dispose() {
    _dailyScheduler?.cancel();
  }
}