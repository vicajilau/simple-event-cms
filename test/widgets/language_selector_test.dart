import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/widgets/language_selector.dart';

void main() {
  // Lista de idiomas soportados, para no depender de la implementación interna
  const supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('ca'),
    Locale('eu'),
    Locale('pt'),
    Locale('fr'),
    Locale('it'),
  ];

  // Helper para montar el widget con el contexto necesario
  Future<void> pumpWidget(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: supportedLocales,
        home: Scaffold(body: Center(child: widget)),
      ),
    );
  }

  group('LanguageSelector', () {
    testWidgets('displays the current language name', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        const LanguageSelector(
          currentLocale: Locale('es'),
          onLanguageChanged: print,
        ),
      );
      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('opens a menu with all languages on tap', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        const LanguageSelector(
          currentLocale: Locale('en'),
          onLanguageChanged: print,
        ),
      );

      await tester.tap(find.byType(LanguageSelector));
      await tester
          .pumpAndSettle(); // Espera a que la animación del menú termine

      expect(
        find.text('English'),
        findsNWidgets(3),
      ); // Uno en el botón, otro en el menú
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Galego'), findsOneWidget);
      expect(find.text('Català'), findsOneWidget);
    });

    testWidgets('calls onLanguageChanged when a new language is selected', (
      WidgetTester tester,
    ) async {
      Locale? selectedLocale;
      await pumpWidget(
        tester,
        LanguageSelector(
          currentLocale: const Locale('en'),
          onLanguageChanged: (locale) => selectedLocale = locale,
        ),
      );

      await tester.tap(find.byType(LanguageSelector));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español').last); // Toca el item del menú
      await tester.pumpAndSettle();

      expect(selectedLocale, const Locale('es'));
    });
  });

  group('CompactLanguageSelector', () {
    testWidgets('displays the current language code in uppercase', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        const CompactLanguageSelector(
          currentLocale: Locale('eu'),
          onLanguageChanged: print,
        ),
      );
      expect(find.text('EU'), findsOneWidget);
    });

    testWidgets('calls onLanguageChanged when a new language is selected', (
      WidgetTester tester,
    ) async {
      Locale? selectedLocale;
      await pumpWidget(
        tester,
        CompactLanguageSelector(
          currentLocale: const Locale('en'),
          onLanguageChanged: (locale) => selectedLocale = locale,
        ),
      );

      await tester.tap(find.byType(CompactLanguageSelector));
      await tester.pumpAndSettle();

      await tester.tap(find.text('IT').last);
      await tester.pumpAndSettle();

      expect(selectedLocale, const Locale('it'));
    });
  });
}
