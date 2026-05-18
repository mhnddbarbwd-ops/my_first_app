import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const FezApp());
}

class FezApp extends StatelessWidget {
  const FezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فِـز',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF006A6A),
        brightness: Brightness.light,
      ),
      home: const StepCounterPage(),
    );
  }
}

class StepCounterPage extends StatefulWidget {
  const StepCounterPage({super.key});

  @override
  State<StepCounterPage> createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  int _steps = 0;
  bool _permissionGranted = false;
  StreamSubscription<StepCount>? _stepSubscription;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    final status = await Permission.activityRecognition.request();
    if (mounted) {
      setState(() {
        _permissionGranted = status.isGranted;
      });
    }

    if (!status.isGranted) return;

    try {
      _stepSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (mounted) {
            setState(() {
              _steps = event.steps;
            });
          }
        },
        onError: (error) {},
      );
    } catch (e) {}
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('فِـز'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _permissionGranted ? Icons.check_circle : Icons.warning_amber_rounded,
              size: 48,
              color: _permissionGranted ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _permissionGranted ? 'الصلاحية ممنوحة' : 'الصلاحية مرفوضة',
              style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 40),
            Text(
              '$_steps',
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const Text(
              'خطوة',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
