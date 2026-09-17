import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'l10n/app_locale_controller.dart';
import 'l10n/app_localizations.dart';
import 'models/room.dart';
import 'models/storage_unit.dart';
import 'models/shelf.dart';
import 'models/item.dart';
import 'models/room_cleanup_session.dart';
import 'screens/home_screen.dart';

// Глобальная переменная для доступа к базе данных из любого места
late Isar isar;

void main() async {
  // Гарантируем инициализацию виджетов Flutter перед вызовом нативных модулей
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedAppLocale();

  // Получаем системную директорию для хранения базы данных
  final dir = await getApplicationDocumentsDirectory();

  // Открываем или создаем базу данных Isar со всеми нашими моделями
  isar = await Isar.open(
    [RoomSchema, StorageUnitSchema, ShelfSchema, ItemSchema, RoomCleanupSessionSchema],
    directory: dir.path,
  );

  runApp(const OrderHelperApp());
}

class OrderHelperApp extends StatelessWidget {
  const OrderHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, child) => MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedAppLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}