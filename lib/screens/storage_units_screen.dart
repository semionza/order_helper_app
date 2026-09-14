import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../models/room.dart';
import '../models/storage_unit.dart';
import '../models/shelf.dart';
import '../models/item.dart';
import 'shelves_screen.dart';

class StorageUnitsScreen extends StatelessWidget {
  final Room room;

  const StorageUnitsScreen({super.key, required this.room});

  void _showAddStorageDialog(BuildContext context) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.furnitureInRoom(room.name)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.furnitureHint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
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
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  // Диалог редактирования или удаления шкафа
  void _showEditStorageDialog(BuildContext context, StorageUnit unit) {
    final controller = TextEditingController(text: unit.name);
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.editStorageUnit),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.storageUnitNameLabel),
            autofocus: true,
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                // Подтверждение и удаление шкафа
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.deleteStorageUnitQuestion),
                    content: Text(l10n.deleteStorageUnitWarning),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await isar.writeTxn(() async {
                    // Находим все полки этого шкафа
                    final shelves = await isar.shelfs.filter().storageUnitIdEqualTo(unit.id).findAll();
                    
                    for (var shelf in shelves) {
                      // Находим все вещи на этой полке и отвязываем их (shelfId = null)
                      final items = await isar.items.filter().shelfIdEqualTo(shelf.id).findAll();
                      for (var item in items) {
                        item.shelfId = null;
                        await isar.items.put(item);
                      }
                      // Удаляем полку
                      await isar.shelfs.delete(shelf.id);
                    }

                    // Удаляем сам шкаф
                    await isar.storageUnits.delete(unit.id);
                  });

                  if (context.mounted) {
                    Navigator.pop(context); // Закрыть окно редактирования
                  }
                }
              },
              child: Text(l10n.deleteStorageUnit),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await isar.writeTxn(() async {
                    unit.name = name;
                    await isar.storageUnits.put(unit);
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            return Center(
              child: Text(
                l10n.storageUnitsEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                  subtitle: Text(l10n.holdToEdit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShelvesScreen(storageUnit: unit)),
                    );
                  },
                  // Добавлено длинное нажатие на шкаф
                  onLongPress: () => _showEditStorageDialog(context, unit),
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