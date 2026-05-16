import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_first_app/models/alarm_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    final granted = await requestNotificationPermission();
    if (!granted) return;

    await cancelAlarm(alarm.id);

    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // تحويل إلى TZDateTime
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'تنبيهات فِـز',
      channelDescription: 'قناة المنبهات الرئيسية',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.hashCode,
      'فِـز: ${alarm.title}',
      'حان وقت ${alarm.category} - الهدف: ${alarm.goal}',
      tzDateTime,  // استخدم TZDateTime هنا
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    await Workmanager().registerOneOffTask(
      'alarm_${alarm.id}',
      'alarmTask',
      initialDelay: scheduledDate.difference(now),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Future<void> cancelAlarm(String id) async {
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);
    await Workmanager().cancelByUniqueName('alarm_$id');
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/alarm_tone.mp3'));
    return Future.value(true);
  });
}