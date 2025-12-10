import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/widgets/error_view.dart';

void main() {
  // Helper para montar el widget con el contexto necesario de Material y Localizaciones
  Future<void> pumpErrorView(
    WidgetTester tester, {
    required String errorMessage,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(
          'en',
        ), // Forzar un locale para que el test sea predecible
        home: Scaffold(body: ErrorView(errorMessage: errorMessage)),
      ),
    );
  }

  group('ErrorView Widget', () {
    testWidgets('should display the provided error message', (
      WidgetTester tester,
    ) async {
      // Arrange
      const message = 'A custom error occurred.';
      await pumpErrorView(tester, errorMessage: message);

      // Assert
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display default message when errorMessage is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpErrorView(tester, errorMessage: '');

      // Assert
      // Asumimos que el valor para 'errorLoadingData' en inglés es 'Error loading data'.
      // Si este test falla, revisa el valor en tus archivos .arb
      expect(find.text('Error loading data'), findsOneWidget);
    });
  });
}
