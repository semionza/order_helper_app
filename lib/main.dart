import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/room.dart';
import 'models/storage_unit.dart';
import 'models/shelf.dart';
import 'models/item.dart';
import 'screens/home_screen.dart';

// Глобальная переменная для доступа к базе данных из любого места
late Isar isar;

void main() async {
  // Гарантируем инициализацию виджетов Flutter перед вызовом нативных модулей
  WidgetsFlutterBinding.ensureInitialized();

  // Получаем системную директорию для хранения базы данных
  final dir = await getApplicationDocumentsDirectory();

  // Открываем или создаем базу данных Isar со всеми нашими моделями
  isar = await Isar.open(
    [RoomSchema, StorageUnitSchema, ShelfSchema, ItemSchema],
    directory: dir.path,
  );

  runApp(const OrderHelperApp());
}

class OrderHelperApp extends StatelessWidget {
  const OrderHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Гид по порядку',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}