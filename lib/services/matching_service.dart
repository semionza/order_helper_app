import 'package:isar/isar.dart';
import '../main.dart';
import '../models/item.dart';

class MatchResult {
  final Item item;
  final int confidencePercent; // Процент схожести (например, 65)

  MatchResult({required this.item, required this.confidencePercent});
}

class MatchingService {
  // Ищет похожие вещи в базе Isar и возвращает отсортированный список по степени схожести
  static Future<List<MatchResult>> findSimilarItems(String detectedName) async {
    final allItems = await isar.items.where().findAll();
    if (allItems.isEmpty) return [];

    final cleanedDetected = _tokenize(detectedName);
    List<MatchResult> results = [];

    for (var dbItem in allItems) {
      final cleanedDb = _tokenize(dbItem.name);
      
      // Считаем пересечение слов
      int commonWords = 0;
      for (var word in cleanedDetected) {
        if (cleanedDb.contains(word)) {
          commonWords++;
        }
      }

      if (commonWords > 0 || cleanedDetected.isEmpty) {
        // Простой расчет процента схожести на основе общих слов
        double score = (commonWords * 2) / (cleanedDetected.length + cleanedDb.length);
        int percent = (score * 100).clamp(20, 95).toInt();

        // Если названия вообще очень близкие, поднимаем процент
        if (dbItem.name.toLowerCase().contains(detectedName.toLowerCase()) ||
            detectedName.toLowerCase().contains(dbItem.name.toLowerCase())) {
          percent = percent < 75 ? 75 : percent;
        }

        results.add(MatchResult(item: dbItem, confidencePercent: percent));
      }
    }

    // Сортируем по убыванию процента схожести
    results.sort((a, b) => b.confidencePercent.compareTo(a.confidencePercent));
    
    // Возвращаем топ-5 лучших вариантов
    return results.take(5).toList();
  }

  static Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sа-яёא-ת]'), '')
        .split(' ')
        .where((w) => w.length > 2) // Игнорируем предлоги и союзы
        .toSet();
  }
}