import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Guide'**
  String get appTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @russianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russianLanguage;

  /// No description provided for @hebrewLanguage.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get hebrewLanguage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @deleteItemPermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteItemPermanently;

  /// No description provided for @deleteItemPermanentlyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete item permanently?'**
  String get deleteItemPermanentlyQuestion;

  /// No description provided for @deleteItemPermanentlyWarning.
  ///
  /// In en, this message translates to:
  /// **'This item and all of its data will be permanently deleted from the database.'**
  String get deleteItemPermanentlyWarning;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// No description provided for @removeItemFromShelf.
  ///
  /// In en, this message translates to:
  /// **'Remove this item from the shelf? It will remain in the catalog without a location.'**
  String get removeItemFromShelf;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemNameLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @quantityValue.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {count}'**
  String quantityValue(int count);

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma-separated)'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'clothes, winter'**
  String get tagsHint;

  /// No description provided for @storageLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage location:'**
  String get storageLocationLabel;

  /// No description provided for @unassignedShelf.
  ///
  /// In en, this message translates to:
  /// **'Unassigned shelf'**
  String get unassignedShelf;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to: {language}'**
  String languageChanged(String language);

  /// No description provided for @fallbackRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get fallbackRoom;

  /// No description provided for @fallbackStorageUnit.
  ///
  /// In en, this message translates to:
  /// **'Storage unit'**
  String get fallbackStorageUnit;

  /// No description provided for @holdToEdit.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to edit'**
  String get holdToEdit;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'My items (Catalog)'**
  String get catalogTitle;

  /// No description provided for @catalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms, storage units, shelves, and items'**
  String get catalogSubtitle;

  /// No description provided for @roomCleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Room cleanup'**
  String get roomCleanupTitle;

  /// No description provided for @roomCleanupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze a messy room and find scattered items'**
  String get roomCleanupSubtitle;

  /// No description provided for @captureMessyRoom.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the messy room'**
  String get captureMessyRoom;

  /// No description provided for @cleanupHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleanup history'**
  String get cleanupHistoryTitle;

  /// No description provided for @cleanupHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Previous clutter analysis results'**
  String get cleanupHistorySubtitle;

  /// No description provided for @newRoom.
  ///
  /// In en, this message translates to:
  /// **'New room'**
  String get newRoom;

  /// No description provided for @roomHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Kids\' room'**
  String get roomHint;

  /// No description provided for @roomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms in the home'**
  String get roomsTitle;

  /// No description provided for @roomsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no rooms yet.\nTap + to add the first one.'**
  String get roomsEmpty;

  /// No description provided for @editRoom.
  ///
  /// In en, this message translates to:
  /// **'Edit room'**
  String get editRoom;

  /// No description provided for @deleteRoom.
  ///
  /// In en, this message translates to:
  /// **'Delete room'**
  String get deleteRoom;

  /// No description provided for @deleteRoomQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete room?'**
  String get deleteRoomQuestion;

  /// No description provided for @deleteRoomWarning.
  ///
  /// In en, this message translates to:
  /// **'The room and all its furniture will be deleted. Items will remain in the catalog without a storage location.'**
  String get deleteRoomWarning;

  /// No description provided for @furnitureInRoom.
  ///
  /// In en, this message translates to:
  /// **'Storage in {roomName}'**
  String furnitureInRoom(String roomName);

  /// No description provided for @furnitureHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Wardrobe, bookcase, dresser'**
  String get furnitureHint;

  /// No description provided for @editStorageUnit.
  ///
  /// In en, this message translates to:
  /// **'Edit storage unit'**
  String get editStorageUnit;

  /// No description provided for @storageUnitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage unit name'**
  String get storageUnitNameLabel;

  /// No description provided for @deleteStorageUnitQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete storage unit?'**
  String get deleteStorageUnitQuestion;

  /// No description provided for @deleteStorageUnitWarning.
  ///
  /// In en, this message translates to:
  /// **'All of its shelves will be deleted. Their items will remain under Unassigned.'**
  String get deleteStorageUnitWarning;

  /// No description provided for @deleteStorageUnit.
  ///
  /// In en, this message translates to:
  /// **'Delete storage unit'**
  String get deleteStorageUnit;

  /// No description provided for @storageUnitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There is no storage here yet.\nTap + to add a wardrobe or bookcase.'**
  String get storageUnitsEmpty;

  /// No description provided for @shelfInStorageUnit.
  ///
  /// In en, this message translates to:
  /// **'Shelf in {storageUnitName}'**
  String shelfInStorageUnit(String storageUnitName);

  /// No description provided for @shelfHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Top shelf, Drawer 1'**
  String get shelfHint;

  /// No description provided for @editShelf.
  ///
  /// In en, this message translates to:
  /// **'Edit shelf'**
  String get editShelf;

  /// No description provided for @shelfNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shelf name'**
  String get shelfNameLabel;

  /// No description provided for @deleteShelfQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete shelf?'**
  String get deleteShelfQuestion;

  /// No description provided for @deleteShelfWarning.
  ///
  /// In en, this message translates to:
  /// **'Items on this shelf will remain under Unassigned.'**
  String get deleteShelfWarning;

  /// No description provided for @deleteShelf.
  ///
  /// In en, this message translates to:
  /// **'Delete shelf'**
  String get deleteShelf;

  /// No description provided for @shelvesEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no shelves yet.\nAdd a shelf or drawer.'**
  String get shelvesEmpty;

  /// No description provided for @itemsOnShelfTitle.
  ///
  /// In en, this message translates to:
  /// **'Items: {shelfName}'**
  String itemsOnShelfTitle(String shelfName);

  /// No description provided for @itemsOnShelfEmpty.
  ///
  /// In en, this message translates to:
  /// **'There is nothing on this shelf yet.\nTap + to add an item.'**
  String get itemsOnShelfEmpty;

  /// No description provided for @captureShelf.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the shelf for analysis'**
  String get captureShelf;

  /// No description provided for @captureItem.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the item'**
  String get captureItem;

  /// No description provided for @savingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Saving photo...'**
  String get savingPhoto;

  /// No description provided for @captureError.
  ///
  /// In en, this message translates to:
  /// **'Could not take the photo'**
  String get captureError;

  /// No description provided for @analyzingShelf.
  ///
  /// In en, this message translates to:
  /// **'Analyzing shelf...'**
  String get analyzingShelf;

  /// No description provided for @recognizeItemsWithAi.
  ///
  /// In en, this message translates to:
  /// **'Recognize items with AI'**
  String get recognizeItemsWithAi;

  /// No description provided for @aiItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'AI added {count} items successfully!'**
  String aiItemsAdded(int count);

  /// No description provided for @aiRecognitionFailed.
  ///
  /// In en, this message translates to:
  /// **'AI could not recognize items, or the API key is not configured.'**
  String get aiRecognitionFailed;

  /// No description provided for @addExistingItems.
  ///
  /// In en, this message translates to:
  /// **'Add existing items'**
  String get addExistingItems;

  /// No description provided for @addFromDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add from catalog: {shelfName}'**
  String addFromDatabaseTitle(String shelfName);

  /// No description provided for @onlyUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned only'**
  String get onlyUnassigned;

  /// No description provided for @noDatabaseItems.
  ///
  /// In en, this message translates to:
  /// **'No catalog items are available'**
  String get noDatabaseItems;

  /// No description provided for @alreadyOnShelf.
  ///
  /// In en, this message translates to:
  /// **'Already on this shelf'**
  String get alreadyOnShelf;

  /// No description provided for @itemsLinked.
  ///
  /// In en, this message translates to:
  /// **'Items linked successfully: {count}'**
  String itemsLinked(int count);

  /// No description provided for @moveSelected.
  ///
  /// In en, this message translates to:
  /// **'Move selected ({count})'**
  String moveSelected(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter an item name to search'**
  String get searchPrompt;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchNoResults;

  /// No description provided for @unassignedLocation.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassignedLocation;

  /// No description provided for @notLinkedLocation.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get notLinkedLocation;

  /// No description provided for @cleanupHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no saved cleanup sessions.\nTake a room photo from the home screen.'**
  String get cleanupHistoryEmpty;

  /// No description provided for @cleanupAt.
  ///
  /// In en, this message translates to:
  /// **'Cleanup on {date}'**
  String cleanupAt(String date);

  /// No description provided for @cleanupHistoryCounts.
  ///
  /// In en, this message translates to:
  /// **'Items found: {foundCount} (selected: {selectedCount})'**
  String cleanupHistoryCounts(int foundCount, int selectedCount);

  /// No description provided for @cleanupResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Room cleanup results'**
  String get cleanupResultsTitle;

  /// No description provided for @clearAnalysisTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete analysis results'**
  String get clearAnalysisTooltip;

  /// No description provided for @noAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'No analysis data.'**
  String get noAnalysisData;

  /// No description provided for @recognizedItems.
  ///
  /// In en, this message translates to:
  /// **'Recognized items (select those put away):'**
  String get recognizedItems;

  /// No description provided for @chooseMatchForItem.
  ///
  /// In en, this message translates to:
  /// **'Choose a match for “{itemName}”'**
  String chooseMatchForItem(String itemName);

  /// No description provided for @createNewItem.
  ///
  /// In en, this message translates to:
  /// **'Create as a new item'**
  String get createNewItem;

  /// No description provided for @doNotLinkExisting.
  ///
  /// In en, this message translates to:
  /// **'Do not link to an existing catalog item'**
  String get doNotLinkExisting;

  /// No description provided for @similarItems.
  ///
  /// In en, this message translates to:
  /// **'Similar catalog items:'**
  String get similarItems;

  /// No description provided for @noSimilarItems.
  ///
  /// In en, this message translates to:
  /// **'No similar catalog items found'**
  String get noSimilarItems;

  /// No description provided for @matchPercent.
  ///
  /// In en, this message translates to:
  /// **'Match: {percent}%'**
  String matchPercent(int percent);

  /// No description provided for @putAway.
  ///
  /// In en, this message translates to:
  /// **'Put away'**
  String get putAway;

  /// No description provided for @saveAndRemove.
  ///
  /// In en, this message translates to:
  /// **'Save the item and remove it from the list'**
  String get saveAndRemove;

  /// No description provided for @eraseAndRemove.
  ///
  /// In en, this message translates to:
  /// **'Delete and remove from the list'**
  String get eraseAndRemove;

  /// No description provided for @itemQuantityAndTags.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity} | Tags: {tags}'**
  String itemQuantityAndTags(int quantity, String tags);

  /// No description provided for @editItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItemTooltip;

  /// No description provided for @databaseMatch.
  ///
  /// In en, this message translates to:
  /// **'In catalog ({percent}%): {location}'**
  String databaseMatch(int percent, String location);

  /// No description provided for @newItemChooseMatch.
  ///
  /// In en, this message translates to:
  /// **'New item (tap to choose a match)'**
  String get newItemChooseMatch;

  /// No description provided for @selectCleanedItems.
  ///
  /// In en, this message translates to:
  /// **'Select the items that you put away'**
  String get selectCleanedItems;

  /// No description provided for @roomCleanupComplete.
  ///
  /// In en, this message translates to:
  /// **'The room is tidy! Cleanup complete.'**
  String get roomCleanupComplete;

  /// No description provided for @cleanupProgress.
  ///
  /// In en, this message translates to:
  /// **'Put away: {cleanedCount}. Remaining: {remainingCount}.'**
  String cleanupProgress(int cleanedCount, int remainingCount);

  /// No description provided for @putAwaySelected.
  ///
  /// In en, this message translates to:
  /// **'Put away ({count})'**
  String putAwaySelected(int count);

  /// No description provided for @recommendSimilarLocation.
  ///
  /// In en, this message translates to:
  /// **'Similar to “{itemName}”: put it in {location}'**
  String recommendSimilarLocation(String itemName, String location);

  /// No description provided for @recommendUnassigned.
  ///
  /// In en, this message translates to:
  /// **'No recommendation; place it under Unassigned'**
  String get recommendUnassigned;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemTitle;

  /// No description provided for @addItemPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'The new item form will appear here'**
  String get addItemPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
