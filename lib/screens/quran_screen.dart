import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نفحات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.audio_file_rounded),
            onPressed: () {
              // ستُضاف شاشة التلاوات لاحقًا
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_rounded),
            onPressed: () {
              // ستُضاف شاشة قائمة السور لاحقًا
            },
          ),
        ],
      ),
      body: const PageviewQuran(
        initialPageNumber: 1,
      ),
    );
  }
}