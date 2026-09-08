import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../models/shelf.dart';
import '../models/item.dart';
import '../models/storage_unit.dart';
import '../models/room.dart';
import '../screens/cleanup_screen.dart';

// Глобальные переменные для сохранения состояния языка голосового ввода между вызовами
int _dialogLangIndex = 0;
final List<Map<String, String>> _dialogLanguages = [
  {'code': 'ru_RU', 'label': 'RU'},
  {'code': 'en_US', 'label': 'EN'},
  {'code': 'he_IL', 'label': 'HE'},
];

Future<void> showEditItemFormDialog({
  required BuildContext context,
  required Item item,
  required VoidCallback onSaved,
}) async {
  final nameController = TextEditingController(text: item.name);
  final quantityController = TextEditingController(text: item.quantity.toString());
  final tagsController = TextEditingController(text: item.tags.join(', '));
  
  String? itemPhotoPath = item.photoPath;
  int? selectedShelfId = item.shelfId;

  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;

  // Вспомогательный метод для загрузки полок
  Future<List<ShelfInfoDropdown>> loadShelves() async {
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

  final shelvesList = await loadShelves();

  if (!context.mounted) return;

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
                
                final activeLocaleId = _dialogLanguages[_dialogLangIndex]['code'];
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
            title: const Text('Редактировать вещь'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название с микрофоном и переключателем языка (точно как в ItemsScreen)
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
                      InkWell(
                        onTap: () {
                          setDialogState(() {
                            _dialogLangIndex = (_dialogLangIndex + 1) % _dialogLanguages.length;
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
                            _dialogLanguages[_dialogLangIndex]['label']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: isListening ? Colors.red : Colors.blue),
                        onPressed: listen,
                        onLongPress: () {
                          setDialogState(() {
                            _dialogLangIndex = (_dialogLangIndex + 1) % _dialogLanguages.length;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Язык изменен на: ${_dialogLanguages[_dialogLangIndex]['label']}'),
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
                  DropdownButtonFormField<int?>(
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
                  ),
                  const SizedBox(height: 16),

                  // Фотография (кнопка и превью в ряд, как в ItemsScreen)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final photoPath = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(builder: (context) => const CleanupScreen(title: 'Сделайте фото вещи')),
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
                      item
                        ..name = name
                        ..quantity = quantity
                        ..tags = tags
                        ..photoPath = itemPhotoPath
                        ..shelfId = selectedShelfId;
                      await isar.items.put(item);
                    });
                    onSaved();
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  );
}

class ShelfInfoDropdown {
  final int shelfId;
  final String fullName;

  ShelfInfoDropdown({required this.shelfId, required this.fullName});
}