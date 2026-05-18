import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
      ),
      body: const PageviewQuran(
        initialPageNumber: 1,
      ),
    );
  }
}