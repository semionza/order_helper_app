import 'package:flutter/widgets.dart';

class SpeechLocaleOption {
  const SpeechLocaleOption(this.localeId, this.label);

  final String localeId;
  final String label;
}

const speechLocaleOptions = [
  SpeechLocaleOption('ru_RU', 'RU'),
  SpeechLocaleOption('en_US', 'EN'),
  SpeechLocaleOption('he_IL', 'HE'),
];

int speechLocaleIndexFor(BuildContext context) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final index = speechLocaleOptions.indexWhere(
    (option) => option.localeId.startsWith(languageCode),
  );
  return index < 0 ? 1 : index;
}

String speechLocaleIdFor(BuildContext context) {
  return speechLocaleOptions[speechLocaleIndexFor(context)].localeId;
}