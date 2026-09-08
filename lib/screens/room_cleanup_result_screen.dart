import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/item.dart';
import '../models/shelf.dart';
import '../models/storage_unit.dart';
import '../models/room.dart';
import '../models/room_cleanup_session.dart';
import '../services/gemini_service.dart';
import '../widgets/edit_item_form_dialog.dart';

class RoomCleanupResultScreen extends StatefulWidget {
  final String? photoPath;
  final int? sessionId; // ID сессии, если открываем из истории

  const RoomCleanupResultScreen({super.key, this.photoPath, this.sessionId});

  @override
  State<RoomCleanupResultScreen> createState() => _RoomCleanupResultScreenState();
}

class _RoomCleanupResultScreenState extends State<RoomCleanupResultScreen> {
  bool _isLoading = true;
  RoomCleanupSession? _activeSession;

  @override
  void initState() {
    super.initState();
    _loadOrAnalyzeSession();
  }

  Future<void> _loadOrAnalyzeSession() async {
    RoomCleanupSession? session;

    if (widget.sessionId != null) {
      // Открываем конкретную сессию из истории
      session = await isar.roomCleanupSessions.get(widget.sessionId!);
    } else if (widget.photoPath == null) {
      // Открываем последнюю актуальную сессию
      session = await isar.roomCleanupSessions.where().sortByCreatedAtDesc().findFirst();
    } else {
      // Создаем новую сессию по новому фото
      final results = await GeminiService.analyzeRoomCleanupPhoto(widget.photoPath!);
      final List<DetectedItemData> detectedList = [];

      for (var itemMap in results) {
        final itemName = itemMap['name'].toString();
        final quantity = itemMap['quantity'] ?? 1;
        final List<String> tags = List<String>.from(itemMap['tags'] ?? []);

        final existingItem = await isar.items
            .filter()
            .nameContains(itemName, caseSensitive: false)
            .findFirst();

        String? locationPath;
        String? recommendation;

        if (existingItem != null && existingItem.shelfId != null) {
          final shelf = await isar.shelfs.get(existingItem.shelfId!);
          if (shelf != null) {
            final storageUnit = await isar.storageUnits.get(shelf.storageUnitId);
            if (storageUnit != null) {
              final room = await isar.rooms.get(storageUnit.roomId);
              if (room != null) {
                locationPath = '${room.name} ➔ ${storageUnit.name} ➔ ${shelf.name}';
              }
            }
          }
        } else {
          for (var dbItem in await isar.items.where().findAll()) {
            if (dbItem.shelfId != null && dbItem.tags.any((t) => tags.contains(t))) {
              final shelf = await isar.shelfs.get(dbItem.shelfId!);
              if (shelf != null) {
                final storageUnit = await isar.storageUnits.get(shelf.storageUnitId);
                if (storageUnit != null) {
                  final room = await isar.rooms.get(storageUnit.roomId);
                  if (room != null) {
                    recommendation = 'Похоже на "${dbItem.name}": положите в ${room.name} ➔ ${storageUnit.name} ➔ ${shelf.name}';
                    break;
                  }
                }
              }
            }
          }
          recommendation ??= 'Нет рекомендаций, положите в категорию "Без места"';
        }

        final data = DetectedItemData()
          ..name = itemName
          ..quantity = quantity
          ..tags = tags
          ..locationPath = locationPath
          ..recommendation = recommendation
          ..isSelected = true
          ..matchedIsarItemId = existingItem?.id;

        detectedList.add(data);
      }

      session = RoomCleanupSession()
        ..photoPath = widget.photoPath!
        ..createdAt = DateTime.now()
        ..items = detectedList;

      await isar.writeTxn(() async {
        await isar.roomCleanupSessions.put(session!);
      });
    }

    setState(() {
      _activeSession = session;
      _isLoading = false;
    });
  }

