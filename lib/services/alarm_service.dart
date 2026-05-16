import 'package:flutter/material.dart';
import 'package:my_first_app/models/alarm_model.dart';
import 'package:my_first_app/services/notification_service.dart';

class AlarmService extends ChangeNotifier {
  final List<AlarmModel> _alarms = [];

  List<AlarmModel> get alarms => _alarms;

  void addAlarm(AlarmModel alarm) {
    _alarms.add(alarm);
    NotificationService().scheduleAlarm(alarm);
    notifyListeners(); // هذا السطر السحري هو ما يُحدّث الواجهة
  }

  void deleteAlarm(String id) {
    _alarms.removeWhere((a) => a.id == id);
    NotificationService().cancelAlarm(id);
    notifyListeners();
  }

  void toggleAlarm(AlarmModel alarm, bool isActive) {
    alarm.isActive = isActive;
    if (isActive) {
      NotificationService().scheduleAlarm(alarm);
    } else {
      NotificationService().cancelAlarm(alarm.id);
    }
    notifyListeners();
  }
}