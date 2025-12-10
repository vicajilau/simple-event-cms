import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/l10n/app_localizations.dart';

void main() {
  // Helper para obtener las localizaciones para un `Locale` específico
  Future<AppLocalizations> getLocalizations(WidgetTester tester, Locale locale) async {
    late AppLocalizations localizations;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate, // Añadido para ser exhaustivo
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            localizations = AppLocalizations.of(context)!;
            return const SizedBox.shrink(); // Widget vacío
          },
        ),
      ),
    );
    await tester.pump(); // Asegurarse de que el frame se ha renderizado
    return localizations;
  }

  group('AppLocalizations Coverage Tests', () {
    // Mapa con los locales y una traducción esperada para cada uno.
    // Usamos 'loading' que es una clave común para verificar.
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

    // Generar un test para cada idioma soportado
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
