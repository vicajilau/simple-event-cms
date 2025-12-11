import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sec/l10n/app_localizations.dart';

void main() {
  // 2. Añade un tearDown para limpiar getIt después de cada test.
  // Esto previene que este fichero contamine a otros y se protege a sí mismo.
  tearDown(() async {
    await GetIt.instance.reset();
  });

  // Helper para obtener las localizaciones para un `Locale` específico

  Future<AppLocalizations> getLocalizations(WidgetTester tester, Locale locale) async {
    late AppLocalizations localizations;

    // ¡EL PASO CLAVE Y MÁS ROBUSTO!
    // Forzamos el locale a nivel del motor de binding del test.
    // Esto sobreescribe cualquier configuración regional del sistema (local o CI).
    await tester.binding.setLocale(locale.languageCode, locale.countryCode ?? "en");

    await tester.pumpWidget(
      MaterialApp(
        // Ya no es estrictamente necesario pasar el locale aquí, pero no hace daño.
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

    // Un pump para asegurar que el widget tree se construye con el locale forzado.
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
