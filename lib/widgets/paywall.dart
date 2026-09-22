import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/purchase_service.dart';
import '../services/supabase_service.dart';
import '../services/usage_service.dart';

/// Показывает предложение оформить Premium. Возвращает true, если премиум активирован.
Future<bool> showPaywall(BuildContext context, {String? reason}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _PaywallSheet(reason: reason),
  );
  return result ?? PurchaseService.instance.isPremium.value;
}

/// Проверяет лимит вещей; при превышении показывает paywall.
/// Возвращает true, если создание [count] вещей разрешено.
Future<bool> ensureItemQuota(BuildContext context, {int count = 1}) async {
  if (await UsageService.canCreateItems(count: count)) return true;
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  return showPaywall(
    context,
    reason: l10n.premiumLimitItemsReached(AppConfig.maxFreeItems),
  );
}

/// Проверяет лимит AI-анализов; при превышении показывает paywall.
Future<bool> ensureAiScanQuota(BuildContext context) async {
  if (await UsageService.canRunAiScan()) return true;
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  return showPaywall(
    context,
    reason: l10n.premiumLimitScansReached(AppConfig.maxFreeAiScansPerMonth),
  );
}

/// Проверяет лимит устройств семейной группы; при превышении показывает paywall.
Future<bool> ensureGroupDeviceQuota(
  BuildContext context,
  String groupId,
) async {
  if (await SupabaseService.instance.canRegisterDevice(groupId)) return true;
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  return showPaywall(
    context,
    reason: l10n.premiumLimitDevicesReached(AppConfig.maxFreeGroupDevices),
  );
}

/// Подключает устройство к группе; при отказе по лимиту (в том числе от
/// серверного триггера) показывает paywall и повторяет попытку после покупки.
Future<JoinGroupResult> joinGroupWithPaywall(
  BuildContext context,
  String groupId,
) async {
  var result = await SupabaseService.instance.joinGroup(groupId);
  if (result != JoinGroupResult.limitReached) return result;
  if (!context.mounted) return result;

  final l10n = AppLocalizations.of(context);
  final upgraded = await showPaywall(
    context,
    reason: l10n.premiumLimitDevicesReached(AppConfig.maxFreeGroupDevices),
  );
  if (upgraded) {
    result = await SupabaseService.instance.joinGroup(groupId);
  }
  return result;
}

class _PaywallSheet extends StatefulWidget {
  final String? reason;

  const _PaywallSheet({this.reason});

  @override
  State<_PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<_PaywallSheet> {
  final PurchaseService _service = PurchaseService.instance;

  @override
  void initState() {
    super.initState();
    _service.isPremium.addListener(_onPremiumChanged);
  }

  @override
  void dispose() {
    _service.isPremium.removeListener(_onPremiumChanged);
    super.dispose();
  }

  void _onPremiumChanged() {
    if (_service.isPremium.value && mounted) {
      final l10n = AppLocalizations.of(context);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.premiumPurchaseSuccess)));
    }
  }

  Future<void> _buy(ProductDetails product) async {
    final l10n = AppLocalizations.of(context);
    final started = await _service.buy(product);
    if (!started && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.premiumPurchaseFailed)));
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    await _service.restorePurchases();
    if (!mounted) return;
    if (!_service.isPremium.value) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.premiumRestoreNoPurchases)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.premiumTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.reason != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(widget.reason!),
                ),
                const SizedBox(height: 12),
              ],
              Text(l10n.premiumSubtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              _benefit(l10n.premiumBenefitUnlimitedItems),
              _benefit(l10n.premiumBenefitUnlimitedScans),
              _benefit(l10n.premiumBenefitFamilySync),
              _benefit(l10n.premiumBenefitSupport),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _service.isPurchasePending,
                builder: (context, pending, child) => AbsorbPointer(
                  absorbing: pending,
                  child: Opacity(opacity: pending ? 0.5 : 1, child: child),
                ),
                child: ValueListenableBuilder<List<ProductDetails>>(
                  valueListenable: _service.products,
                  builder: (context, products, _) {
                    if (products.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.premiumStoreUnavailable,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () async {
                              await _service.init();
                              await _service.loadProducts();
                            },
                            child: Text(l10n.premiumRetry),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final product in products) ...[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _buy(product),
                            child: Text(
                              '${product.title} · ${product.price}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    );
                  },
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _service.isPurchasePending,
                builder: (context, pending, _) => pending
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      )
                    : const SizedBox.shrink(),
              ),
              TextButton(
                onPressed: _restore,
                child: Text(l10n.premiumRestore),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.premiumMaybeLater),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
