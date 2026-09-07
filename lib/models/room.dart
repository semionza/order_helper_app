import 'package:isar/isar.dart';

part 'room.g.dart';

@collection
class Room {
  Id id = Isar.autoIncrement;

  late String name; // Название комнаты (например, "Детская")
  late String icon; // Иконка или эмодзи
}