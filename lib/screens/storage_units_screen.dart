import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/room.dart';
import '../models/storage_unit.dart';
import 'shelves_screen.dart';

class StorageUnitsScreen extends StatelessWidget {
  final Room room;

  const StorageUnitsScreen({super.key, required this.room});

  void _showAddStorageDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Мебель в комнате: ${room.name}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Например: Шкаф, Стеллаж, Комод'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final unit = StorageUnit()
                    ..name = name
                    ..roomId = room.id;

                  await isar.writeTxn(() async {
                    await isar.storageUnits.put(unit);
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(room.name)),
      body: StreamBuilder<List<StorageUnit>>(
        stream: isar.storageUnits.filter().roomIdEqualTo(room.id).watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final units = snapshot.data!;

          if (units.isEmpty) {
            return const Center(
              child: Text(
                'Здесь пока нет мебели.\nНажмите "+", чтобы добавить шкаф или стеллаж.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.kitchen, color: Colors.blue),
                  title: Text(unit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShelvesScreen(storageUnit: unit)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStorageDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}