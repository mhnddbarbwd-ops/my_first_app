import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quran_tajwid/flutter_quran_tajwid.dart';
import 'package:nafahat/services/gemini_service.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> {
  List<Map<String, dynamic>> _errors = [];
  String _currentSurah = 'الفاتحة';
  int _currentVerse = 1;
  bool _isListening = false;

  // محاكاة بدء التصحيح (يتم استبدالها بالربط الحقيقي لاحقًا)
  void _startListening() {
    setState(() {
      _isListening = true;
      _errors = [];
    });

    // محاكاة استقبال الأخطاء بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errors = GeminiService.getMockErrors(_currentSurah, _currentVerse);
          _isListening = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'معلم التجويد',
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // زر بدء التصحيح
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : colorScheme.primary,
            ),
            onPressed: _isListening ? null : _startListening,
            tooltip: 'بدء الاستماع',
          ),
        ],
      ),
      body: Column(
        children: [
          // الجزء العلوي: المصحف (RecitationScreen)
          Expanded(
            flex: 3,
            // استخدام const وإزالة UniqueKey لمنع إعادة التهيئة الداخلية
            child: const RecitationScreen(),
          ),
          // فاصل
          Divider(color: colorScheme.primary.withOpacity(0.2), height: 1),
          // الجزء السفلي: شريط الأخطاء
          Container(
            height: _errors.isEmpty ? 80 : 140,
            color: colorScheme.surface,
            child: _errors.isEmpty
                ? Center(
                    child: Text(
                      _isListening ? 'جاري الاستماع...' : 'اضغط على الميكروفون لبدء التصحيح',
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'تم اكتشاف ${_errors.length} ملاحظة',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(() => _errors = []),
                              child: Text('مسح', style: TextStyle(color: colorScheme.primary)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _errors.length,
                          itemBuilder: (context, index) {
                            final error = _errors[index];
                            final isSuccess = error['type'] == 'ممتاز';
                            return Container(
                              width: 180,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: isSuccess
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.05),
                                border: Border.all(
                                  color: isSuccess ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSuccess ? Icons.check_circle : Icons.warning_rounded,
                                    color: isSuccess ? Colors.green : Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          error['word']!,
                                          style: GoogleFonts.ibmPlexSansArabic(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          error['message']!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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