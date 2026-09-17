import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../main.dart';
import '../l10n/app_localizations.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmPermanentDelete(BuildContext context, Item item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteItemPermanentlyQuestion),
        content: Text(l10n.deleteItemPermanentlyWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteItemPermanently),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await isar.writeTxn(() async {
      await isar.items.delete(item.id);
    });

    if (mounted) {
      setState(() => _selectedItemIds.remove(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addFromDatabaseTitle(widget.targetShelf.name)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
              },
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          // Фильтр-плашка для быстрого переключения "Только без места"
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.onlyUnassigned),
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
                  ? isar.items.filter().shelfIdIsNull().watch(
                      fireImmediately: true,
                    )
                  : isar.items.where().watch(fireImmediately: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!
                    .where(
                      (item) => item.name.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? l10n.noDatabaseItems
                          : l10n.searchNoResults,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      color: isAlreadyHere ? Colors.grey.shade100 : null,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onLongPress: () =>
                            _confirmPermanentDelete(context, item),
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
                            isAlreadyHere
                                ? l10n.alreadyOnShelf
                                : l10n.quantityValue(item.quantity),
                            style: TextStyle(
                              color: isAlreadyHere
                                  ? Colors.grey
                                  : Colors.blueGrey,
                            ),
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
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
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
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
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
                        item.shelfId = widget
                            .targetShelf
                            .id; // Привязываем к текущей полке
                        await isar.items.put(item);
                      }
                    }
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.itemsLinked(_selectedItemIds.length),
                        ),
                      ),
                    );
                  }
                },
          icon: const Icon(Icons.done_all),
          label: Text(
            l10n.moveSelected(_selectedItemIds.length),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
