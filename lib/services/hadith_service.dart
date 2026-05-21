import 'dart:convert';
import 'package:http/http.dart' as http;

class HadithService {
  static const String _apiKey = '\$2y\$10\$k3FTAaUDItwZde1lQZUUlons97yWZYM7Ah4z4JSAPQvoLWteVQC';
  static const String _baseUrl = 'https://hadithapi.com/api';

  /// يجلب أحاديث عشوائية
  static Future<List<Map<String, dynamic>>> getRandomHadiths({int count = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/hadiths/random?apiKey=$_apiKey&count=$count'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['hadiths']['data'] ?? []);
      } else {
        throw Exception('فشل جلب الأحاديث من API');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// يجلب أحاديث من كتاب محدد (مثال: صحيح البخاري)
  static Future<List<Map<String, dynamic>>> getHadithsByBook(String bookSlug, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/books/$bookSlug/hadiths?apiKey=$_apiKey&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['hadiths']['data'] ?? []);
      } else {
        throw Exception('فشل جلب أحاديث من كتاب $bookSlug');
      }
    } catch (e) {
      rethrow;
    }
  }
}
