import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../models/shelf.dart';
import '../models/item.dart';
import '../models/storage_unit.dart';
import '../models/room.dart';
import 'cleanup_screen.dart';

class ItemsScreen extends StatefulWidget {
  final Shelf shelf;

  const ItemsScreen({super.key, required this.shelf});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  // Список доступных языков для голосового ввода
  static int _currentLangIndex = 0;
  final List<Map<String, String>> _languages = [
    {'code': 'ru_RU', 'label': 'RU'},
    {'code': 'en_US', 'label': 'EN'},
    {'code': 'he_IL', 'label': 'HE'},
  ];

  void _cycleLanguage() {
    setState(() {
      _currentLangIndex = (_currentLangIndex + 1) % _languages.length;
    });
  }
  // Универсальный диалог для создания или редактирования вещи
  void _showItemDialog(BuildContext context, {Item? itemToEdit}) {
    final isEditing = itemToEdit != null;
    
    final nameController = TextEditingController(text: isEditing ? itemToEdit.name : '');
    final quantityController = TextEditingController(text: isEditing ? itemToEdit.quantity.toString() : '1');
    final tagsController = TextEditingController(text: isEditing ? itemToEdit.tags.join(', ') : '');
    
    String? itemPhotoPath = isEditing ? itemToEdit.photoPath : null;
    int? selectedShelfId = isEditing ? itemToEdit.shelfId : widget.shelf.id;

    final stt.SpeechToText speech = stt.SpeechToText();
    bool isListening = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void listen() async {
              if (!isListening) {
                bool available = await speech.initialize();
                if (available) {
                  setDialogState(() => isListening = true);
                  
                  final activeLocaleId = _languages[_currentLangIndex]['code'];
                  debugPrint('DEBUG: Запуск голосового ввода с локалью -> $activeLocaleId');

                  speech.listen(
                    localeId: activeLocaleId,
                    onResult: (val) {
                      setDialogState(() {
                        nameController.text = val.recognizedWords;
                      });
                    },
                  );
                }
              } else {
                setDialogState(() => isListening = false);
                speech.stop();
              }
            }

            return AlertDialog(
              title: Text(isEditing ? 'Редактировать вещь' : 'Новая вещь'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название с микрофоном и переключателем языка
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Название вещи'),
                            autofocus: true,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Клик по языковому бейджу переключает язык циклично
                        InkWell(
                          onTap: () {
                            setDialogState(() {
                              _currentLangIndex = (_currentLangIndex + 1) % _languages.length;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.blue.shade50,
                            ),
                            child: Text(
                              _languages[_currentLangIndex]['label']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ),
                        // Кнопка микрофона: обычный тап — запись, долгое нажатие — смена языка
                        IconButton(
                          icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: isListening ? Colors.red : Colors.blue),
                          onPressed: listen,
                          onLongPress: () {
                            setDialogState(() {
                              _currentLangIndex = (_currentLangIndex + 1) % _languages.length;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Язык изменен на: ${_languages[_currentLangIndex]['label']}'),
                                duration: const Duration(milliseconds: 600),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Количество'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(labelText: 'Теги (через запятую)', hintText: 'одежда, зима'),
                    ),
                    const SizedBox(height: 16),

                    // Выбор местоположения (Полка / Без места)
                    const Text('Место хранения:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    FutureBuilder<List<ShelfInfoDropdown>>(
                      future: _loadAllShelvesForDropdown(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const LinearProgressIndicator();
                        
                        final shelvesList = snapshot.data!;

                        return DropdownButtonFormField<int?>(
                          value: selectedShelfId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('📍 Без полки (пока не решил)', style: TextStyle(color: Colors.grey)),
                            ),
                            ...shelvesList.map((s) => DropdownMenuItem<int?>(
                              value: s.shelfId,
                              child: Text(s.fullName, overflow: TextOverflow.ellipsis),
                            )),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedShelfId = val;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Фотография
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final photoPath = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(builder: (context) => const CleanupScreen()),
                            );
                            if (photoPath != null) {
                              setDialogState(() {
                                itemPhotoPath = photoPath;
                              });
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Фото'),
                        ),
                        const SizedBox(width: 12),
                        if (itemPhotoPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              File(itemPhotoPath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    speech.stop();
                    Navigator.pop(context);
                  },
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    speech.stop();
                    final name = nameController.text.trim();
                    final quantity = int.tryParse(quantityController.text.trim()) ?? 1;
                    final tagsRaw = tagsController.text.trim();
                    final tags = tagsRaw.isNotEmpty
                        ? tagsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                        : <String>[];

                    if (name.isNotEmpty) {
                      await isar.writeTxn(() async {
                        if (isEditing) {
                          itemToEdit
                            ..name = name
                            ..quantity = quantity
                            ..tags = tags
                            ..photoPath = itemPhotoPath
                            ..shelfId = selectedShelfId;
                          await isar.items.put(itemToEdit);
                        } else {
                          final newItem = Item()
                            ..name = name
                            ..quantity = quantity
                            ..tags = tags
                            ..photoPath = itemPhotoPath
                            ..shelfId = selectedShelfId;
                          await isar.items.put(newItem);
                        }
                      });
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Сохранить' : 'Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Вспомогательный метод для загрузки всех полок с их иерархией для выпадающего списка
  Future<List<ShelfInfoDropdown>> _loadAllShelvesForDropdown() async {
    final allShelves = await isar.shelfs.where().findAll();
    List<ShelfInfoDropdown> result = [];

    for (var shelf in allShelves) {
      final unit = await isar.storageUnits.get(shelf.storageUnitId);
      final room = unit != null ? await isar.rooms.get(unit.roomId) : null;

      final roomName = room?.name ?? 'Комната';
      final unitName = unit?.name ?? 'Шкаф';

      result.add(ShelfInfoDropdown(
        shelfId: shelf.id,
        fullName: '$roomName ➔ $unitName ➔ ${shelf.name}',
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вещи: ${widget.shelf.name}')),
      body: StreamBuilder<List<Item>>(
        stream: isar.items.filter().shelfIdEqualTo(widget.shelf.id).watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'На этой полке пока ничего нет.\nНажмите "+", чтобы добавить вещь.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: item.photoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(item.photoPath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.inventory_2, color: Colors.white),
                        ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Количество: ${item.quantity}'),
                      if (item.tags.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: item.tags.map((tag) => Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                  isThreeLine: item.tags.isNotEmpty,
                  // Кнопки редактирования и удаления
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _showItemDialog(context, itemToEdit: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          await isar.writeTxn(() async {
                            await isar.items.delete(item.id);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Вспомогательный класс для отображения полного пути полки в выпадающем списке
class ShelfInfoDropdown {
  final int shelfId;
  final String fullName;

  ShelfInfoDropdown({required this.shelfId, required this.fullName});
}