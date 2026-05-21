import 'package:flutter/material.dart';
import 'package:flutter_quran_tajwid/flutter_quran_tajwid.dart';

class TajweedRecitationWrapper extends StatefulWidget {
  const TajweedRecitationWrapper({super.key});

  @override
  State<TajweedRecitationWrapper> createState() => _TajweedRecitationWrapperState();
}

class _TajweedRecitationWrapperState extends State<TajweedRecitationWrapper> {
  static bool _quranServiceInitialized = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initializeOnce();
  }

  Future<void> _initializeOnce() async {
    if (!_quranServiceInitialized) {
      try {
        await QuranJsonService().initialize();
        _quranServiceInitialized = true;
      } catch (e) {
        // قد تحدث أخطاء لو تمت التهيئة مسبقًا، نتجاهلها بأمان
        debugPrint('تحذير: $e');
        _quranServiceInitialized = true; // نضعها true لمنع إعادة المحاولة
      }
    }
    if (mounted) {
      setState(() {
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    return const RecitationScreen();
  }
}