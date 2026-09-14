import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../models/room.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roomsTitle),
      ),
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
                  leading: Text(room.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StorageUnitsScreen(room: room)),
                    );
                  },
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