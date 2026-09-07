import 'package:isar/isar.dart';

part 'storage_unit.g.dart';

@collection
class StorageUnit {
  Id id = Isar.autoIncrement;

  late String name; // Название (например, "Шкаф для одежды")
  late int roomId;  // ID комнаты, к которой относится мебель
}