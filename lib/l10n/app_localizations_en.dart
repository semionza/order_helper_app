// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Order Guide';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get englishLanguage => 'English';

  @override
  String get russianLanguage => 'Russian';

  @override
  String get hebrewLanguage => 'Hebrew';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get photo => 'Photo';

  @override
  String get editItem => 'Edit item';

  @override
  String get deleteItemPermanently => 'Delete permanently';

  @override
  String get deleteItemPermanentlyQuestion => 'Delete item permanently?';

  @override
  String get deleteItemPermanentlyWarning =>
      'This item and all of its data will be permanently deleted from the database.';

  @override
  String get removeItem => 'Remove';

  @override
  String get removeItemFromShelf =>
      'Remove this item from the shelf? It will remain in the catalog without a location.';

  @override
  String get newItem => 'New item';

  @override
  String get itemNameLabel => 'Item name';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String quantityValue(int count) {
    return 'Quantity: $count';
  }

  @override
  String get tagsLabel => 'Tags (comma-separated)';

  @override
  String get tagsHint => 'clothes, winter';

  @override
  String get storageLocationLabel => 'Storage location:';

  @override
  String get unassignedShelf => 'Unassigned shelf';

  @override
  String languageChanged(String language) {
    return 'Language changed to: $language';
  }

  @override
  String get fallbackRoom => 'Room';

  @override
  String get fallbackStorageUnit => 'Storage unit';

  @override
  String get holdToEdit => 'Press and hold to edit';

  @override
  String get catalogTitle => 'My items (Catalog)';

  @override
  String get catalogSubtitle => 'Rooms, storage units, shelves, and items';

  @override
  String get roomCleanupTitle => 'Room cleanup';

  @override
  String get roomCleanupSubtitle =>
      'Analyze a messy room and find scattered items';

  @override
  String get captureMessyRoom => 'Take a photo of the messy room';

  @override
  String get cleanupHistoryTitle => 'Cleanup history';

  @override
  String get cleanupHistorySubtitle => 'Previous clutter analysis results';

  @override
  String get newRoom => 'New room';

  @override
  String get roomHint => 'For example: Kids\' room';

  @override
  String get roomsTitle => 'Rooms in the home';

  @override
  String get roomsEmpty =>
      'There are no rooms yet.\nTap + to add the first one.';

  @override
  String get editRoom => 'Edit room';

  @override
  String get deleteRoom => 'Delete room';

  @override
  String get deleteRoomQuestion => 'Delete room?';

  @override
  String get deleteRoomWarning =>
      'The room and all its furniture will be deleted. Items will remain in the catalog without a storage location.';

  @override
  String furnitureInRoom(String roomName) {
    return 'Storage in $roomName';
  }

  @override
  String get furnitureHint => 'For example: Wardrobe, bookcase, dresser';

  @override
  String get editStorageUnit => 'Edit storage unit';

  @override
  String get storageUnitNameLabel => 'Storage unit name';

  @override
  String get deleteStorageUnitQuestion => 'Delete storage unit?';

  @override
  String get deleteStorageUnitWarning =>
      'All of its shelves will be deleted. Their items will remain under Unassigned.';

  @override
  String get deleteStorageUnit => 'Delete storage unit';

  @override
  String get storageUnitsEmpty =>
      'There is no storage here yet.\nTap + to add a wardrobe or bookcase.';

  @override
  String shelfInStorageUnit(String storageUnitName) {
    return 'Shelf in $storageUnitName';
  }

  @override
  String get shelfHint => 'For example: Top shelf, Drawer 1';

  @override
  String get editShelf => 'Edit shelf';

  @override
  String get shelfNameLabel => 'Shelf name';

  @override
  String get deleteShelfQuestion => 'Delete shelf?';

  @override
  String get deleteShelfWarning =>
      'Items on this shelf will remain under Unassigned.';

  @override
  String get deleteShelf => 'Delete shelf';

  @override
  String get shelvesEmpty =>
      'There are no shelves yet.\nAdd a shelf or drawer.';

  @override
  String itemsOnShelfTitle(String shelfName) {
    return 'Items: $shelfName';
  }

  @override
  String get itemsOnShelfEmpty =>
      'There is nothing on this shelf yet.\nTap + to add an item.';

  @override
  String get captureShelf => 'Take a photo of the shelf for analysis';

  @override
  String get captureItem => 'Take a photo of the item';

  @override
  String get savingPhoto => 'Saving photo...';

  @override
  String get captureError => 'Could not take the photo';

  @override
  String get analyzingShelf => 'Analyzing shelf...';

  @override
  String get recognizeItemsWithAi => 'Recognize items with AI';

  @override
  String aiItemsAdded(int count) {
    return 'AI added $count items successfully!';
  }

  @override
  String get aiRecognitionFailed =>
      'AI could not recognize items, or the API key is not configured.';

  @override
  String get addExistingItems => 'Add existing items';

  @override
  String addFromDatabaseTitle(String shelfName) {
    return 'Add from catalog: $shelfName';
  }

  @override
  String get onlyUnassigned => 'Unassigned only';

  @override
  String get noDatabaseItems => 'No catalog items are available';

  @override
  String get alreadyOnShelf => 'Already on this shelf';

  @override
  String itemsLinked(int count) {
    return 'Items linked successfully: $count';
  }

  @override
  String moveSelected(int count) {
    return 'Move selected ($count)';
  }

  @override
  String get searchHint => 'Search items...';

  @override
  String get searchPrompt => 'Enter an item name to search';

  @override
  String get searchNoResults => 'Nothing found';

  @override
  String get unassignedLocation => 'Unassigned';

  @override
  String get notLinkedLocation => 'Not linked';

  @override
  String get cleanupHistoryEmpty =>
      'There are no saved cleanup sessions.\nTake a room photo from the home screen.';

  @override
  String cleanupAt(String date) {
    return 'Cleanup on $date';
  }

  @override
  String cleanupHistoryCounts(int foundCount, int selectedCount) {
    return 'Items found: $foundCount (selected: $selectedCount)';
  }

  @override
  String get cleanupResultsTitle => 'Room cleanup results';

  @override
  String get clearAnalysisTooltip => 'Delete analysis results';

  @override
  String get noAnalysisData => 'No analysis data.';

  @override
  String get recognizedItems => 'Recognized items (select those put away):';

  @override
  String chooseMatchForItem(String itemName) {
    return 'Choose a match for “$itemName”';
  }

  @override
  String get createNewItem => 'Create as a new item';

  @override
  String get doNotLinkExisting => 'Do not link to an existing catalog item';

  @override
  String get similarItems => 'Similar catalog items:';

  @override
  String get noSimilarItems => 'No similar catalog items found';

  @override
  String matchPercent(int percent) {
    return 'Match: $percent%';
  }

  @override
  String get putAway => 'Put away';

  @override
  String get saveAndRemove => 'Save the item and remove it from the list';

  @override
  String get eraseAndRemove => 'Delete and remove from the list';

  @override
  String itemQuantityAndTags(int quantity, String tags) {
    return 'Qty: $quantity | Tags: $tags';
  }

  @override
  String get editItemTooltip => 'Edit item';

  @override
  String databaseMatch(int percent, String location) {
    return 'In catalog ($percent%): $location';
  }

  @override
  String get newItemChooseMatch => 'New item (tap to choose a match)';

  @override
  String get selectCleanedItems => 'Select the items that you put away';

  @override
  String get roomCleanupComplete => 'The room is tidy! Cleanup complete.';

  @override
  String cleanupProgress(int cleanedCount, int remainingCount) {
    return 'Put away: $cleanedCount. Remaining: $remainingCount.';
  }

  @override
  String putAwaySelected(int count) {
    return 'Put away ($count)';
  }

  @override
  String recommendSimilarLocation(String itemName, String location) {
    return 'Similar to “$itemName”: put it in $location';
  }

  @override
  String get recommendUnassigned =>
      'No recommendation; place it under Unassigned';

  @override
  String get addItemTitle => 'Add item';

  @override
  String get addItemPlaceholder => 'The new item form will appear here';
}
