import 'package:flutter/material.dart';
import '../app_config.dart';
import '../l10n/app_locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../services/purchase_service.dart';
import '../services/supabase_service.dart';
import '../services/usage_service.dart';
import '../widgets/paywall.dart';
import 'family_sync_screen.dart';
import 'rooms_screen.dart';
import 'cleanup_screen.dart';
import 'search_screen.dart';
import 'room_cleanup_result_screen.dart';
import 'cleanup_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startupSync());
  }

  /// Фоновая синхронизация при запуске: списки обновятся сами через watch() в Isar.
  Future<void> _startupSync() async {
    if (await SupabaseService.instance.currentGroupId() == null) return;
    if (!mounted) return;

    setState(() => _isSyncing = true);
    final outcome = await SupabaseService.instance.autoSync();
    if (!mounted) return;
    setState(() => _isSyncing = false);

    if (outcome == SyncOutcome.pulled) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.syncPulled)));
    }
  }

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
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
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
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.family_restroom, color: Colors.purple, size: 32),
              title: Text(l10n.familySyncTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.familySyncSubtitle),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FamilySyncScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const _PremiumCard(),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatefulWidget {
  const _PremiumCard();

  @override
  State<_PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<_PremiumCard> {
  Future<int> _loadUsage() => UsageService.aiScansUsedThisMonth();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseService.instance.isPremium,
      builder: (context, isPremium, _) {
        return Card(
          child: FutureBuilder<int>(
            future: isPremium ? null : _loadUsage(),
            builder: (context, snapshot) {
              final usage = snapshot.data;
              final subtitle = isPremium
                  ? l10n.premiumActive
                  : usage == null
                  ? l10n.premiumSubtitle
                  : l10n.premiumUsageSummary(
                      usage,
                      AppConfig.maxFreeAiScansPerMonth,
                    );

              return ListTile(
                leading: Icon(
                  isPremium ? Icons.workspace_premium : Icons.lock_open,
                  color: Colors.amber,
                  size: 32,
                ),
                title: Text(
                  l10n.premiumHomeTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(subtitle),
                trailing: isPremium
                    ? null
                    : const Icon(Icons.arrow_forward_ios),
                onTap: isPremium
                    ? null
                    : () async {
                        await showPaywall(context);
                        if (mounted) setState(() {});
                      },
              );
            },
          ),
        );
      },
    );
  }
}