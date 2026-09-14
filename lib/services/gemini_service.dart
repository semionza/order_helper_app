import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart'; // Импортируем наш конфиг

class GeminiService {
  // Используем актуальную модель и ключ из файла конфигурации
  static const String _model = 'gemini-3.6-flash';

  static Future<List<Map<String, dynamic>>> analyzeShelfPhoto(
    String imagePath, {
    required String languageCode,
  }) async {
    if (Config.geminiApiKey == 'YOUR_GEMINI_API_KEY' || Config.geminiApiKey.isEmpty) {
      debugPrint('Gemini API Key не настроен в lib/config.dart!');
      return [];
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=${Config.geminiApiKey}');

      final outputLanguage = _languageName(languageCode);
      final prompt = '''
      Analyze this photo of a shelf or household storage area.
      Return only a JSON array of objects, without extra text, Markdown, or prefixes.
      Write all item names and tags in $outputLanguage.
      Each object must contain:
      - "name": string
      - "quantity": number (estimated quantity, default 1)
      - "tags": array of 1 to 3 category strings

      Example structure:
      [
        {"name": "localized item name", "quantity": 1, "tags": ["localized tag"]}
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
  static Future<List<Map<String, dynamic>>> analyzeRoomCleanupPhoto(
    String imagePath, {
    required String languageCode,
  }) async {
    if (Config.geminiApiKey == 'YOUR_GEMINI_API_KEY' || Config.geminiApiKey.isEmpty) {
      debugPrint('Gemini API Key не настроен в lib/config.dart!');
      return [];
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=${Config.geminiApiKey}');

      final outputLanguage = _languageName(languageCode);
      final prompt = '''
      Analyze this photo of a room containing scattered items or clutter.
      Identify items that are out of place or need organizing.
      Return only a JSON array of objects, without extra text, Markdown, or prefixes.
      Write all item names and tags in $outputLanguage.
      Each object must contain:
      - "name": string
      - "quantity": number (estimated quantity, default 1)
      - "tags": array of 1 to 3 category strings

      Example structure:
      [
        {"name": "localized item name", "quantity": 1, "tags": ["localized tag"]}
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

  static String _languageName(String languageCode) {
    return switch (languageCode) {
      'ru' => 'Russian',
      'he' => 'Hebrew',
      _ => 'English',
    };
  }
}