import 'package:flutter/material.dart';
import 'rooms_screen.dart';
import 'cleanup_screen.dart';
import 'search_screen.dart';
import 'room_cleanup_result_screen.dart';
import 'cleanup_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Гид по порядку'),
        actions: [
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
              title: const Text('Мои вещи (Каталог)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text('Комнаты, шкафы, полки и список вещей'),
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
              title: const Text('Уборка комнаты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text('Анализ неубранной комнаты и поиск разбросанных вещей'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final photoPath = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CleanupScreen(
                      title: 'Сделайте фото неубранной комнаты',
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
              title: const Text('История уборок', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text('Предыдущие результаты анализа беспорядка'),
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