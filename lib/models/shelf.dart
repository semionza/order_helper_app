import 'package:isar/isar.dart';

part 'shelf.g.dart';

@collection
class Shelf {
  Id id = Isar.autoIncrement;

  late String name;       // Название или номер (например, "Полка 3")
  late int storageUnitId; // ID мебели, в которой находится полка
  String? photoPath;      // Путь к фотографии этой полки с вещами
}