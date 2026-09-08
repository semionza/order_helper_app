import 'package:isar/isar.dart';

part 'room_cleanup_session.g.dart';

@embedded
class DetectedItemData {
  String name = '';
  int quantity = 1;
  List<String> tags = [];
  String? locationPath;
  String? recommendation;
  bool isSelected = true;
  int? matchedIsarItemId; // ID существующей вещи в Isar, если найдена
  int matchConfidence = 0; // Процент схожести
}

@collection
class RoomCleanupSession {
  Id id = Isar.autoIncrement;

  late String photoPath;
  late DateTime createdAt;

  List<DetectedItemData> items = [];
}