// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'מדריך לסדר';

  @override
  String get changeLanguage => 'החלפת שפה';

  @override
  String get englishLanguage => 'אנגלית';

  @override
  String get russianLanguage => 'רוסית';

  @override
  String get hebrewLanguage => 'עברית';

  @override
  String get cancel => 'ביטול';

  @override
  String get save => 'שמירה';

  @override
  String get add => 'הוספה';

  @override
  String get delete => 'מחיקה';

  @override
  String get close => 'סגירה';

  @override
  String get photo => 'תמונה';

  @override
  String get editItem => 'עריכת פריט';

  @override
  String get newItem => 'פריט חדש';

  @override
  String get itemNameLabel => 'שם הפריט';

  @override
  String get quantityLabel => 'כמות';

  @override
  String quantityValue(int count) {
    return 'כמות: $count';
  }

  @override
  String get tagsLabel => 'תגיות (מופרדות בפסיקים)';

  @override
  String get tagsHint => 'בגדים, חורף';

  @override
  String get storageLocationLabel => 'מיקום אחסון:';

  @override
  String get unassignedShelf => 'ללא מדף';

  @override
  String languageChanged(String language) {
    return 'השפה שונתה ל: $language';
  }

  @override
  String get fallbackRoom => 'חדר';

  @override
  String get fallbackStorageUnit => 'ארון';

  @override
  String get holdToEdit => 'לחיצה ארוכה לעריכה';

  @override
  String get catalogTitle => 'הפריטים שלי (קטלוג)';

  @override
  String get catalogSubtitle => 'חדרים, ארונות, מדפים ורשימת פריטים';

  @override
  String get roomCleanupTitle => 'סידור החדר';

  @override
  String get roomCleanupSubtitle => 'ניתוח חדר מבולגן ואיתור פריטים מפוזרים';

  @override
  String get captureMessyRoom => 'צלמו את החדר המבולגן';

  @override
  String get cleanupHistoryTitle => 'היסטוריית סידור';

  @override
  String get cleanupHistorySubtitle => 'תוצאות קודמות של ניתוח הבלגן';

  @override
  String get newRoom => 'חדר חדש';

  @override
  String get roomHint => 'לדוגמה: חדר ילדים';

  @override
  String get roomsTitle => 'חדרים בבית';

  @override
  String get roomsEmpty => 'עדיין אין חדרים.\nהקישו על + כדי להוסיף את הראשון.';

  @override
  String furnitureInRoom(String roomName) {
    return 'אחסון בחדר $roomName';
  }

  @override
  String get furnitureHint => 'לדוגמה: ארון, כוננית, שידה';

  @override
  String get editStorageUnit => 'עריכת יחידת אחסון';

  @override
  String get storageUnitNameLabel => 'שם יחידת האחסון';

  @override
  String get deleteStorageUnitQuestion => 'למחוק את יחידת האחסון?';

  @override
  String get deleteStorageUnitWarning =>
      'כל המדפים יימחקו. הפריטים יישמרו תחת ללא מיקום.';

  @override
  String get deleteStorageUnit => 'מחיקת יחידת אחסון';

  @override
  String get storageUnitsEmpty =>
      'עדיין אין כאן אחסון.\nהקישו על + כדי להוסיף ארון או כוננית.';

  @override
  String shelfInStorageUnit(String storageUnitName) {
    return 'מדף בתוך $storageUnitName';
  }

  @override
  String get shelfHint => 'לדוגמה: מדף עליון, מגירה 1';

  @override
  String get editShelf => 'עריכת מדף';

  @override
  String get shelfNameLabel => 'שם המדף';

  @override
  String get deleteShelfQuestion => 'למחוק את המדף?';

  @override
  String get deleteShelfWarning => 'הפריטים במדף יישמרו תחת ללא מיקום.';

  @override
  String get deleteShelf => 'מחיקת מדף';

  @override
  String get shelvesEmpty => 'עדיין אין מדפים.\nהוסיפו מדף או מגירה.';

  @override
  String itemsOnShelfTitle(String shelfName) {
    return 'פריטים: $shelfName';
  }

  @override
  String get itemsOnShelfEmpty =>
      'עדיין אין דבר במדף הזה.\nהקישו על + כדי להוסיף פריט.';

  @override
  String get captureShelf => 'צלמו את המדף לניתוח';

  @override
  String get captureItem => 'צלמו את הפריט';

  @override
  String get savingPhoto => 'שומר תמונה...';

  @override
  String get captureError => 'לא ניתן לצלם';

  @override
  String get analyzingShelf => 'מנתח את המדף...';

  @override
  String get recognizeItemsWithAi => 'זיהוי פריטים באמצעות AI';

  @override
  String aiItemsAdded(int count) {
    return 'AI הוסיף $count פריטים בהצלחה!';
  }

  @override
  String get aiRecognitionFailed =>
      'AI לא הצליח לזהות פריטים, או שמפתח ה-API אינו מוגדר.';

  @override
  String get addExistingItems => 'הוספת פריטים קיימים';

  @override
  String addFromDatabaseTitle(String shelfName) {
    return 'הוספה מהקטלוג: $shelfName';
  }

  @override
  String get onlyUnassigned => 'ללא מיקום בלבד';

  @override
  String get noDatabaseItems => 'אין פריטי קטלוג זמינים';

  @override
  String get alreadyOnShelf => 'כבר במדף הזה';

  @override
  String itemsLinked(int count) {
    return 'פריטים שקושרו בהצלחה: $count';
  }

  @override
  String moveSelected(int count) {
    return 'העברת הנבחרים ($count)';
  }

  @override
  String get searchHint => 'חיפוש פריטים...';

  @override
  String get searchPrompt => 'הקלידו שם פריט לחיפוש';

  @override
  String get searchNoResults => 'לא נמצאו תוצאות';

  @override
  String get unassignedLocation => 'ללא מיקום';

  @override
  String get notLinkedLocation => 'לא מקושר';

  @override
  String get cleanupHistoryEmpty =>
      'אין פעולות סידור שמורות.\nצלמו חדר ממסך הבית.';

  @override
  String cleanupAt(String date) {
    return 'סידור בתאריך $date';
  }

  @override
  String cleanupHistoryCounts(int foundCount, int selectedCount) {
    return 'פריטים שנמצאו: $foundCount (נבחרו: $selectedCount)';
  }

  @override
  String get cleanupResultsTitle => 'תוצאות סידור החדר';

  @override
  String get clearAnalysisTooltip => 'מחיקת תוצאות הניתוח';

  @override
  String get noAnalysisData => 'אין נתוני ניתוח.';

  @override
  String get recognizedItems => 'פריטים שזוהו (בחרו את אלה שסודרו):';

  @override
  String chooseMatchForItem(String itemName) {
    return 'בחירת התאמה עבור ״$itemName״';
  }

  @override
  String get createNewItem => 'יצירה כפריט חדש';

  @override
  String get doNotLinkExisting => 'לא לקשר לפריט קיים בקטלוג';

  @override
  String get similarItems => 'פריטים דומים בקטלוג:';

  @override
  String get noSimilarItems => 'לא נמצאו פריטים דומים';

  @override
  String matchPercent(int percent) {
    return 'התאמה: $percent%';
  }

  @override
  String get putAway => 'החזרה למקום';

  @override
  String get saveAndRemove => 'שמירת הפריט והסרתו מהרשימה';

  @override
  String get eraseAndRemove => 'מחיקה והסרה מהרשימה';

  @override
  String itemQuantityAndTags(int quantity, String tags) {
    return 'כמות: $quantity | תגיות: $tags';
  }

  @override
  String get editItemTooltip => 'עריכת פריט';

  @override
  String databaseMatch(int percent, String location) {
    return 'בקטלוג ($percent%): $location';
  }

  @override
  String get newItemChooseMatch => 'פריט חדש (הקישו לבחירת התאמה)';

  @override
  String get selectCleanedItems => 'בחרו את הפריטים שהחזרתם למקום';

  @override
  String get roomCleanupComplete => 'החדר מסודר! פעולת הסידור הושלמה.';

  @override
  String cleanupProgress(int cleanedCount, int remainingCount) {
    return 'סודרו: $cleanedCount. נותרו: $remainingCount.';
  }

  @override
  String putAwaySelected(int count) {
    return 'החזרה למקום ($count)';
  }

  @override
  String recommendSimilarLocation(String itemName, String location) {
    return 'דומה ל״$itemName״: יש לשים ב-$location';
  }

  @override
  String get recommendUnassigned => 'אין המלצה; יש לשים תחת ללא מיקום';

  @override
  String get addItemTitle => 'הוספת פריט';

  @override
  String get addItemPlaceholder => 'טופס הוספת הפריט יופיע כאן';
}
