import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyCl22yx6JbZc80-PCrdEhGfMaKPxe3_F9I';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// يحلل النص المنطوق من قبل المستخدم ويقارنه بالنص القرآني الصحيح
  static Future<List<Map<String, dynamic>>> analyzeRecitation({
    required String recognizedText,
    required String verseText,
  }) async {
    final prompt = '''
أنت معلم تجويد للقرآن الكريم.
النص القرآني الصحيح: "$verseText"
النص الذي تلفظ به الطالب: "$recognizedText"

قارن بينهما وأعطني قائمة بالأخطاء. لكل خطأ، أعطني:
- الكلمة (word)
- نوع الخطأ (مثلاً: خطأ في النطق, تجويد خفيف, حرف زائد)
- وصف مختصر للخطأ (message)

إذا كان النطق صحيحًا، أعط كلمة "ممتاز" في الحقل type مع كلمة الآية في word.

أعد الرد بصيغة JSON مصفوفة بالشكل:
[
  {"word": "...", "type": "...", "message": "..."}
]
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        // استخراج JSON من الرد
        final jsonStart = text.indexOf('[');
        final jsonEnd = text.lastIndexOf(']') + 1;
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = text.substring(jsonStart, jsonEnd);
          return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
        }
        return [];
      } else {
        throw Exception('فشل الاتصال بـ Gemini: ${response.body}');
      }
    } catch (e) {
      return [
        {'word': 'خطأ', 'type': 'فشل', 'message': 'تعذر تحليل التلاوة: $e'}
      ];
    }
  }
}
