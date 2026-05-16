import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:my_first_app/services/database_service.dart';

class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  StreamSubscription<StepCount>? _subscription;
  final DatabaseService _databaseService = DatabaseService();

  // بدء الاستماع للخطوات
  void startListening() {
    _subscription = Pedometer.stepCountStream.listen((StepCount event) {
      _databaseService.addSteps(event.steps);
    });
  }

  // إيقاف الاستماع
  void stopListening() {
    _subscription?.cancel();
  }
}