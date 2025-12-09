import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/presentation/ui/dialogs/delete_dialog.dart';

void main() {
  group('DeleteDialog', () {
    testWidgets('should show title and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeleteDialog(
            title: 'Test Title',
            message: 'Test Message',
            onDeletePressed: () {},
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('should call onDeletePressed when delete button is pressed',
        (WidgetTester tester) async {
      bool deletePressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DeleteDialog(
            title: 'Test Title',
            message: 'Test Message',
            onDeletePressed: () {
              deletePressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deletePressed, isTrue);
    });

    testWidgets('should close dialog when cancel button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => DeleteDialog(
                    title: 'Test Title',
                    message: 'Test Message',
                    onDeletePressed: () {},
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(DeleteDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(DeleteDialog), findsNothing);
    });
  });
}
