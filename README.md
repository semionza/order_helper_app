# Order Helper

A Flutter app for cataloging household items and organizing room cleanup.

## Localization

The interface supports English (`en`), Russian (`ru`), and Hebrew (`he`). On first launch, Flutter selects the closest supported language from the device locale. When the user selects a language from the Home screen, that choice is saved locally and restored on the next launch. Hebrew automatically uses RTL layout through Flutter's localization delegates.

1. Add or edit messages in `lib/l10n/app_en.arb`. English is the template catalog.
2. Add the same keys to `lib/l10n/app_ru.arb` and `lib/l10n/app_he.arb`.
3. Declare typed placeholders in the `@messageKey` metadata in the English catalog.
4. Run `flutter gen-l10n` to regenerate `AppLocalizations`.
5. Access messages with `AppLocalizations.of(context).messageKey`.
6. Run `flutter analyze` and `flutter test` before shipping catalog changes.

Generation is enabled by `flutter.generate: true` in `pubspec.yaml` and configured in `l10n.yaml`. The root `MaterialApp` registers the generated delegate plus Flutter's Material, Widgets, and Cupertino delegates.

Speech recognition follows the resolved app language through `speechLocaleIdFor(context)`:

- `en` uses `en_US`
- `ru` uses `ru_RU`
- `he` uses `he_IL`

Gemini analysis also receives the active language code so newly recognized item names and tags match the interface language. Existing room, shelf, item, and tag names remain user data and are not translated automatically.
