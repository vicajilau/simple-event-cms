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
    await tester.pumpWidget(
      // 1. Envuelve tu MaterialApp en un widget simple que no haga nada.
      // Esto asegura que podemos reconstruir desde la raíz.
      SizedBox(
        child: MaterialApp(
          // 2. NO establezcas el locale aquí inicialmente.
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    // 3. ¡EL PASO CLAVE! Llama a pumpWidget OTRA VEZ, pero ahora
    //    pasando el Locale. Esto FUERZA una reconstrucción completa con el
    //    idioma correcto.
    await tester.pumpWidget(
      MaterialApp(
        locale: locale, // Ahora sí establece el locale deseado.
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

    // 4. Un último pump para asegurar que todo se asiente.
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
