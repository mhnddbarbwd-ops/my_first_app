import 'dart:math';

class GeminiService {
  static const String apiKey = 'AIzaSyCl22yx6JbZc80-PCrdEhGfMaKPxe3_F9I';

  // قائمة محاكاة لأخطاء التلاوة (يمكن ربطها لاحقًا بـ Gemini API حقيقي)
  static List<Map<String, dynamic>> getMockErrors(String surahName, int verseNumber) {
    // محاكاة أخطاء عشوائية بناءً على الآية
    final random = Random(verseNumber + surahName.length);
    final errors = <Map<String, dynamic>>[];

    // توليد أخطاء وهمية للتوضيح
    if (random.nextBool()) {
      errors.add({
        'word': 'الْحَمْدُ',
        'type': 'نطق',
        'message': 'لم تُمد الألف بشكل كافٍ (مد طبيعي)',
        'position': 0,
      });
    }
    if (random.nextBool()) {
      errors.add({
        'word': 'الرَّحْمَنِ',
        'type': 'تفخيم',
        'message': 'يجب تفخيم الراء لوقوعها بعد الفتح',
        'position': 3,
      });
    }
    if (random.nextBool()) {
      errors.add({
        'word': 'إِيَّاكَ',
        'type': 'تشديد',
        'message': 'لم تُظهر التشديد على الياء',
        'position': 5,
      });
    }
    if (errors.isEmpty) {
      errors.add({
        'word': 'جميع الكلمات',
        'type': 'ممتاز',
        'message': 'تلاوة صحيحة، أحسنت!',
        'position': -1,
      });
    }
    return errors;
  }
}