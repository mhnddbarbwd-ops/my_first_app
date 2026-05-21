import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quran_tajwid/flutter_quran_tajwid.dart';
import 'package:nafahat/services/gemini_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> {
  bool _hideText = false;
  bool _isRecording = false;
  List<Map<String, dynamic>> _errors = [];
  final _recorder = Record();

  // بدء التسجيل الحقيقي
  Future<void> _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      try {
        if (await _recorder.hasPermission()) {
          await _recorder.start();
          setState(() => _isRecording = true);

          // تسجيل لمدة 5 ثوانٍ كتجربة، ثم التوقف تلقائياً
          await Future.delayed(const Duration(seconds: 5));
          if (!mounted) return;

          final path = await _recorder.stop();
          setState(() => _isRecording = false);

          if (path != null) {
            _processAudioFile(path);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في التسجيل: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى منح إذن الميكروفون')),
        );
      }
    }
  }

  // معالجة الملف الصوتي: مؤقتاً نرسل نصاً تجريبياً، وسنضيف التعرف على الصوت لاحقاً
  Future<void> _processAudioFile(String filePath) async {
    // TODO: استخدم مكتبة speech_to_text لتحويل الصوت إلى نص عربي
    final recognizedText = 'الحمد لله رب العالمين'; // سيتم استبداله بالنص الفعلي
    const verseText = 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ';

    final result = await GeminiService.analyzeRecitation(
      recognizedText: recognizedText,
      verseText: verseText,
    );

    if (mounted) {
      setState(() {
        _errors = result;
      });
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
                const RecitationScreen(),
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
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? null : _startListening,
                  icon: Icon(_isRecording ? Icons.mic : Icons.mic_none),
                  label: Text(_isRecording ? 'جاري الاستماع...' : 'ابدأ التصحيح'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),
                const SizedBox(height: 16),
                if (_errors.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _errors.length,
                      itemBuilder: (context, index) {
                        final e = _errors[index];
                        final isSuccess = e['type'] == 'ممتاز';
                        return Card(
                          color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e['word'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(e['message'] ?? '', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
