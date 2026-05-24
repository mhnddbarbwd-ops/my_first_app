import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _is24HourFormat = false;
  
  // إعدادات الصلاة على النبي
  bool _prophetReminderEnabled = false;
  int _prophetReminderInterval = 60; // بالدقائق

  // إعدادات الأذان
  Map<String, bool> _prayerNotifications = {
    'الفجر': true,
    'الشروق': false, // مغلق افتراضياً
    'الظهر': true,
    'العصر': true,
    'المغرب': true,
    'العشاء': true,
  };

  String _selectedMuazzin = 'مكة المكرمة (علي ملا)';

  // Getters
  bool get is24HourFormat => _is24HourFormat;
  bool get prophetReminderEnabled => _prophetReminderEnabled;
  int get prophetReminderInterval => _prophetReminderInterval;
  Map<String, bool> get prayerNotifications => _prayerNotifications;
  String get selectedMuazzin => _selectedMuazzin;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _is24HourFormat = prefs.getBool('is24HourFormat') ?? false;
    _prophetReminderEnabled = prefs.getBool('prophetReminderEnabled') ?? false;
    _prophetReminderInterval = prefs.getInt('prophetReminderInterval') ?? 60;
    
    _prayerNotifications['الفجر'] = prefs.getBool('fajr_notif') ?? true;
    _prayerNotifications['الشروق'] = prefs.getBool('shuruq_notif') ?? false;
    _prayerNotifications['الظهر'] = prefs.getBool('dhuhr_notif') ?? true;
    _prayerNotifications['العصر'] = prefs.getBool('asr_notif') ?? true;
    _prayerNotifications['المغرب'] = prefs.getBool('maghrib_notif') ?? true;
    _prayerNotifications['العشاء'] = prefs.getBool('isha_notif') ?? true;

    _selectedMuazzin = prefs.getString('muazzin') ?? 'مكة المكرمة (علي ملا)';
    notifyListeners();
  }

  void toggleTimeFormat(bool value) async {
    _is24HourFormat = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is24HourFormat', value);
    notifyListeners();
  }

  void toggleProphetReminder(bool value) async {
    _prophetReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prophetReminderEnabled', value);
    // هنا مستقبلاً نضع كود جدولة الإشعار الفعلي
    notifyListeners();
  }

  void setProphetInterval(int minutes) async {
    _prophetReminderInterval = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prophetReminderInterval', minutes);
    notifyListeners();
  }

  void togglePrayerNotification(String prayer, bool value) async {
    _prayerNotifications[prayer] = value;
    final prefs = await SharedPreferences.getInstance();
    
    // حفظ حسب اسم الصلاة
    String key = '';
    switch(prayer) {
      case 'الفجر': key = 'fajr_notif'; break;
      case 'الشروق': key = 'shuruq_notif'; break;
      case 'الظهر': key = 'dhuhr_notif'; break;
      case 'العصر': key = 'asr_notif'; break;
      case 'المغرب': key = 'maghrib_notif'; break;
      case 'العشاء': key = 'isha_notif'; break;
    }
    if (key.isNotEmpty) await prefs.setBool(key, value);
    notifyListeners();
  }

  void setMuazzin(String muazzin) async {
    _selectedMuazzin = muazzin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('muazzin', muazzin);
    notifyListeners();
  }
}
