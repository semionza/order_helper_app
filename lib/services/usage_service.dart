import '../app_config.dart';
import '../main.dart';
import '../models/usage_stats.dart';
import 'purchase_service.dart';

/// Учёт лимита бесплатных AI-анализов за месяц.
class UsageService {
  UsageService._();

  static bool get isPremium => PurchaseService.instance.isPremium.value;

  static String periodKeyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Возвращает статистику текущего месяца, сбрасывая счётчик при смене периода.
  static Future<UsageStats> currentStats() async {
    final now = DateTime.now();
    final key = periodKeyFor(now);

    var stats = await isar.usageStats.get(UsageStats.singletonId);
    if (stats == null) {
      stats = UsageStats()
        ..id = UsageStats.singletonId
        ..aiScanCount = 0
        ..periodKey = key
        ..periodStartedAt = DateTime(now.year, now.month);
      await isar.writeTxn(() async => isar.usageStats.put(stats!));
      return stats;
    }

    if (stats.periodKey != key) {
      stats
        ..aiScanCount = 0
        ..periodKey = key
        ..periodStartedAt = DateTime(now.year, now.month);
      await isar.writeTxn(() async => isar.usageStats.put(stats!));
    }
    return stats;
  }

  // --- AI-анализы ---

  static Future<int> aiScansUsedThisMonth() async {
    final stats = await currentStats();
    return stats.aiScanCount;
  }

  static Future<int> remainingFreeAiScans() async {
    if (isPremium) return AppConfig.maxFreeAiScansPerMonth;
    final used = await aiScansUsedThisMonth();
    final left = AppConfig.maxFreeAiScansPerMonth - used;
    return left < 0 ? 0 : left;
  }

  static Future<bool> canRunAiScan() async {
    if (isPremium) return true;
    final used = await aiScansUsedThisMonth();
    return used < AppConfig.maxFreeAiScansPerMonth;
  }

  /// Учитывает выполненный AI-анализ (для премиума ничего не меняет).
  static Future<void> registerAiScan() async {
    if (isPremium) return;
    final stats = await currentStats();
    await isar.writeTxn(() async {
      stats.aiScanCount += 1;
      await isar.usageStats.put(stats);
    });
  }

  /// Сброс счётчиков — удобно для ручного тестирования paywall.
  static Future<void> resetUsageForTesting() async {
    final stats = await currentStats();
    await isar.writeTxn(() async {
      stats.aiScanCount = 0;
      await isar.usageStats.put(stats);
    });
  }
}
