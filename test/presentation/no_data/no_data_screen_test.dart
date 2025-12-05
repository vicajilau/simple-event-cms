import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/presentation/ui/screens/no_data/no_data_screen.dart';

void main() {
  group('NoDataScreen', () {
    testWidgets('renders with default icon when none is provided', (WidgetTester tester) async {
      const message = 'No data available';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoDataScreen(message: message),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });

    testWidgets('renders with the provided custom icon', (WidgetTester tester) async {
      const message = 'Custom message';
      const customIcon = Icons.error;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoDataScreen(message: message, icon: customIcon),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(customIcon), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsNothing);
    });
  });
}
