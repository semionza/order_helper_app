import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_helper_app/l10n/app_locale_controller.dart';
import 'package:order_helper_app/l10n/app_localizations.dart';
import 'package:order_helper_app/l10n/locale_utils.dart';
import 'package:order_helper_app/main.dart';

void main() {
  tearDown(() => appLocale.value = null);

  Widget localizedApp(Locale locale) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('he')],
      home: Builder(
        builder: (context) => Text(
          '${AppLocalizations.of(context).appTitle}|${speechLocaleIdFor(context)}',
        ),
      ),
    );
  }

  testWidgets('Hebrew localization uses RTL and he_IL speech', (tester) async {
    await tester.pumpWidget(localizedApp(const Locale('he')));

    expect(find.text('מדריך לסדר|he_IL'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(Text))), TextDirection.rtl);
  });

  testWidgets('English and Russian use matching speech locales', (tester) async {
    await tester.pumpWidget(localizedApp(const Locale('en')));
    expect(find.text('Order Guide|en_US'), findsOneWidget);

    await tester.pumpWidget(localizedApp(const Locale('ru')));
    expect(find.text('Гид по порядку|ru_RU'), findsOneWidget);
  });

  testWidgets('Home language menu changes the application locale', (tester) async {
    appLocale.value = const Locale('en');
    await tester.pumpWidget(const OrderHelperApp());

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RU · Russian'));
    await tester.pumpAndSettle();

    expect(find.text('Гид по порядку'), findsOneWidget);
    expect(appLocale.value, const Locale('ru'));
  });
}
