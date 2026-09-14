import 'package:flutter/material.dart';
import '../l10n/app_locale_controller.dart';
import '../l10n/app_localizations.dart';
import 'rooms_screen.dart';
import 'cleanup_screen.dart';
import 'search_screen.dart';
import 'room_cleanup_result_screen.dart';
import 'cleanup_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: l10n.changeLanguage,
            onSelected: setAppLocale,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Text('EN · ${l10n.englishLanguage}'),
              ),
              PopupMenuItem(
                value: const Locale('ru'),
                child: Text('RU · ${l10n.russianLanguage}'),
              ),
              PopupMenuItem(
                value: const Locale('he'),
                child: Text('HE · ${l10n.hebrewLanguage}'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue, size: 32),
              title: Text(l10n.catalogTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.catalogSubtitle),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoomsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green, size: 32),
              title: Text(l10n.roomCleanupTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.roomCleanupSubtitle),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final photoPath = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CleanupScreen(
                      title: l10n.captureMessyRoom,
                    ),
                  ),
                );

                if (photoPath != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomCleanupResultScreen(photoPath: photoPath),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.orange, size: 32),
              title: Text(l10n.cleanupHistoryTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.cleanupHistorySubtitle),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CleanupHistoryScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}