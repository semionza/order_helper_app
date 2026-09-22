import 'package:isar/isar.dart';

part 'usage_stats.g.dart';

/// Счётчик использования платных функций. В базе хранится одна запись с [singletonId].
@collection
class UsageStats {
  static const int singletonId = 0;

  Id id = singletonId;

  /// Количество AI-анализов, выполненных в текущем периоде.
  int aiScanCount = 0;

  /// Текущий период в формате `yyyy-MM`; при смене месяца счётчик сбрасывается.
  String periodKey = '';

  DateTime? periodStartedAt;
}
