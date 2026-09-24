import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/supabase_service.dart';
import '../widgets/paywall.dart';
import 'qr_scanner_screen.dart';

class FamilySyncScreen extends StatefulWidget {
  const FamilySyncScreen({super.key});

  @override
  State<FamilySyncScreen> createState() => _FamilySyncScreenState();
}

class _FamilySyncScreenState extends State<FamilySyncScreen> {
  final SupabaseService _service = SupabaseService.instance;

  bool _busy = false;
  String? _groupId;
  String? _deviceId;
  String? _ownerId;
  int _memberCount = 0;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final deviceId = await _service.deviceId();
    final groupId = await _service.currentGroupId();
    String? ownerId;
    var memberCount = 0;

    if (groupId != null) {
      final group = await _service.fetchGroup(groupId);
      ownerId = group?['owner_id']?.toString();
      memberCount = (await _service.groupDevices(groupId)).length;
    }

    if (!mounted) return;
    setState(() {
      _deviceId = deviceId;
      _groupId = groupId;
      _ownerId = ownerId;
      _memberCount = memberCount;
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createSpace() => _run(() async {
    final l10n = AppLocalizations.of(context);
    final groupId = await _service.createGroup();
    if (groupId == null) {
      _snack(l10n.sharedSpaceCreateFailed);
      return;
    }
    await _loadState();
    _snack(l10n.sharedSpaceCreated);
    if (mounted) _showInvitationQr(groupId);
  });

  Future<void> _joinSpace() async {
    final l10n = AppLocalizations.of(context);
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (scanned == null || !mounted) return;

    await _run(() async {
      final result = await joinGroupWithPaywall(context, scanned);
      switch (result) {
        case JoinGroupResult.success:
          await _service.autoSync();
          await _loadState();
          _snack(l10n.joinSuccess);
          break;
        case JoinGroupResult.notFound:
          _snack(l10n.joinNotFound);
          break;
        case JoinGroupResult.limitReached:
          _snack(
            l10n.premiumLimitDevicesReached(AppConfig.maxFreeGroupDevices),
          );
          break;
        case JoinGroupResult.error:
          _snack(l10n.joinFailed);
          break;
      }
    });
  }

  Future<void> _syncNow() => _run(() async {
    final l10n = AppLocalizations.of(context);
    final outcome = await _service.autoSync();
    await _loadState();
    switch (outcome) {
      case SyncOutcome.pulled:
        _snack(l10n.syncPulled);
        break;
      case SyncOutcome.pushed:
        _snack(l10n.syncPushed);
        break;
      case SyncOutcome.notInGroup:
        _snack(l10n.familySyncNotConnected);
        break;
      case SyncOutcome.failed:
        _snack(l10n.syncFailed);
        break;
    }
  });

  Future<void> _uploadLocal() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.uploadLocalData),
        content: Text(l10n.uploadLocalDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.uploadLocalData),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _run(() async {
      final ok = await _service.forcePush();
      _snack(ok ? l10n.syncPushed : l10n.syncFailed);
    });
  }

  Future<void> _leaveSpace() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.leaveSharedSpaceQuestion),
        content: Text(l10n.leaveSharedSpaceWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.leaveSharedSpace),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _run(() async {
      await _service.leaveGroup();
      await _loadState();
    });
  }

  void _showInvitationQr(String groupId) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.familySyncTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: QrImageView(
                data: groupId,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.invitationQrHint, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            SelectableText(
              groupId,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: groupId));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _snack(l10n.groupIdCopied);
            },
            label: Text(l10n.copyGroupId),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inGroup = _groupId != null;
    final isOwner = inGroup && _ownerId != null && _ownerId == _deviceId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.familySyncTitle)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.familySyncSubtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!inGroup)
                        Text(
                          l10n.familySyncNotConnected,
                          style: const TextStyle(color: Colors.grey),
                        )
                      else ...[
                        Text(isOwner ? l10n.ownerDevice : l10n.guestDevice),
                        const SizedBox(height: 4),
                        Text(l10n.membersCount(_memberCount)),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.groupIdLabel}: $_groupId',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!inGroup) ...[
                ElevatedButton.icon(
                  onPressed: _busy ? null : _createSpace,
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(l10n.createSharedSpace),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _joinSpace,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.joinSharedSpace),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _busy ? null : _syncNow,
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.syncNow),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _showInvitationQr(_groupId!),
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(l10n.invitationQrHint),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _uploadLocal,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(l10n.uploadLocalData),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _busy ? null : _leaveSpace,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    l10n.leaveSharedSpace,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
