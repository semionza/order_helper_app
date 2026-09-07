import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../models/shelf.dart';
import '../models/item.dart';
import 'cleanup_screen.dart'; // Используем наш экран камеры

class ItemsScreen extends StatefulWidget {
  final Shelf shelf;

  const ItemsScreen({super.key, required this.shelf});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final tagsController = TextEditingController();
    
    String? itemPhotoPath;
    
    // Инициализация сервиса распознавания речи
    final stt.SpeechToText speech = stt.SpeechToText();
    bool isListening = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            // Функция запуска/остановки голосового ввода
            void listen() async {
              if (!isListening) {
                bool available = await speech.initialize(
                  onStatus: (status) => debugPrint('Статус речи: $status'),
                  onError: (error) => debugPrint('Ошибка речи: $error'),
                );
                if (available) {
                  setDialogState(() => isListening = true);
                  speech.listen(
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
              title: Text('Новая вещь: ${widget.shelf.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Поле названия с кнопкой микрофона
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Название вещи',
                              hintText: 'Нажмите микрофон для надиктовывания',
                            ),
                            autofocus: true,
                          ),
                        ),
                        IconButton(
                          icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: isListening ? Colors.red : Colors.blue),
                          onPressed: listen,
                          tooltip: 'Надиктовать голосом',
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
                    
                    // Кнопка и превью фотографии вещи
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
                          label: const Text('Фото вещи'),
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
                      final newItem = Item()
                        ..name = name
                        ..quantity = quantity
                        ..tags = tags
                        ..photoPath = itemPhotoPath
                        ..shelfId = widget.shelf.id;

                      await isar.writeTxn(() async {
                        await isar.items.put(newItem);
                      });
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await isar.writeTxn(() async {
                        await isar.items.delete(item.id);
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}