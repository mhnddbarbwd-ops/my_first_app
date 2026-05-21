import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> {
  bool _hideText = false;
  bool _isRecording = false;
  final _recorder = Record();

  Future<void> _startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى منح إذن الميكروفون')),
        );
      }
      return;
    }

    if (await _recorder.hasPermission()) {
      await _recorder.start();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ التلاوة. التحليل الصوتي سيُضاف قريباً.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('معلم التجويد', style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w900, color: colorScheme.primary)),
        actions: [
          IconButton(
            icon: Icon(_hideText ? Icons.visibility_off : Icons.visibility, color: colorScheme.primary),
            onPressed: () => setState(() => _hideText = !_hideText),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                PageviewQuran(
                  initialPageNumber: 1,
                  onPageChanged: (_) {},
                ),
                if (_hideText)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(child: Text('النص مخفي', style: TextStyle(color: Colors.white, fontSize: 24))),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'إيقاف التسجيل' : 'ابدأ التلاوة'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
          ),
        ],
      ),
    );
  }
}
