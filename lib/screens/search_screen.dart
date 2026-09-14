import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_utils.dart';
import '../models/item.dart';
import '../models/shelf.dart';
import '../models/storage_unit.dart';
import '../models/room.dart';
import 'cleanup_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Диалог редактирования вещи прямо из экрана поиска
  void _showEditItemDialog(BuildContext context, Item itemToEdit) {
    final l10n = AppLocalizations.of(context);
    final activeLocaleId = speechLocaleIdFor(context);
    final nameController = TextEditingController(text: itemToEdit.name);
    final quantityController = TextEditingController(text: itemToEdit.quantity.toString());
    final tagsController = TextEditingController(text: itemToEdit.tags.join(', '));
    
    String? itemPhotoPath = itemToEdit.photoPath;
    int? selectedShelfId = itemToEdit.shelfId;

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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: l10n.itemNameLabel),
                            autofocus: true,
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
                    Text(l10n.storageLocationLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    FutureBuilder<List<ShelfInfoDropdown>>(
                      future: _loadAllShelvesForDropdown(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const LinearProgressIndicator();
                        
                        final shelvesList = snapshot.data!;

                        return DropdownButtonFormField<int?>(
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
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                        itemToEdit
                          ..name = name
                          ..quantity = quantity
                          ..tags = tags
                          ..photoPath = itemPhotoPath
                          ..shelfId = selectedShelfId;
                        await isar.items.put(itemToEdit);
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
      },
    );
  }

  Future<List<ShelfInfoDropdown>> _loadAllShelvesForDropdown() async {
    final l10n = AppLocalizations.of(context);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
        ),
      ),
      body: _searchQuery.isEmpty
              ? Center(
              child: Text(
                l10n.searchPrompt,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : StreamBuilder<List<Item>>(
              stream: isar.items.filter().nameContains(_searchQuery, caseSensitive: false).watch(fireImmediately: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.searchNoResults,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return FutureBuilder<Map<String, String>>(
                      future: _resolveItemLocation(item.shelfId),
                      builder: (context, locationSnapshot) {
                        final location = locationSnapshot.data ?? {'room': '...', 'unit': '...', 'shelf': '...'};

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: InkWell(
                            // Клик по всей карточке сразу открывает редактирование вещи
                            onTap: () => _showEditItemDialog(context, item),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
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
                                    const SizedBox(height: 4),
                                    Text(l10n.quantityValue(item.quantity)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '📍 ${location['room']} ➔ ${location['unit']} ➔ ${location['shelf']}',
                                      style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 12),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Future<Map<String, String>> _resolveItemLocation(int? shelfId) async {
    if (shelfId == null) {
      final l10n = AppLocalizations.of(context);
      return {'room': l10n.unassignedLocation, 'unit': l10n.notLinkedLocation, 'shelf': '—'};
    }

    final shelf = await isar.shelfs.get(shelfId);
    if (shelf == null) return {'room': '?', 'unit': '?', 'shelf': '?'};

    final storageUnit = await isar.storageUnits.get(shelf.storageUnitId);
    if (storageUnit == null) return {'room': '?', 'unit': '?', 'shelf': shelf.name};

    final room = await isar.rooms.get(storageUnit.roomId);
    
    return {
      'room': room?.name ?? '?',
      'unit': storageUnit.name,
      'shelf': shelf.name,
    };
  }
}

class ShelfInfoDropdown {
  final int shelfId;
  final String fullName;

  ShelfInfoDropdown({required this.shelfId, required this.fullName});
}