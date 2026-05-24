import 'dart:async';
import 'dart:convert';
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

  // مفاتيح التخزين
  static const String _keyLastScheduledDate = 'prayer_last_scheduled_date';
  static const String _keyUserLat = 'prayer_user_lat';
  static const String _keyUserLng = 'prayer_user_lng';
  
  // ✅ مفاتيح نظام السجلات الداخلي
  static const String _keyLogs = 'prayer_service_logs';
  static const int _maxLogs = 50; // الاحتفاظ بآخر 50 سجل فقط

  // ✅ دالة مساعدة: إضافة سجل مع طابع زمني
  Future<void> _log(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final timestamp = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final logEntry = '[$timestamp] $message';
    
    // جلب السجلات الحالية
    final existingLogs = prefs.getStringList(_keyLogs) ?? [];
    existingLogs.add(logEntry);
    
    // الحفاظ على آخر _maxLogs سجل فقط
    if (existingLogs.length > _maxLogs) {
      existingLogs.removeRange(0, existingLogs.length - _maxLogs);
    }
    
    await prefs.setStringList(_keyLogs, existingLogs);
  }
  
  // ✅ دالة عامة: جلب السجلات لعرضها في الإعدادات
  static Future<List<String>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();    return prefs.getStringList(_keyLogs) ?? [];
  }
  
  // ✅ دالة عامة: مسح السجلات
  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLogs);
  }

  Future<void> init() async {
    await _log('🔹 خدمة الأذان: بدء التهيئة');
    
    if (_isInitialized) {
      await _log('⚠️ الخدمة مهيأة مسبقاً، تخطي التهيئة');
      return;
    }
    
    try {
      tz.initializeTimeZones();
      await _log('✅ تم تهيئة المناطق الزمنية');
      
      await _scheduleTodaysPrayers();
      await _log('✅ اكتملت جدولة صلوات اليوم');
      
      _dailyScheduler = Timer.periodic(const Duration(hours: 24), (timer) async {
        await _log('🔄 فحص يومي: بدء إعادة جدولة الصلوات');
        await _scheduleTodaysPrayers();
      });
      
      _isInitialized = true;
      await _log('✅ الخدمة مهيأة وجاهزة');
    } catch (e, stack) {
      await _log('❌ خطأ فادح في التهيئة: $e');
      await _log('📋 تتبع الخطأ: $stack');
    }
  }

  Future<Coordinates?> _getUserCoordinates() async {
    await _log('📍 طلب إحداثيات المستخدم');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      double? lat = prefs.getDouble(_keyUserLat);
      double? lng = prefs.getDouble(_keyUserLng);
      
      if (lat != null && lng != null) {
        await _log('✅ استخدام الإحداثيات المحفوظة: ($lat, $lng)');
        return Coordinates(lat, lng);
      }
      await _log('⚠️ لا توجد إحداثيات محفوظة، طلب من الجهاز');      
      LocationPermission permission = await Geolocator.checkPermission();
      await _log('🔐 إذن الموقع الحالي: $permission');
      
      if (permission == LocationPermission.denied) {
        await _log('⚠️ إذن الموقع مرفوض، طلب الإذن');
        permission = await Geolocator.requestPermission();
        await _log('🔐 نتيجة طلب الإذن: $permission');
      }
      
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        await _log('❌ فشل الحصول على إذن الموقع، العودة');
        return null;
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      await _log('✅ تم الحصول على الموقع: (${position.latitude}, ${position.longitude})');
      
      await prefs.setDouble(_keyUserLat, position.latitude);
      await prefs.setDouble(_keyUserLng, position.longitude);
      await _log('💾 تم حفظ الإحداثيات');
      
      return Coordinates(position.latitude, position.longitude);
    } catch (e, stack) {
      await _log('❌ خطأ في الحصول على الموقع: $e');
      await _log('📋 تتبع الخطأ: $stack');
      return null;
    }
  }

  Future<void> _scheduleTodaysPrayers() async {
    await _log('📅 بدء جدولة صلوات اليوم');
    
    final coordinates = await _getUserCoordinates();
    if (coordinates == null) {
      await _log('❌ إحداثيات المستخدم غير متوفرة، إلغاء الجدولة');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastScheduled = prefs.getString(_keyLastScheduledDate);
    if (lastScheduled == todayStr) {
      await _log('⚠️ تم الجدولة لهذا اليوم مسبقاً ($lastScheduled)، تخطي');
      return;
    }    await _log('🆓 اليوم غير مجدول، بدء الحساب');

    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(coordinates, params);
    await _log('✅ تم حساب المواقيت: الفجر=${prayerTimes.fajr}, العشاء=${prayerTimes.isha}');

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

    await prefs.setString(_keyLastScheduledDate, todayStr);
    await _log('✅ اكتملت جدولة جميع الصلوات، تاريخ: $todayStr');
  }

  Future<void> _scheduleSinglePrayer(String prayerName, DateTime prayerTime, String prefsKey) async {
    await _log('🔔 فحص صلاة $prayerName');
    
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(prefsKey) ?? true;
    
    if (!isEnabled) {
      await _log('⚪ صلاة $prayerName غير مفعلة في الإعدادات، تخطي');
      return;
    }
    await _log('✅ صلاة $prayerName مفعلة، متابعة');

    final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    
    if (scheduledDate.isBefore(now)) {
      await _log('⚠️ وقت $prayerName قد فات ($scheduledDate < $now)، تخطي');
      return;
    }
    await _log('⏰ وقت $prayerName المُجدول: $scheduledDate (الفرق: ${scheduledDate.difference(now).inMinutes} دقيقة)');

    final selectedMuazzin = prefs.getString('muazzin') ?? 'علي الملا';    final soundResourceName = _getSoundResourceName(selectedMuazzin);
    await _log('🎵 المؤذن المختار: $selectedMuazzin → ملف الصوت: $soundResourceName');

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

    try {
      await _log('📤 محاولة جدولة إشعار لـ $prayerName (ID: ${prayerName.hashCode})');
      
      // ✅ تم التعديل: zonedSchedule تعيد Future<void> وليس Future<bool>
      // لذا نكتفي بانتظار اكتمالها دون مقارنة النتيجة
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
      
      // إذا وصلنا لهنا بدون استثناء، فالجدولة نجحت
      await _log('✅ نجحت جدولة $prayerName');
    } catch (e, stack) {
      await _log('❌ فشل جدولة $prayerName: $e');
      await _log('📋 تتبع الخطأ: $stack');
    }
  }

  String _getSoundResourceName(String selectedMuazzin) {
    final muazzinFiles = {
      'ناصر القطامي': 'adhan_nasser',
      'عمر هشام العربي': 'adhan_omar',
      'علي الملا': 'adhan_ali',
      'مروان قصاص': 'adhan_marwan',
    };
    return muazzinFiles[selectedMuazzin] ?? 'adhan_ali';  }

  Future<void> reschedule() async {
    await _log('🔄 طلب إعادة جدولة فورية');
    await _notifications.cancelAll();
    await _log('🗑️ تم إلغاء جميع الإشعارات السابقة');
    _isInitialized = false;
    await init();
  }

  void dispose() {
    _dailyScheduler?.cancel();
    // ✅ تم التعديل: إزالة _log من dispose لأنها غير متزامنة وقد تسبب مشاكل عند الإغلاق
  }
}