  // Открытие формы редактирования вещи (как в каталоге)
  Future<void> _editItem(DetectedItemData detectedItem) async {
    // Находим реальный Item в базе или создаем временный объект для формы
    Item item;
    if (detectedItem.matchedIsarItemId != null) {
      item = (await isar.items.get(detectedItem.matchedIsarItemId!)) ?? Item();
    } else {
      item = Item()
        ..name = detectedItem.name
        ..quantity = detectedItem.quantity
        ..tags = detectedItem.tags
        ..photoPath = _activeSession?.photoPath
        ..shelfId = null;
    }

    if (!context.mounted) return;

    await showEditItemFormDialog(
      context: context,
      item: item,
      onSaved: () async {
        // Синхронизируем изменения обратно в сессию
        setState(() {
          detectedItem.name = item.name;
          detectedItem.quantity = item.quantity;
          detectedItem.tags = item.tags;
          detectedItem.matchedIsarItemId = item.id;
        });
        if (_activeSession != null) {
          await isar.writeTxn(() async {
            await isar.roomCleanupSessions.put(_activeSession!);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты уборки комнаты'),
        actions: [
          if (_activeSession != null)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: 'Стереть результаты анализа',
              onPressed: () async {
                await isar.writeTxn(() async {
                  await isar.roomCleanupSessions.delete(_activeSession!.id);
                });
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_activeSession == null || _activeSession!.items.isEmpty)
              ? const Center(child: Text('Нет данных анализа.'))
              : Column(
                  children: [
                    SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: Image.file(File(_activeSession!.photoPath), fit: BoxFit.cover),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Распознанные предметы (нажмите для редактирования):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _activeSession!.items.length,
                        itemBuilder: (context, index) {
                          final itemData = _activeSession!.items[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: InkWell(
                              onTap: () => _editItem(itemData), // Открывает полную форму редактирования
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: itemData.isSelected,
                                      onChanged: (val) async {
                                        setState(() {
                                          itemData.isSelected = val ?? true;
                                        });
                                        await isar.writeTxn(() async {
                                          await isar.roomCleanupSessions.put(_activeSession!);
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itemData.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 2),
                                          Text('Кол-во: ${itemData.quantity} | Теги: ${itemData.tags.join(', ')}'),
                                          const SizedBox(height: 4),
                                          itemData.locationPath != null
                                              ? Text(
                                                  '🟢 Есть в базе: ${itemData.locationPath}',
                                                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                                                )
                                              : Text(
                                                  '💡 Рекомендация: ${itemData.recommendation}',
                                                  style: const TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.w600),
                                                ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.edit, size: 18, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: (_activeSession == null || _activeSession!.items.isEmpty)
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final selectedItems = _activeSession!.items.where((e) => e.isSelected).toList();
                  if (selectedItems.isEmpty) return;

                  await isar.writeTxn(() async {
                    for (var itemData in selectedItems) {
                      if (itemData.matchedIsarItemId != null) {
                        final matched = await isar.items.get(itemData.matchedIsarItemId!);
                        if (matched != null) {
                          matched.photoPath = _activeSession!.photoPath;
                          await isar.items.put(matched);
                        }
                      } else {
                        final newItem = Item()
                          ..name = itemData.name
                          ..quantity = itemData.quantity
                          ..tags = itemData.tags
                          ..photoPath = _activeSession!.photoPath
                          ..shelfId = null;

                        await isar.items.put(newItem);
                      }
                    }
                    // Удаляем текущую сессию из архива после успешного сохранения вещей
                    await isar.roomCleanupSessions.delete(_activeSession!.id);
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Сохранено предметов в базу: ${selectedItems.length}')),
                    );
                  }
                },
                icon: const Icon(Icons.save_alt),
                label: Text('Сохранить выбранное (${_activeSession!.items.where((e) => e.isSelected).length})', style: const TextStyle(fontSize: 16)),
              ),
            ),
    );
  }
}