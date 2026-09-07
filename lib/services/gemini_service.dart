import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // Вставьте сюда ваш ключ от Gemini API (или используйте переменную окружения)
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  
  // Используем актуальную мультимодальную модель
  static const String _model = 'gemini-2.5-flash';

  static Future<List<Map<String, dynamic>>> analyzeShelfPhoto(String imagePath) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      debugPrint('Gemini API Key не настроен!');
      return [];
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey');

      final prompt = '''
      Проанализируй эту фотографию вещей или места хранения в доме.
      Верни строго JSON-массив объектов без какого-либо дополнительного текста, markdown-разметки или префиксов.
      Каждый объект должен содержать следующие поля:
      - "name": строка (название найденного предмета на русском языке)
      - "quantity": число (оценка количества, по умолчанию 1)
      - "tags": массив строк (от 1 до 3 категорий или тегов на русском, например: ["одежда", "зима"])
      
      Пример ответа:
      [
        {"name": "Книга по программированию", "quantity": 1, "tags": ["книги", "учеба"]},
        {"name": "Синяя кружка", "quantity": 2, "tags": ["посуда", "кухня"]}
      ]
      ''';

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidateText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (candidateText != null) {
          // Очищаем ответ от возможных маркдаун-оберток вида ```json ... ```
          String cleanedJson = candidateText.trim();
          if (cleanedJson.startsWith('```json')) {
            cleanedJson = cleanedJson.replaceFirst('```json', '').replaceFirst('```', '').trim();
          } else if (cleanedJson.startsWith('```')) {
            cleanedJson = cleanedJson.replaceFirst('```', '').replaceFirst('```', '').trim();
          }

          final List<dynamic> decodedList = jsonDecode(cleanedJson);
          return decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      } else {
        debugPrint('Ошибка Gemini API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Исключение при запросе к Gemini: $e');
    }

    return [];
  }
}