import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/presentation/ui/widgets/section_input_form.dart';

void main() {
  testWidgets('SectionInputForm should display label and child input', (
    WidgetTester tester,
  ) async {
    // Arrange
    const String labelText = 'Test Label';
    final Widget childInput = TextFormField(key: const Key('test_input'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SectionInputForm(label: labelText, childInput: childInput),
        ),
      ),
    );

    // Assert
    // Verifica que la etiqueta se muestra
    expect(find.text(labelText), findsOneWidget);

    // Verifica que el widget hijo se muestra
    expect(find.byKey(const Key('test_input')), findsOneWidget);

    // Verifica que están en una columna
    expect(find.byType(Column), findsOneWidget);

    // Verifica que el texto está por encima del input
    final column = tester.widget<Column>(find.byType(Column));
    expect(column.children.length, 2);
    expect(column.children[0], isA<Text>());
    expect(column.children[1], isA<TextFormField>());
  });
}
