import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/presentation/ui/widgets/event_filter_button.dart';

void main() {
  group('EventFilterButton', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      required EventFilter selectedFilter,
      required ValueChanged<EventFilter> onFilterChanged,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                EventFilterButton(
                  selectedFilter: selectedFilter,
                  onFilterChanged: onFilterChanged,
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('should display filter icon', (WidgetTester tester) async {
      await pumpWidget(
        tester,
        selectedFilter: EventFilter.all,
        onFilterChanged: (_) {},
      );

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should open menu with all filter options on tap', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        selectedFilter: EventFilter.all,
        onFilterChanged: (_) {},
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle(); // Wait for menu animation

      expect(find.text(EventFilter.all.label), findsOneWidget);
      expect(find.text(EventFilter.past.label), findsOneWidget);
      expect(find.text(EventFilter.current.label), findsOneWidget);
    });

    testWidgets('should call onFilterChanged when a new filter is selected', (
      WidgetTester tester,
    ) async {
      EventFilter? result;
      await pumpWidget(
        tester,
        selectedFilter: EventFilter.all,
        onFilterChanged: (filter) => result = filter,
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.text(EventFilter.past.label));
      await tester.pumpAndSettle();

      expect(result, EventFilter.past);
    });

    testWidgets('should show selected filter with a checked radio button', (
      WidgetTester tester,
    ) async {
      await pumpWidget(
        tester,
        selectedFilter: EventFilter.current,
        onFilterChanged: (_) {},
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      final checkedRadioButton = find.byIcon(Icons.radio_button_checked);
      final currentFilterRow = find.ancestor(
        of: find.text(EventFilter.current.label),
        matching: find.byType(Row),
      );

      expect(
        find.descendant(of: currentFilterRow, matching: checkedRadioButton),
        findsOneWidget,
      );

      final uncheckedRadioButton = find.byIcon(Icons.radio_button_unchecked);
      final allFilterRow = find.ancestor(
        of: find.text(EventFilter.all.label),
        matching: find.byType(Row),
      );

      expect(
        find.descendant(of: allFilterRow, matching: uncheckedRadioButton),
        findsOneWidget,
      );
    });
  });
}
