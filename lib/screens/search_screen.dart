import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/item.dart';
import '../models/shelf.dart';
import '../models/storage_unit.dart';
import '../models/room.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Поиск вещей...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white60),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 18),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(
              child: Text(
                'Введите название вещи для поиска',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : StreamBuilder<List<Item>>(
              // Ищем вещи, название которых содержит поисковый запрос (регистронезависимо через contains)
              stream: isar.items.filter().nameContains(_searchQuery, caseSensitive: false).watch(fireImmediately: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Ничего не найдено',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    // Подтягиваем связанную иерархию (Полка -> Шкаф -> Комната)
                    return FutureBuilder<Map<String, String>>(
                      future: _resolveItemLocation(item.shelfId),
                      builder: (context, locationSnapshot) {
                        final location = locationSnapshot.data ?? {'room': '...', 'unit': '...', 'shelf': '...'};

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
                                const SizedBox(height: 4),
                                Text('Количество: ${item.quantity}'),
                                const SizedBox(height: 2),
                                // Путь к вещи: Комната -> Мебель -> Полка
                                Text(
                                  '📍 ${location['room']} ➔ ${location['unit']} ➔ ${location['shelf']}',
                                  style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                              ],
                            ),
                            isThreeLine: true,
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

  // Вспомогательный метод для поиска названий полки, шкафа и комнаты по ID полки
  Future<Map<String, String>> _resolveItemLocation(int? shelfId) async {
    if (shelfId == null) {
      return {'room': 'Без места', 'unit': 'Не привязано', 'shelf': '—'};
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