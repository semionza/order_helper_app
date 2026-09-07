import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/shelf.dart';
import '../models/item.dart';

class AddExistingItemsScreen extends StatefulWidget {
  final Shelf targetShelf;

  const AddExistingItemsScreen({super.key, required this.targetShelf});

  @override
  State<AddExistingItemsScreen> createState() => _AddExistingItemsScreenState();
}

class _AddExistingItemsScreenState extends State<AddExistingItemsScreen> {
  bool _onlyUnassigned = false; // Фильтр: показывать только вещи без полки
  final Set<int> _selectedItemIds = {}; // ID выбранных вещей

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить из базы: ${widget.targetShelf.name}'),
      ),
      body: Column(
        children: [
          // Фильтр-плашка для быстрого переключения "Только без места"
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('📍 Только без места'),
                  selected: _onlyUnassigned,
                  onSelected: (bool value) {
                    setState(() {
                      _onlyUnassigned = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Список вещей из базы
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _onlyUnassigned
                  ? isar.items.filter().shelfIdIsNull().watch(fireImmediately: true)
                  : isar.items.where().watch(fireImmediately: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет доступных вещей в базе',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = _selectedItemIds.contains(item.id);
                    final isAlreadyHere = item.shelfId == widget.targetShelf.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: isAlreadyHere ? Colors.grey.shade100 : null,
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: isAlreadyHere
                            ? null // Если вещь уже здесь, выключаем выбор
                            : (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedItemIds.add(item.id);
                                  } else {
                                    _selectedItemIds.remove(item.id);
                                  }
                                });
                              },
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isAlreadyHere ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          isAlreadyHere ? 'Уже на этой полке' : 'Количество: ${item.quantity}',
                          style: TextStyle(color: isAlreadyHere ? Colors.grey : Colors.blueGrey),
                        ),
                        secondary: item.photoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  File(item.photoPath!),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.inventory_2, color: Colors.white, size: 20),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Кнопка подтверждения переноса выбранных вещей
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: _selectedItemIds.isEmpty
              ? null
              : () async {
                  await isar.writeTxn(() async {
                    for (var id in _selectedItemIds) {
                      final item = await isar.items.get(id);
                      if (item != null) {
                        item.shelfId = widget.targetShelf.id; // Привязываем к текущей полке
                        await isar.items.put(item);
                      }
                    }
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Успешно привязано предметов: ${_selectedItemIds.length}')),
                    );
                  }
                },
          icon: const Icon(Icons.done_all),
          label: Text('Перенести выбранное (${_selectedItemIds.length})', style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}