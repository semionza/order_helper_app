import 'package:isar/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  late String name;

  int quantity = 1;

  List<String> tags = [];

  String? photoPath; // Путь к фотографии конкретной вещи

  late int shelfId;
}