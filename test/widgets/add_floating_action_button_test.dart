import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/presentation/ui/widgets/add_floating_action_button.dart';

void main() {
  testWidgets(
    'AddFloatingActionButton should render correctly and respond to taps',
    (WidgetTester tester) async {
      // Arrange
      bool pressed = false;
      final widget = AddFloatingActionButton(onPressed: () => pressed = true);

      // Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(floatingActionButton: widget)),
      );

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Assert
      expect(pressed, isTrue);
    },
  );
}
