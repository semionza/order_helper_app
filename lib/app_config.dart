/// Центральное место для настройки лимитов бесплатной версии.
/// Меняйте значения здесь, чтобы протестировать поведение paywall.
class AppConfig {
  AppConfig._();

  // --- Лимиты бесплатной версии ---

  /// Максимальное количество вещей в каталоге для бесплатной версии.
  static const int maxFreeItems = 30;

  /// Максимальное количество AI-анализов (Gemini) в месяц для бесплатной версии.
  static const int maxFreeAiScansPerMonth = 5;

  /// Максимальное число устройств в семейной группе для бесплатной версии.
  static const int maxFreeGroupDevices = 2;

  /// Включите, чтобы локально открыть все премиум-функции без покупки (только для отладки).
  static const bool forcePremiumForTesting = false;

  // --- Идентификаторы товаров в App Store / Google Play ---

  static const String monthlySubscriptionId = 'order_helper_premium_monthly';
  static const String yearlySubscriptionId = 'order_helper_premium_yearly';
  static const String lifetimeProductId = 'order_helper_premium_lifetime';

  /// Подписки (auto-renewable / subscription).
  static const Set<String> subscriptionProductIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
  };

  /// Разовые покупки (non-consumable).
  static const Set<String> nonConsumableProductIds = {lifetimeProductId};

  static const Set<String> allProductIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
    lifetimeProductId,
  };

  /// Порядок отображения товаров в paywall.
  static const List<String> paywallProductOrder = [
    yearlySubscriptionId,
    monthlySubscriptionId,
    lifetimeProductId,
  ];
}
