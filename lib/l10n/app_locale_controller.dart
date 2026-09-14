import 'package:flutter/widgets.dart';

final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

const supportedAppLocales = [
  Locale('en'),
  Locale('ru'),
  Locale('he'),
];