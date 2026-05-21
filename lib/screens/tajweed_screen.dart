import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran/quran_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:nafahat/services/gemini_service.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> {
  bool _hideText = false;
  bool _isListening = false;
  bool _isLoading = false;
  String _recognizedText = '';
  List<Map<String, dynamic>> _errors = [];
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          _stopListening();
        }
      },
    );
  }

  Future<void> _startListening() async {
    // 1. طلب إذن الميكروفون
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى منح إذن الميكروفون')),
        );
      }
      return;
    }

    // 2. التحقق من توفر خدمة التعرف الصوتي
    if (!_speech.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمة التعرف الصوتي غير متوفرة على جهازك')),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _errors = [];
    });

    // 3. بدء الاستماع مع إعدادات مناسبة للعربية
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),   // أقصى مدة 30 ثانية
      pauseFor: const Duration(seconds: 5),     // يتوقف تلقائيًا بعد 5 ثوانٍ من الصمت
      localeId: 'ar',                           // اللغة العربية
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    if (_recognizedText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم التعرف على أي كلام')),
        );
      }
      return;
    }

    // 4. إرسال النص إلى Gemini
    setState(() => _isLoading = true);
    const correctVerse = 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ';
    final result = await GeminiService.analyzeRecitation(
      recognizedText: _recognizedText,
      verseText: correctVerse,
    );

    if (mounted) {
      setState(() {
        _errors = result;
        _isLoading = false;
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
                const QuranPage(pageNumber: 1),
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
          if (_recognizedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ما سمعته: "$_recognizedText"',
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: (_isListening || _isLoading) ? null : _startListening,
                  icon: _isListening
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.mic),
                  label: Text(_isListening ? 'استمع...' : _isLoading ? 'جاري التحليل...' : 'ابدأ التصحيح'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),
                if (_isListening)
                  TextButton(
                    onPressed: _stopListening,
                    child: const Text('إيقاف'),
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
