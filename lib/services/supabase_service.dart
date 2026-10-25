import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../models/item.dart';
import '../models/room.dart';
import '../models/shelf.dart';
import '../models/storage_unit.dart';
import 'purchase_service.dart';

/// Результат подключения устройства к семейной группе.
enum JoinGroupResult { success, notFound, error }

/// Результат фоновой синхронизации.
enum SyncOutcome { notInGroup, pulled, pushed, failed }

/// Синхронизация локальной базы Isar с семейной группой в Supabase.
///
/// Схема:
///   family_groups(id uuid pk, created_at, owner_id text, is_premium bool,
///                 shared_data jsonb, updated_at)
///   group_members(id uuid pk, group_id uuid fk, device_id text,
///                 joined_at, unique(group_id, device_id))
///
/// В клиенте используется только публичный publishable-ключ.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  /// Заголовок, по которому RLS-политики определяют устройство.
  static const String deviceIdHeader = 'x-device-id';

  static const String _groupsTable = 'family_groups';
  static const String _membersTable = 'group_members';
  static const String _deviceIdKey = 'family_device_id';
  static const String _groupIdKey = 'family_group_id';
  static const String _lastSyncKey = 'family_last_sync_at';

  SupabaseClient get client => Supabase.instance.client;

  // --- Устройство и текущая группа ---

  /// Стабильный идентификатор устройства, сохранённый локально.
  Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id = base64Url.encode(bytes).replaceAll('=', '');
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  Future<String?> currentGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_groupIdKey);
  }

  Future<void> _setCurrentGroupId(String? groupId) async {
    final prefs = await SharedPreferences.getInstance();
    if (groupId == null) {
      await prefs.remove(_groupIdKey);
    } else {
      await prefs.setString(_groupIdKey, groupId);
    }
  }

  // --- Группы ---

  Future<Map<String, dynamic>?> fetchGroup(String groupId) async {
    try {
      return await client
          .from(_groupsTable)
          .select()
          .eq('id', groupId)
          .maybeSingle();
    } on PostgrestException catch (e) {
      debugPrint('Supabase: не удалось загрузить группу: ${e.message}');
      return null;
    }
  }

  Future<List<String>> groupDevices(String groupId) async {
    try {
      final rows = await client
          .from(_membersTable)
          .select('device_id')
          .eq('group_id', groupId);
      return rows.map((row) => row['device_id'].toString()).toList();
    } on PostgrestException catch (e) {
      debugPrint('Supabase: не удалось получить участников: ${e.message}');
      return <String>[];
    }
  }

  Future<bool> isMemberOf(String groupId) async {
    final id = await deviceId();
    return (await groupDevices(groupId)).contains(id);
  }

  /// Создаёт группу, делает текущее устройство владельцем и выгружает каталог.
  /// Возвращает `group_id`, который передаётся второму устройству.
  Future<String?> createGroup() async {
    final id = await deviceId();
    try {
      final group = await client
          .from(_groupsTable)
          .insert({
            'owner_id': id,
            'is_premium': PurchaseService.instance.isPremium.value,
            'shared_data': await buildLocalSnapshot(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select()
          .single();

      final groupId = group['id'].toString();
      await client.from(_membersTable).insert({
        'group_id': groupId,
        'device_id': id,
      });
      await _setCurrentGroupId(groupId);
      return groupId;
    } on PostgrestException catch (e) {
      debugPrint('Supabase: не удалось создать группу: ${e.message}');
      return null;
    }
  }

  /// Подключает устройство к существующей группе по `group_id`.
  Future<JoinGroupResult> joinGroup(String groupId) async {
    final group = await fetchGroup(groupId);
    if (group == null) return JoinGroupResult.notFound;

    final id = await deviceId();

    if ((await groupDevices(groupId)).contains(id)) {
      await _setCurrentGroupId(groupId);
      return JoinGroupResult.success;
    }

    try {
      await client.from(_membersTable).insert({
        'group_id': groupId,
        'device_id': id,
      });
    } on PostgrestException catch (e) {
      debugPrint('Supabase: не удалось подключить устройство: ${e.message}');
      return JoinGroupResult.error;
    }

    await _setCurrentGroupId(groupId);
    return JoinGroupResult.success;
  }

  Future<void> leaveGroup() async {
    final groupId = await currentGroupId();
    if (groupId == null) return;

    final id = await deviceId();
    try {
      await client
          .from(_membersTable)
          .delete()
          .eq('group_id', groupId)
          .eq('device_id', id);
    } on PostgrestException catch (e) {
      debugPrint('Supabase: не удалось отключить устройство: ${e.message}');
    }
    await _setCurrentGroupId(null);
  }

  /// Обновляет премиум-статус группы (вызывать после покупки владельцем).
  Future<void> syncPremiumStatus() async {
    final groupId = await currentGroupId();
    if (groupId == null) return;

    final id = await deviceId();
    try {
      await client
          .from(_groupsTable)
          .update({'is_premium': PurchaseService.instance.isPremium.value})
          .eq('id', groupId)
          .eq('owner_id', id);
    } on PostgrestException catch (e) {
      debugPrint('Supabase: не удалось обновить премиум-статус: ${e.message}');
    }
  }

  // --- Синхронизация каталога ---

  /// Снимок локального каталога. Пути к фотографиям не выгружаются — они локальные.
  Future<Map<String, dynamic>> buildLocalSnapshot() async {
    final rooms = await isar.rooms.where().findAll();
    final storageUnits = await isar.storageUnits.where().findAll();
    final shelves = await isar.shelfs.where().findAll();
    final items = await isar.items.where().findAll();

    return {
      'rooms': [
        for (final r in rooms) {'id': r.id, 'name': r.name, 'icon': r.icon},
      ],
      'storage_units': [
        for (final u in storageUnits)
          {'id': u.id, 'name': u.name, 'room_id': u.roomId},
      ],
      'shelves': [
        for (final s in shelves)
          {'id': s.id, 'name': s.name, 'storage_unit_id': s.storageUnitId},
      ],
      'items': [
        for (final i in items)
          {
            'id': i.id,
            'name': i.name,
            'quantity': i.quantity,
            'tags': i.tags,
            'shelf_id': i.shelfId,
          },
      ],
    };
  }

  /// Выгружает локальные комнаты, мебель, полки и вещи в `shared_data` группы.
  Future<bool> pushLocalData([String? groupId]) async {
    final id = groupId ?? await currentGroupId();
    if (id == null) return false;

    try {
      await client
          .from(_groupsTable)
          .update({
            'shared_data': await buildLocalSnapshot(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase: синхронизация не удалась: ${e.message}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchSnapshot([String? groupId]) async {
    final id = groupId ?? await currentGroupId();
    if (id == null) return null;
    final group = await fetchGroup(id);
    final data = group?['shared_data'];
    return data is Map<String, dynamic> ? data : null;
  }

  /// Заменяет локальный каталог данными из облака.
  Future<void> applySnapshot(Map<String, dynamic> snapshot) async {
    List<Map<String, dynamic>> listOf(String key) =>
        (snapshot[key] as List? ?? const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    await isar.writeTxn(() async {
      await isar.rooms.clear();
      await isar.storageUnits.clear();
      await isar.shelfs.clear();
      await isar.items.clear();

      await isar.rooms.putAll([
        for (final r in listOf('rooms'))
          Room()
            ..id = (r['id'] as num).toInt()
            ..name = r['name']?.toString() ?? ''
            ..icon = r['icon']?.toString() ?? '',
      ]);
      await isar.storageUnits.putAll([
        for (final u in listOf('storage_units'))
          StorageUnit()
            ..id = (u['id'] as num).toInt()
            ..name = u['name']?.toString() ?? ''
            ..roomId = (u['room_id'] as num).toInt(),
      ]);
      await isar.shelfs.putAll([
        for (final s in listOf('shelves'))
          Shelf()
            ..id = (s['id'] as num).toInt()
            ..name = s['name']?.toString() ?? ''
            ..storageUnitId = (s['storage_unit_id'] as num).toInt(),
      ]);
      await isar.items.putAll([
        for (final i in listOf('items'))
          Item()
            ..id = (i['id'] as num).toInt()
            ..name = i['name']?.toString() ?? ''
            ..quantity = (i['quantity'] as num?)?.toInt() ?? 1
            ..tags = (i['tags'] as List? ?? const [])
                .map((e) => e.toString())
                .toList()
            ..shelfId = (i['shelf_id'] as num?)?.toInt(),
      ]);
    });
  }

  /// Подтягивает облачный каталог в локальную базу.
  Future<bool> pullRemoteData([String? groupId]) async {
    final snapshot = await fetchSnapshot(groupId);
    if (snapshot == null) return false;
    await applySnapshot(snapshot);
    return true;
  }

  Future<DateTime?> lastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> _setLastSyncAt(DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, value.toUtc().toIso8601String());
  }

  /// Фоновая синхронизация по принципу last-write-wins на уровне всего каталога:
  /// если в облаке есть изменения новее последней синхронизации — забираем их,
  /// иначе выгружаем локальные данные.
  Future<SyncOutcome> autoSync() async {
    final groupId = await currentGroupId();
    if (groupId == null) return SyncOutcome.notInGroup;

    final group = await fetchGroup(groupId);
    if (group == null) return SyncOutcome.failed;

    final remoteUpdatedAt =
        DateTime.tryParse(group['updated_at']?.toString() ?? '')?.toUtc();
    final lastSync = await lastSyncAt();

    if (remoteUpdatedAt != null &&
        (lastSync == null || remoteUpdatedAt.isAfter(lastSync))) {
      final snapshot = group['shared_data'];
      if (snapshot is Map<String, dynamic>) {
        await applySnapshot(snapshot);
        await _setLastSyncAt(remoteUpdatedAt);
        return SyncOutcome.pulled;
      }
    }

    if (!await pushLocalData(groupId)) return SyncOutcome.failed;
    await _setLastSyncAt(DateTime.now());
    return SyncOutcome.pushed;
  }

  /// Принудительная выгрузка локальных данных поверх облачных.
  Future<bool> forcePush() async {
    final ok = await pushLocalData();
    if (ok) await _setLastSyncAt(DateTime.now());
    return ok;
  }
}
