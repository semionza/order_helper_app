import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/room_cleanup_session.dart';
import 'room_cleanup_result_screen.dart';

class CleanupHistoryScreen extends StatelessWidget {
  const CleanupHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История уборок'),
      ),
      body: StreamBuilder<List<RoomCleanupSession>>(
        stream: isar.roomCleanupSessions.where().sortByCreatedAtDesc().watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!;

          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                'Нет сохраненных сессий уборки.\nСделайте фото комнаты с главного экрана.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final dateStr = '${session.createdAt.day}.${session.createdAt.month}.${session.createdAt.year} ${session.createdAt.hour}:${session.createdAt.minute.toString().padLeft(2, '0')}';
              final unassignedCount = session.items.where((i) => i.isSelected).length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(session.photoPath),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text('Уборка от $dateStr', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Найдено предметов: ${session.items.length} (выбрано: $unassignedCount)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Открываем конкретную сессию в экране результатов
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomCleanupResultScreen(sessionId: session.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}