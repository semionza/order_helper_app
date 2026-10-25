// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'WhereIsThat: Smart Organizer';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get englishLanguage => 'Английский';

  @override
  String get russianLanguage => 'Русский';

  @override
  String get hebrewLanguage => 'Иврит';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get add => 'Добавить';

  @override
  String get delete => 'Удалить';

  @override
  String get close => 'Закрыть';

  @override
  String get photo => 'Фото';

  @override
  String get editItem => 'Редактировать вещь';

  @override
  String get deleteItemPermanently => 'Удалить навсегда';

  @override
  String get deleteItemPermanentlyQuestion => 'Удалить предмет навсегда?';

  @override
  String get deleteItemPermanentlyWarning =>
      'Этот предмет и все его данные будут безвозвратно удалены из базы данных.';

  @override
  String get removeItem => 'Убрать';

  @override
  String get removeItemFromShelf =>
      'Убрать предмет с полки? Он останется в каталоге без места хранения.';

  @override
  String get newItem => 'Новая вещь';

  @override
  String get itemNameLabel => 'Название вещи';

  @override
  String get quantityLabel => 'Количество';

  @override
  String quantityValue(int count) {
    return 'Количество: $count';
  }

  @override
  String get tagsLabel => 'Теги (через запятую)';

  @override
  String get tagsHint => 'одежда, зима';

  @override
  String get storageLocationLabel => 'Место хранения:';

  @override
  String get unassignedShelf => 'Без полки (пока не решил)';

  @override
  String languageChanged(String language) {
    return 'Язык изменен на: $language';
  }

  @override
  String get fallbackRoom => 'Комната';

  @override
  String get fallbackStorageUnit => 'Шкаф';

  @override
  String get holdToEdit => 'Удерживайте для редактирования';

  @override
  String get catalogTitle => 'Мои вещи (Каталог)';

  @override
  String get catalogSubtitle => 'Комнаты, шкафы, полки и список вещей';

  @override
  String get roomCleanupTitle => 'Уборка комнаты';

  @override
  String get roomCleanupSubtitle =>
      'Анализ неубранной комнаты и поиск разбросанных вещей';

  @override
  String get captureMessyRoom => 'Сделайте фото неубранной комнаты';

  @override
  String get cleanupHistoryTitle => 'История уборок';

  @override
  String get cleanupHistorySubtitle =>
      'Предыдущие результаты анализа беспорядка';

  @override
  String get newRoom => 'Новая комната';

  @override
  String get roomHint => 'Например: Детская';

  @override
  String get roomsTitle => 'Комнаты в доме';

  @override
  String get roomsEmpty =>
      'Список комнат пуст.\nНажмите +, чтобы добавить первую.';

  @override
  String get editRoom => 'Редактировать комнату';

  @override
  String get deleteRoom => 'Удалить комнату';

  @override
  String get deleteRoomQuestion => 'Удалить комнату?';

  @override
  String get deleteRoomWarning =>
      'Комната и вся мебель в ней будут удалены. Вещи останутся в каталоге без места хранения.';

  @override
  String furnitureInRoom(String roomName) {
    return 'Мебель в комнате: $roomName';
  }

  @override
  String get furnitureHint => 'Например: Шкаф, Стеллаж, Комод';

  @override
  String get editStorageUnit => 'Редактировать шкаф';

  @override
  String get storageUnitNameLabel => 'Название мебели';

  @override
  String get deleteStorageUnitQuestion => 'Удалить шкаф?';

  @override
  String get deleteStorageUnitWarning =>
      'Все полки этого шкафа будут удалены. Вещи на них сохранятся, но перейдут в категорию «Без места».';

  @override
  String get deleteStorageUnit => 'Удалить шкаф';

  @override
  String get storageUnitsEmpty =>
      'Здесь пока нет мебели.\nНажмите +, чтобы добавить шкаф или стеллаж.';

  @override
  String shelfInStorageUnit(String storageUnitName) {
    return 'Полка в: $storageUnitName';
  }

  @override
  String get shelfHint => 'Например: Верхняя полка, Ящик 1';

  @override
  String get editShelf => 'Редактировать полку';

  @override
  String get shelfNameLabel => 'Название полки';

  @override
  String get deleteShelfQuestion => 'Удалить полку?';

  @override
  String get deleteShelfWarning =>
      'Все вещи с этой полки сохранятся, но перейдут в категорию «Без места».';

  @override
  String get deleteShelf => 'Удалить полку';

  @override
  String get shelvesEmpty => 'Нет полок.\nДобавьте полку или ящик.';

  @override
  String itemsOnShelfTitle(String shelfName) {
    return 'Вещи: $shelfName';
  }

  @override
  String get itemsOnShelfEmpty =>
      'На этой полке пока ничего нет.\nНажмите +, чтобы добавить вещь.';

  @override
  String get captureShelf => 'Сделайте фото полки для анализа';

  @override
  String get captureItem => 'Сделайте фото вещи';

  @override
  String get savingPhoto => 'Сохранение фото...';

  @override
  String get captureError => 'Ошибка при съемке';

  @override
  String get analyzingShelf => 'Анализируем полку...';

  @override
  String get recognizeItemsWithAi => 'Распознать вещи с AI';

  @override
  String aiItemsAdded(int count) {
    return 'AI успешно добавил предметов: $count';
  }

  @override
  String get aiRecognitionFailed =>
      'AI не смог распознать предметы или не настроен API ключ.';

  @override
  String get addExistingItems => 'Добавить из базы (выбрать существующие)';

  @override
  String addFromDatabaseTitle(String shelfName) {
    return 'Добавить из базы: $shelfName';
  }

  @override
  String get onlyUnassigned => 'Только без места';

  @override
  String get noDatabaseItems => 'Нет доступных вещей в базе';

  @override
  String get alreadyOnShelf => 'Уже на этой полке';

  @override
  String itemsLinked(int count) {
    return 'Успешно привязано предметов: $count';
  }

  @override
  String moveSelected(int count) {
    return 'Перенести выбранное ($count)';
  }

  @override
  String get searchHint => 'Поиск вещей...';

  @override
  String get searchPrompt => 'Введите название вещи для поиска';

  @override
  String get searchNoResults => 'Ничего не найдено';

  @override
  String get unassignedLocation => 'Без места';

  @override
  String get notLinkedLocation => 'Не привязано';

  @override
  String get cleanupHistoryEmpty =>
      'Нет сохраненных сессий уборки.\nСделайте фото комнаты с главного экрана.';

  @override
  String cleanupAt(String date) {
    return 'Уборка от $date';
  }

  @override
  String cleanupHistoryCounts(int foundCount, int selectedCount) {
    return 'Найдено предметов: $foundCount (выбрано: $selectedCount)';
  }

  @override
  String get cleanupResultsTitle => 'Результаты уборки комнаты';

  @override
  String get clearAnalysisTooltip => 'Стереть результаты анализа';

  @override
  String get noAnalysisData => 'Нет данных анализа.';

  @override
  String get recognizedItems => 'Распознанные предметы (отметьте убранные):';

  @override
  String chooseMatchForItem(String itemName) {
    return 'Выбрать связь для «$itemName»';
  }

  @override
  String get createNewItem => 'Создать как новый предмет';

  @override
  String get doNotLinkExisting => 'Не связывать с существующими в базе';

  @override
  String get similarItems => 'Похожие вещи в базе:';

  @override
  String get noSimilarItems => 'Похожих вещей в базе не найдено';

  @override
  String matchPercent(int percent) {
    return 'Совпадение: $percent%';
  }

  @override
  String get putAway => 'Положить на место';

  @override
  String get saveAndRemove => 'Сохранить вещь в базу и убрать из списка';

  @override
  String get eraseAndRemove => 'Стереть и удалить из списка';

  @override
  String itemQuantityAndTags(int quantity, String tags) {
    return 'Кол-во: $quantity | Теги: $tags';
  }

  @override
  String get editItemTooltip => 'Редактировать вещь';

  @override
  String databaseMatch(int percent, String location) {
    return 'В базе ($percent%): $location';
  }

  @override
  String get newItemChooseMatch => 'Новый предмет (нажмите для выбора связи)';

  @override
  String get selectCleanedItems => 'Отметьте галочками вещи, которые вы убрали';

  @override
  String get roomCleanupComplete =>
      'Комната полностью убрана! Сессия завершена.';

  @override
  String cleanupProgress(int cleanedCount, int remainingCount) {
    return 'Убрано: $cleanedCount. Осталось в комнате: $remainingCount.';
  }

  @override
  String putAwaySelected(int count) {
    return 'Положить на место ($count)';
  }

  @override
  String recommendSimilarLocation(String itemName, String location) {
    return 'Похоже на «$itemName»: положите в $location';
  }

  @override
  String get recommendUnassigned =>
      'Нет рекомендаций, положите в категорию «Без места»';

  @override
  String get addItemTitle => 'Добавить предмет';

  @override
  String get addItemPlaceholder =>
      'Здесь будет форма для добавления нового предмета';

  @override
  String get premiumTitle => 'Order Guide Premium';

  @override
  String get premiumSubtitle => 'Снимите ограничения бесплатной версии';

  @override
  String get premiumBenefitUnlimitedItems =>
      'Неограниченное количество вещей в каталоге';

  @override
  String get premiumBenefitUnlimitedScans =>
      'Неограниченные AI-анализы фотографий';

  @override
  String get premiumBenefitSupport =>
      'Поддержка дальнейшей разработки приложения';

  @override
  String premiumLimitItemsReached(int limit) {
    return 'В бесплатной версии можно хранить $limit вещей. Оформите Premium, чтобы добавлять дальше.';
  }

  @override
  String premiumLimitScansReached(int limit) {
    return 'В бесплатной версии доступно $limit AI-анализов в месяц. Оформите Premium для безлимита.';
  }

  @override
  String premiumLimitDevicesReached(int limit) {
    return 'В бесплатной версии к семейной группе можно подключить $limit устройства. Оформите Premium, чтобы добавить больше.';
  }

  @override
  String get premiumBenefitFamilySync =>
      'Семейная синхронизация без ограничения по устройствам';

  @override
  String get premiumRestore => 'Восстановить покупки';

  @override
  String get premiumMaybeLater => 'Может быть позже';

  @override
  String get premiumRetry => 'Повторить';

  @override
  String get premiumStoreUnavailable => 'Магазин сейчас недоступен.';

  @override
  String get premiumPurchaseFailed => 'Не удалось начать покупку.';

  @override
  String get premiumPurchaseSuccess => 'Premium активирован. Спасибо!';

  @override
  String get premiumRestoreNoPurchases => 'Предыдущие покупки не найдены.';

  @override
  String get premiumHomeTitle => 'Premium';

  @override
  String get familySyncTitle => 'Семейная синхронизация';

  @override
  String get familySyncSubtitle => 'Общий каталог с другим устройством';

  @override
  String get familySyncNotConnected =>
      'Это устройство ещё не подключено к общему пространству.';

  @override
  String get createSharedSpace => 'Создать общее пространство';

  @override
  String get joinSharedSpace => 'Подключиться по QR-коду';

  @override
  String get sharedSpaceCreated => 'Общее пространство создано';

  @override
  String get sharedSpaceCreateFailed =>
      'Не удалось создать общее пространство.';

  @override
  String get scanQrTitle => 'Сканирование кода приглашения';

  @override
  String get scanQrHint => 'Наведите камеру на QR-код на устройстве-хосте';

  @override
  String get invitationQrHint => 'Отсканируйте этот код на втором устройстве';

  @override
  String get groupIdLabel => 'ID пространства';

  @override
  String get copyGroupId => 'Скопировать ID';

  @override
  String get groupIdCopied => 'ID скопирован';

  @override
  String membersCount(int count) {
    return 'Подключено устройств: $count';
  }

  @override
  String get ownerDevice => 'Это устройство — владелец';

  @override
  String get guestDevice => 'Это устройство — гость';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncPulled => 'Локальные данные обновлены из облака';

  @override
  String get syncPushed => 'Локальные данные выгружены в облако';

  @override
  String get syncFailed => 'Не удалось синхронизировать';

  @override
  String get uploadLocalData => 'Выгрузить данные этого устройства';

  @override
  String get uploadLocalDataWarning =>
      'Данные в облаке будут заменены каталогом этого устройства.';

  @override
  String get leaveSharedSpace => 'Покинуть пространство';

  @override
  String get leaveSharedSpaceQuestion => 'Покинуть общее пространство?';

  @override
  String get leaveSharedSpaceWarning =>
      'Устройство перестанет синхронизироваться. Локальные данные останутся на устройстве.';

  @override
  String get joinSuccess => 'Подключено к общему пространству';

  @override
  String get joinNotFound => 'Пространство по этому коду не найдено.';

  @override
  String get joinFailed => 'Не удалось подключиться к пространству.';

  @override
  String get premiumActive => 'Premium активен: без ограничений';

  @override
  String premiumUsageSummary(int items, int maxItems, int scans, int maxScans) {
    return 'Бесплатно: $items/$maxItems вещей, $scans/$maxScans AI-анализов в этом месяце';
  }
}
