import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';

void main() {
  group('CustomErrorDialog', () {
    testWidgets('should display error message and button', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool buttonPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CustomErrorDialog(
                      errorMessage: 'Test Error Message',
                      buttonText: 'Close',
                      onCancel: () => buttonPressed = true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act: Muestra el diálogo
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert: Verifica el contenido del diálogo
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test Error Message'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Act: Presiona el botón
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Assert: Verifica que la función se llamó y el diálogo se cerró
      expect(buttonPressed, isTrue);
    });

    testWidgets('should not display button if onCancel is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CustomErrorDialog(
                      errorMessage: 'Another Error',
                      buttonText: 'OK',
                      // onCancel es null por defecto en este caso
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Another Error'), findsOneWidget);
      expect(find.text('OK'), findsNothing);
    });
  });
}
