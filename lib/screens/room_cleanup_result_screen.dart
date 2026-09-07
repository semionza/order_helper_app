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

class RoomCleanupResultScreen extends StatefulWidget {
  final String? photoPath; // Может быть null, если открываем последнюю сохраненную сессию

  const RoomCleanupResultScreen({super.key, this.photoPath});

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
    // 1. Проверяем, есть ли уже сохраненная сессия в базе
    final existingSession = await isar.roomCleanupSessions.where().sortByCreatedAtDesc().findFirst();

    if (widget.photoPath == null && existingSession != null) {
      // Если фото не передано явно, но есть сохраненная сессия — загружаем её
      setState(() {
        _activeSession = existingSession;
        _isLoading = false;
      });
      return;
    }

    // 2. Если передано новое фото, выполняем анализ через Gemini
    if (widget.photoPath != null) {
      final results = await GeminiService.analyzeRoomCleanupPhoto(widget.photoPath!);

      final List<DetectedItemData> detectedList = [];

      for (var itemMap in results) {
        final itemName = itemMap['name'].toString();
        final quantity = itemMap['quantity'] ?? 1;
        final List<String> tags = List<String>.from(itemMap['tags'] ?? []);

        // Сверяем с Isar
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
          // Ищем рекомендации по тегам
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

      // Сохраняем новую сессию в Isar
      final newSession = RoomCleanupSession()
        ..photoPath = widget.photoPath!
        ..createdAt = DateTime.now()
        ..items = detectedList;

      await isar.writeTxn(() async {
        // Очищаем старые сессии, оставляем только последнюю
        await isar.roomCleanupSessions.clear();
        await isar.roomCleanupSessions.put(newSession);
      });

      setState(() {
        _activeSession = newSession;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Диалог редактирования конкретного распознанного предмета
  void _editDetectedItem(int index) {
    if (_activeSession == null) return;
    final itemData = _activeSession!.items[index];

    final nameController = TextEditingController(text: itemData.name);
    final qtyController = TextEditingController(text: itemData.quantity.toString());
    final tagsController = TextEditingController(text: itemData.tags.join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать предмет'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Количество'),
              ),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(labelText: 'Теги (через запятую)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  itemData.name = nameController.text.trim();
                  itemData.quantity = int.tryParse(qtyController.text) ?? 1;
                  itemData.tags = tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                });

                // Сохраняем изменения в базу сессий
                await isar.writeTxn(() async {
                  await isar.roomCleanupSessions.put(_activeSession!);
                });

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты уборки комнаты'),
        actions: [
          if (_activeSession != null && _activeSession!.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: 'Стереть результаты анализа',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Стереть результаты?'),
                    content: const Text('Сохраненный анализ неубранной комнаты будет удален.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () async {
                          await isar.writeTxn(() async {
                            await isar.roomCleanupSessions.clear();
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            setState(() {
                              _activeSession = null;
                            });
                          }
                        },
                        child: const Text('Стереть'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_activeSession == null || _activeSession!.items.isEmpty)
              ? const Center(
                  child: Text(
                    'Нет сохраненных результатов уборки.\nСделайте фото комнаты с главного экрана.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
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
                        'Разбросанные предметы (нажмите для редактирования):',
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
                              onTap: () => _editDetectedItem(index), // Открывает форму редактирования предмета
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
                          ..shelfId = null; // Без места

                        await isar.items.put(newItem);
                      }
                    }
                    // Удаляем сессию после сохранения в базу вещей
                    await isar.roomCleanupSessions.clear();
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Успешно сохранено предметов: ${selectedItems.length}')),
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