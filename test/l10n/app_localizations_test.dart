import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sec/l10n/app_localizations.dart';

void main() {
  // 2. Add a tearDown to clean up getIt after each test.
  // This prevents this file from polluting others and protects itself.
  tearDown(() async {
    await GetIt.instance.reset();
  });

  // Helper to get localizations for a specific `Locale`

  Future<AppLocalizations> getLocalizations(WidgetTester tester, Locale locale) async {
    late AppLocalizations localizations;

    // 1. Call setLocale.
    await tester.binding.setLocale(locale.languageCode, locale.countryCode??"");

    // 2. THE KEY MISSING STEP!
    //    Add a pump() here. This gives the framework the necessary time
    //    to process the locale change and mark the widget tree
    //    as "needs rebuild".
    await tester.pump();

    // 3. Now, when you call pumpWidget, it's already aware of the new locale.
    await tester.pumpWidget(
      MaterialApp(
        // Passing the locale here now acts as a secondary confirmation.
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            localizations = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // A final pump to ensure the Builder runs.
    await tester.pump();

    return localizations;
  }

  group('AppLocalizations Coverage Tests', () {
    final translations = {
      const Locale('en'): 'Loading...',
      const Locale('es'): 'Cargando...',
      const Locale('ca'): 'Carregant...',
      const Locale('eu'): 'Kargatzen...',
      const Locale('fr'): 'Chargement...',
      const Locale('gl'): 'Cargando...',
      const Locale('it'): 'Caricamento...',
      const Locale('pt'): 'Carregando...',
    };

    translations.forEach((locale, expectedLoadingText) {
      testWidgets('should load ${locale.languageCode} translations correctly', (WidgetTester tester) async {
        // Arrange
        final localizations = await getLocalizations(tester, locale);

        // Act & Assert
        expect(localizations.loading, expectedLoadingText, reason: 'Failed for ${locale.languageCode}');
      });
    });
  });
}
