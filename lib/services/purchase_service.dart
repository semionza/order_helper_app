import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config.dart';

/// Состояние премиум-подписки и работа с магазином (App Store / Google Play).
class PurchaseService {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  static const String _premiumPrefsKey = 'is_premium';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Активен ли премиум. Слушайте, чтобы перестраивать UI.
  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(
    AppConfig.forcePremiumForTesting,
  );

  final ValueNotifier<bool> isStoreAvailable = ValueNotifier<bool>(false);
  final ValueNotifier<List<ProductDetails>> products =
      ValueNotifier<List<ProductDetails>>(const []);
  final ValueNotifier<bool> isPurchasePending = ValueNotifier<bool>(false);

  /// Текст последней ошибки магазина (для показа в paywall).
  final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadCachedEntitlement();

    try {
      isStoreAvailable.value = await _iap.isAvailable();
    } catch (e) {
      debugPrint('IAP: магазин недоступен: $e');
      isStoreAvailable.value = false;
    }

    if (!isStoreAvailable.value) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object e) {
        debugPrint('IAP: ошибка потока покупок: $e');
        isPurchasePending.value = false;
      },
      onDone: () => _subscription?.cancel(),
    );

    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!isStoreAvailable.value) return;
    try {
      final response = await _iap.queryProductDetails(AppConfig.allProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAP: товары не найдены в магазине: ${response.notFoundIDs}');
      }
      final sorted = [...response.productDetails]
        ..sort((a, b) {
          final ai = AppConfig.paywallProductOrder.indexOf(a.id);
          final bi = AppConfig.paywallProductOrder.indexOf(b.id);
          return (ai < 0 ? 999 : ai).compareTo(bi < 0 ? 999 : bi);
        });
      products.value = sorted;
    } catch (e) {
      debugPrint('IAP: не удалось загрузить товары: $e');
      products.value = const [];
    }
  }

  /// Запускает покупку. Результат придёт в [purchaseStream] и обновит [isPremium].
  Future<bool> buy(ProductDetails product) async {
    if (!isStoreAvailable.value) return false;
    lastError.value = null;
    isPurchasePending.value = true;
    final param = PurchaseParam(productDetails: product);
    try {
      // Подписки и разовые покупки оформляются как non-consumable.
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('IAP: покупка не запустилась: $e');
      lastError.value = e.toString();
      isPurchasePending.value = false;
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!isStoreAvailable.value) return;
    lastError.value = null;
    isPurchasePending.value = true;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP: восстановление не удалось: $e');
      lastError.value = e.toString();
    } finally {
      isPurchasePending.value = false;
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          isPurchasePending.value = true;
          break;
        case PurchaseStatus.error:
          isPurchasePending.value = false;
          lastError.value = purchase.error?.message;
          debugPrint('IAP: ошибка покупки: ${purchase.error}');
          break;
        case PurchaseStatus.canceled:
          isPurchasePending.value = false;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isPurchasePending.value = false;
          if (await _isPurchaseValid(purchase)) {
            await _setPremium(true);
          }
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Проверка покупки. Для продакшена чек (`verificationData.serverVerificationData`)
  /// следует валидировать на собственном сервере через API App Store / Google Play.
  Future<bool> _isPurchaseValid(PurchaseDetails purchase) async {
    return AppConfig.allProductIds.contains(purchase.productID) &&
        purchase.verificationData.serverVerificationData.isNotEmpty;
  }

  Future<void> _setPremium(bool value) async {
    isPremium.value = value || AppConfig.forcePremiumForTesting;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumPrefsKey, value);
  }

  Future<void> _loadCachedEntitlement() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium.value =
        (prefs.getBool(_premiumPrefsKey) ?? false) ||
        AppConfig.forcePremiumForTesting;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
