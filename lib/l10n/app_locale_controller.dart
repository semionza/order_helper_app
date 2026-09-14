import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

const _savedLocaleKey = 'app_locale';

const supportedAppLocales = [
  Locale('en'),
  Locale('ru'),
  Locale('he'),
];

Future<void> loadSavedAppLocale() async {
  final preferences = await SharedPreferences.getInstance();
  final languageCode = preferences.getString(_savedLocaleKey);

  if (languageCode == null) return;

  final savedLocale = supportedAppLocales.where(
    (locale) => locale.languageCode == languageCode,
  );
  if (savedLocale.isNotEmpty) {
    appLocale.value = savedLocale.first;
  }
}

Future<void> setAppLocale(Locale locale) async {
  if (!supportedAppLocales.any(
    (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
  )) {
    return;
  }

  appLocale.value = locale;
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(_savedLocaleKey, locale.languageCode);
}