import 'package:flutter/material.dart';

void main() {
  runApp(const DeathApp());
}

class DeathApp extends StatelessWidget {
  const DeathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الوفيات',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        textTheme: ThemeData.light().textTheme,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('الوفيات')),
        body: const Center(
          child: Text(
            'بسم الله الرحمن الرحيم',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
