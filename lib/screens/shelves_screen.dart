import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/storage_unit.dart';
import '../models/shelf.dart';
import '../models/item.dart';
import '../services/gemini_service.dart';
import 'cleanup_screen.dart';
import 'items_screen.dart';

class ShelvesScreen extends StatefulWidget {
  final StorageUnit storageUnit;

  const ShelvesScreen({super.key, required this.storageUnit});

  @override
  State<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends State<ShelvesScreen> {
  final Map<int, bool> _isAnalyzing = {};

  void _showAddShelfDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Полка в: ${widget.storageUnit.name}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Например: Верхняя полка, Ящик 1'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final shelf = Shelf()
                    ..name = name
                    ..storageUnitId = widget.storageUnit.id;

                  await isar.writeTxn(() async {
                    await isar.shelfs.put(shelf);
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // Диалог редактирования или удаления полки
  void _showEditShelfDialog(BuildContext context, Shelf shelf) {
    final controller = TextEditingController(text: shelf.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать полку'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Название полки'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Удалить полку?'),
                    content: const Text('Все вещи с этой полки сохранятся, но перейдут в категорию "Без места".'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await isar.writeTxn(() async {
                    // Отвязываем все вещи с этой полки (shelfId = null)
                    final items = await isar.items.filter().shelfIdEqualTo(shelf.id).findAll();
                    for (var item in items) {
                      item.shelfId = null;
                      await isar.items.put(item);
                    }

                    // Удаляем саму полку
                    await isar.shelfs.delete(shelf.id);
                  });

                  if (context.mounted) {
                    Navigator.pop(context); // Закрыть окно редактирования
                  }
                }
              },
              child: const Text('Удалить полку'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await isar.writeTxn(() async {
                    shelf.name = name;
                    await isar.shelfs.put(shelf);
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
  }

  Future<void> _analyzeShelfWithAI(Shelf shelf) async {
    if (shelf.photoPath == null) return;

    setState(() {
      _isAnalyzing[shelf.id] = true;
    });

    try {
      final detectedItems = await GeminiService.analyzeShelfPhoto(shelf.photoPath!);

      if (detectedItems.isNotEmpty) {
        await isar.writeTxn(() async {
          for (var itemMap in detectedItems) {
            final newItem = Item()
              ..name = itemMap['name'] ?? 'Предмет'
              ..quantity = itemMap['quantity'] ?? 1
              ..tags = List<String>.from(itemMap['tags'] ?? [])
              ..shelfId = shelf.id;

            await isar.items.put(newItem);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI успешно добавил ${detectedItems.length} предметов!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(key: Key('error_snackbar'), content: Text('AI не смог распознать предметы или не настроен API ключ.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Ошибка анализа: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing[shelf.id] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.storageUnit.name)),
      body: StreamBuilder<List<Shelf>>(
        stream: isar.shelfs.filter().storageUnitIdEqualTo(widget.storageUnit.id).watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final shelves = snapshot.data!;

          if (shelves.isEmpty) {
            return const Center(
              child: Text(
                'Нет полок.\nДобавьте полку или ящик.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: shelves.length,
            itemBuilder: (context, index) {
              final shelf = shelves[index];
              final analyzing = _isAnalyzing[shelf.id] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemsScreen(shelf: shelf)),
                    );
                  },
                  // Добавлено длинное нажатие на полку
                  onLongPress: () => _showEditShelfDialog(context, shelf),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shelf.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const Text('Удерживайте для редактирования', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.blue),
                              onPressed: () async {
                                final photoPath = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CleanupScreen()),
                                );

                                if (photoPath != null) {
                                  await isar.writeTxn(() async {
                                    shelf.photoPath = photoPath;
                                    await isar.shelfs.put(shelf);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        if (shelf.photoPath != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(shelf.photoPath!),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: analyzing ? null : () => _analyzeShelfWithAI(shelf),
                              icon: analyzing 
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.auto_awesome, color: Colors.amber),
                              label: Text(analyzing ? 'Анализируем полку...' : 'Распознать вещи с AI'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade50,
                                foregroundColor: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddShelfDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}