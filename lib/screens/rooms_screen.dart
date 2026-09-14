import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../main.dart';
import '../l10n/app_localizations.dart';
import '../models/room.dart';
import '../models/item.dart';
import '../models/shelf.dart';
import '../models/storage_unit.dart';
import 'storage_units_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  // Функция добавления новой комнаты через диалоговое окно
  void _showAddRoomDialog(BuildContext context) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.newRoom),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.roomHint),
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
                  final newRoom = Room()
                    ..name = name
                    ..icon = '🏠';

                  // Записываем комнату в базу данных Isar
                  await isar.writeTxn(() async {
                    await isar.rooms.put(newRoom);
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

  void _showRoomActionsDialog(BuildContext context, Room room) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: room.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(room.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.editRoom),
              onTap: () {
                Navigator.pop(dialogContext);
                _showEditRoomDialog(context, room, nameController);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(l10n.deleteRoom),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () async {
                Navigator.pop(dialogContext);
                await _confirmDeleteRoom(context, room);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRoomDialog(
    BuildContext context,
    Room room,
    TextEditingController controller,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editRoom),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.roomHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await isar.writeTxn(() async {
                  room.name = name;
                  await isar.rooms.put(room);
                });
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRoom(BuildContext context, Room room) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteRoomQuestion),
        content: Text(l10n.deleteRoomWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteRoom),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await isar.writeTxn(() async {
      final storageUnits = await isar.storageUnits
          .filter()
          .roomIdEqualTo(room.id)
          .findAll();

      for (final storageUnit in storageUnits) {
        final shelves = await isar.shelfs
            .filter()
            .storageUnitIdEqualTo(storageUnit.id)
            .findAll();

        for (final shelf in shelves) {
          final items = await isar.items
              .filter()
              .shelfIdEqualTo(shelf.id)
              .findAll();

          for (final item in items) {
            item.shelfId = null;
            await isar.items.put(item);
          }

          await isar.shelfs.delete(shelf.id);
        }

        await isar.storageUnits.delete(storageUnit.id);
      }

      await isar.rooms.delete(room.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.roomsTitle)),
      body: StreamBuilder<List<Room>>(
        // Подписываемся на изменения в таблице комнат Isar в реальном времени
        stream: isar.rooms.where().watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!;

          if (rooms.isEmpty) {
            return Center(
              child: Text(
                l10n.roomsEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Text(
                    room.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    room.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StorageUnitsScreen(room: room),
                      ),
                    );
                  },
                  onLongPress: () => _showRoomActionsDialog(context, room),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoomDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
