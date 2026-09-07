import 'package:isar/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  late String name;

  int quantity = 1;

  List<String> tags = [];

  String? photoPath;

  int? shelfId; // Теперь поле может быть пустым (если место не выбрано)
}