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
import '../services/matching_service.dart';
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
      session = await isar.roomCleanupSessions.get(widget.sessionId!);
    } else if (widget.photoPath == null) {
      session = await isar.roomCleanupSessions.where().sortByCreatedAtDesc().findFirst();
    } else {
      final results = await GeminiService.analyzeRoomCleanupPhoto(widget.photoPath!);
      final List<DetectedItemData> detectedList = [];

      for (var itemMap in results) {
        final itemName = itemMap['name'].toString();
        final quantity = itemMap['quantity'] ?? 1;
        final List<String> tags = List<String>.from(itemMap['tags'] ?? []);

        final similarMatches = await MatchingService.findSimilarItems(itemName);
        
        int? matchedId;
        int confidence = 0;
        String? locationPath;
        String? recommendation;

        if (similarMatches.isNotEmpty && similarMatches.first.confidencePercent >= 45) {
          final bestMatch = similarMatches.first;
          matchedId = bestMatch.item.id;
          confidence = bestMatch.confidencePercent;

          if (bestMatch.item.shelfId != null) {
            final shelf = await isar.shelfs.get(bestMatch.item.shelfId!);
            if (shelf != null) {
              final storageUnit = await isar.storageUnits.get(shelf.storageUnitId);
              if (storageUnit != null) {
                final room = await isar.rooms.get(storageUnit.roomId);
                if (room != null) {
                  locationPath = '${room.name} ➔ ${storageUnit.name} ➔ ${shelf.name}';
                }
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
          ..matchedIsarItemId = matchedId
          ..matchConfidence = confidence;

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

  Future<void> _saveSessionState() async {
    if (_activeSession != null) {
      await isar.writeTxn(() async {
        await isar.roomCleanupSessions.put(_activeSession!);
      });
    }
  }

  Future<void> _showMatchSelectionDialog(DetectedItemData itemData) async {
    final similarMatches = await MatchingService.findSimilarItems(itemData.name);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Выбрать связь для "${itemData.name}"'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.add_circle, color: Colors.orange),
                  title: const Text('Создать как новый предмет'),
                  subtitle: const Text('Не связывать с существующими в базе'),
                  onTap: () async {
                    setState(() {
                      itemData.matchedIsarItemId = null;
                      itemData.locationPath = null;
                      itemData.matchConfidence = 0;
                    });
                    await _saveSessionState();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const Divider(),
                const Text('Похожие вещи в базе:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                if (similarMatches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Похожих вещей в базе не найдено', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ...similarMatches.map((match) {
                  return ListTile(
                    leading: const Icon(Icons.link, color: Colors.blue),
                    title: Text(match.item.name),
                    subtitle: Text('Совпадение: ${match.confidencePercent}%'),
                    trailing: itemData.matchedIsarItemId == match.item.id 
                        ? const Icon(Icons.check, color: Colors.green) 
                        : null,
                    onTap: () async {
                      setState(() {
                        itemData.matchedIsarItemId = match.item.id;
                        itemData.matchConfidence = match.confidencePercent;
                      });
                      
                      if (match.item.shelfId != null) {
                        final shelf = await isar.shelfs.get(match.item.shelfId!);
                        if (shelf != null) {
                          final storageUnit = await isar.storageUnits.get(shelf.storageUnitId);
                          if (storageUnit != null) {
                            final room = await isar.rooms.get(storageUnit.roomId);
                            if (room != null) {
                              itemData.locationPath = '${room.name} ➔ ${storageUnit.name} ➔ ${shelf.name}';
                            }
                          }
                        }
                      }

                      await _saveSessionState();
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
          ],
        );
      },
    );
  }

  Future<void> _editItem(DetectedItemData detectedItem) async {
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
        setState(() {
          detectedItem.name = item.name;
          detectedItem.quantity = item.quantity;
          detectedItem.tags = item.tags;
          detectedItem.matchedIsarItemId = item.id;
        });
        await _saveSessionState();
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
                        'Распознанные предметы (отметьте убранные):',
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
                              onTap: () => _editItem(itemData),
                              // Долгое нажатие открывает контекстное меню быстрых действий
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SafeArea(
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.check_circle, color: Colors.green),
                                            title: const Text('Положить на место'),
                                            subtitle: const Text('Сохранить вещь в базу и убрать из списка'),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              
                                              // Сохраняем вещь в базу (логика аналогична кнопке "Положить на место")
                                              await isar.writeTxn(() async {
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

                                                // Удаляем конкретный элемент из сессии
                                                _activeSession!.items.remove(itemData);

                                                if (_activeSession!.items.isEmpty) {
                                                  await isar.roomCleanupSessions.delete(_activeSession!.id);
                                                } else {
                                                  await isar.roomCleanupSessions.put(_activeSession!);
                                                }
                                              });

                                              setState(() {});
                                              if (_activeSession!.items.isEmpty && context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete, color: Colors.red),
                                            title: const Text('Удалить'),
                                            subtitle: const Text('Стереть и удалить из списка'),
                                            onTap: () async {
                                              Navigator.pop(context);

                                              // Удаляем только из списка сессии (без сохранения в базу)
                                              await isar.writeTxn(() async {
                                                _activeSession!.items.remove(itemData);

                                                if (_activeSession!.items.isEmpty) {
                                                  await isar.roomCleanupSessions.delete(_activeSession!.id);
                                                } else {
                                                  await isar.roomCleanupSessions.put(_activeSession!);
                                                }
                                              });

                                              setState(() {});
                                              if (_activeSession!.items.isEmpty && context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: itemData.isSelected,
                                          onChanged: (val) async {
                                            setState(() {
                                              itemData.isSelected = val ?? true;
                                            });
                                            await _saveSessionState();
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
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                          onPressed: () => _editItem(itemData),
                                          tooltip: 'Редактировать вещь',
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 8),
                                    InkWell(
                                      onTap: () => _showMatchSelectionDialog(itemData),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: itemData.matchedIsarItemId != null ? Colors.green.shade50 : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: itemData.matchedIsarItemId != null ? Colors.green.shade200 : Colors.orange.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              itemData.matchedIsarItemId != null ? Icons.link : Icons.help_outline,
                                              size: 16,
                                              color: itemData.matchedIsarItemId != null ? Colors.green : Colors.orange,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                itemData.matchedIsarItemId != null && itemData.locationPath != null
                                                    ? '🟢 В базе (${itemData.matchConfidence}%): ${itemData.locationPath}'
                                                    : '🟡 Новый предмет (нажмите для выбора связи)',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: itemData.matchedIsarItemId != null ? Colors.green.shade800 : Colors.orange.shade800,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
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
              padding: EdgeInsets.fromLTRB(
                16, 
                16, 
                16, 
                16 + MediaQuery.of(context).padding.bottom,
              ),
              color: Colors.white,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  // Выбираем только те вещи, которые отмечены чекбоксом (убранные)
                  final checkedItems = _activeSession!.items.where((e) => e.isSelected).toList();
                  if (checkedItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отметьте галочками вещи, которые вы убрали')),
                    );
                    return;
                  }

                  await isar.writeTxn(() async {
                    // 1. Сохраняем/обновляем убранные вещи в базе
                    for (var itemData in checkedItems) {
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

                    // 2. Удаляем из списка сессии ТОЛЬКО убранные (отмеченные) вещи
                    _activeSession!.items.removeWhere((item) => item.isSelected);

                    // 3. Проверяем: если в сессии больше не осталось неубранных вещей — полностью удаляем сессию
                    if (_activeSession!.items.isEmpty) {
                      await isar.roomCleanupSessions.delete(_activeSession!.id);
                    } else {
                      // Иначе сохраняем сессию с оставшимися неубранными вещами
                      await isar.roomCleanupSessions.put(_activeSession!);
                    }
                  });

                  if (context.mounted) {
                    if (_activeSession!.items.isEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Комната полностью убрана! Сессия завершена.')),
                      );
                    } else {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Убрано предметов: ${checkedItems.length}. Осталось в комнате: ${_activeSession!.items.length}')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text('Положить на место (${_activeSession!.items.where((e) => e.isSelected).length})', style: const TextStyle(fontSize: 16)),
              ),
            ),
    );
  }
}