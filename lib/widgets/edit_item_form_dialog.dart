import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_utils.dart';
import '../models/shelf.dart';
import '../models/item.dart';
import '../models/storage_unit.dart';
import '../models/room.dart';
import '../screens/cleanup_screen.dart';

Future<void> showEditItemFormDialog({
  required BuildContext context,
  required Item item,
  required VoidCallback onSaved,
}) async {
  final l10n = AppLocalizations.of(context);
  int speechLocaleIndex = speechLocaleIndexFor(context);
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

      final roomName = room?.name ?? l10n.fallbackRoom;
      final unitName = unit?.name ?? l10n.fallbackStorageUnit;

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
                
                final activeLocaleId = speechLocaleOptions[speechLocaleIndex].localeId;
                speech.listen(
                  listenOptions: stt.SpeechListenOptions(localeId: activeLocaleId),
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
            title: Text(l10n.editItem),
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
                          decoration: InputDecoration(labelText: l10n.itemNameLabel),
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          if (isListening) {
                            speech.stop();
                          }
                          setDialogState(() {
                            isListening = false;
                            speechLocaleIndex = (speechLocaleIndex + 1) % speechLocaleOptions.length;
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
                            speechLocaleOptions[speechLocaleIndex].label,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: isListening ? Colors.red : Colors.blue),
                        onPressed: listen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: l10n.quantityLabel),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(labelText: l10n.tagsLabel, hintText: l10n.tagsHint),
                  ),
                  const SizedBox(height: 16),

                  // Выбор местоположения (Полка / Без места)
                  Text(l10n.storageLocationLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<int?>(
                    initialValue: selectedShelfId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(l10n.unassignedShelf, style: const TextStyle(color: Colors.grey)),
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
                            MaterialPageRoute(builder: (context) => CleanupScreen(title: l10n.captureItem)),
                          );
                          if (photoPath != null) {
                            setDialogState(() {
                              itemPhotoPath = photoPath;
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: Text(l10n.photo),
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
                child: Text(l10n.cancel),
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
                child: Text(l10n.save),
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