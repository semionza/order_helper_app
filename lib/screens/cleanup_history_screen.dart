import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../models/room_cleanup_session.dart';
import 'room_cleanup_result_screen.dart';

class CleanupHistoryScreen extends StatelessWidget {
  const CleanupHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cleanupHistoryTitle),
      ),
      body: StreamBuilder<List<RoomCleanupSession>>(
        stream: isar.roomCleanupSessions.where().sortByCreatedAtDesc().watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!;

          if (sessions.isEmpty) {
            return Center(
              child: Text(
                l10n.cleanupHistoryEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final dateStr = DateFormat.yMd(localeName).add_Hm().format(session.createdAt);
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
                  title: Text(l10n.cleanupAt(dateStr), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.cleanupHistoryCounts(session.items.length, unassignedCount)),
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