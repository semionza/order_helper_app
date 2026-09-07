import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart'; // Импортируем наш конфиг

class GeminiService {
  // Используем актуальную модель и ключ из файла конфигурации
  static const String _model = 'gemini-3.6-flash';

  static Future<List<Map<String, dynamic>>> analyzeShelfPhoto(String imagePath) async {
    if (Config.geminiApiKey == 'YOUR_GEMINI_API_KEY' || Config.geminiApiKey.isEmpty) {
      debugPrint('Gemini API Key не настроен в lib/config.dart!');
      return [];
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=${Config.geminiApiKey}');

      final prompt = '''
      Проанализируй эту фотографию полки или места хранения в доме.
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

  // Анализ общей фотографии комнаты (поиск разбросанных вещей)
  static Future<List<Map<String, dynamic>>> analyzeRoomCleanupPhoto(String imagePath) async {
    if (Config.geminiApiKey == 'YOUR_GEMINI_API_KEY' || Config.geminiApiKey.isEmpty) {
      debugPrint('Gemini API Key не настроен в lib/config.dart!');
      return [];
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=${Config.geminiApiKey}');

      final prompt = '''
      Проанализируй эту фотографию комнаты, на которой видны разбросанные вещи или беспорядок.
      Выдели предметы, которые находятся не на своих местах или требуют уборки/организации.
      Верни строго JSON-массив объектов без какого-либо дополнительного текста, markdown-разметки или префиксов.
      Каждый объект должен содержать следующие поля:
      - "name": строка (название найденного предмета на русском языке)
      - "quantity": число (оценка количества, по умолчанию 1)
      - "tags": массив строк (от 1 до 3 категорий, например: ["беспорядок", "одежда"])
      
      Пример ответа:
      [
        {"name": "Брошенная куртка", "quantity": 1, "tags": ["одежда", "прихожая"]},
        {"name": "Чашка на столе", "quantity": 1, "tags": ["посуда", "комната"]}
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
        debugPrint('Ошибка Gemini API (Room Cleanup): ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Исключение при запросе к Gemini (Room Cleanup): $e');
    }

    return [];
  }
}