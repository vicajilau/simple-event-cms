import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sec/core/utils/date_utils.dart';

// A wrapper widget to provide a BuildContext with a specific locale.
Widget buildTestWidget(Locale locale, Widget child) {
  return MaterialApp(
    home: Localizations(
      locale: locale,
      delegates: const [
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: child,
    ),
  );
}

void main() {
  // Initialize only the locales that will be used in the success cases.
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('es', null);
  });

  group('EventDateUtils', () {
    const testDateString = '2025-03-17'; // This was a Monday

    // --- Tests for getDayName ---
    group('getDayName', () {
      testWidgets('should return the full day name in English (en_US)',
              (WidgetTester tester) async {
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('en', 'US'),
                Builder(builder: (context) {
                  final dayName = EventDateUtils.getDayName(testDateString, context);
                  expect(dayName, 'Monday');
                  return Container();
                }),
              ),
            );
          });

      testWidgets('should fall back to English if the locale is not initialized (catch block test)',
              (WidgetTester tester) async {
            // We use a locale ('xx') that we haven't initialized with `initializeDateFormatting`.
            // This will cause an exception inside the `try` block.
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('xx'), // Uninitialized locale
                Builder(builder: (context) {
                  final dayName = EventDateUtils.getDayName(testDateString, context);
                  // The catch block should execute and format in English.
                  expect(dayName, 'Monday');
                  return Container();
                }),
              ),
            );
          });
    });

    // --- Tests for getShortDayName ---
    group('getShortDayName', () {
      testWidgets('should return the short day name in Spanish (es)',
              (WidgetTester tester) async {
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('es'),
                Builder(builder: (context) {
                  final shortDayName = EventDateUtils.getShortDayName(testDateString, context);
                  expect(shortDayName, 'lun');
                  return Container();
                }),
              ),
            );
          });

      testWidgets('should fall back to English if the locale is not initialized (catch block test)',
              (WidgetTester tester) async {
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('xx'), // Uninitialized locale
                Builder(builder: (context) {
                  final shortDayName = EventDateUtils.getShortDayName(testDateString, context);
                  expect(shortDayName, 'Mon');
                  return Container();
                }),
              ),
            );
          });
    });

    // --- Tests for getFormattedDate ---
    group('getFormattedDate', () {
      testWidgets('should return the formatted date in English (en_US)',
              (WidgetTester tester) async {
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('en', 'US'),
                Builder(builder: (context) {
                  final formattedDate = EventDateUtils.getFormattedDate(testDateString, context);
                  expect(formattedDate, 'March 17, 2025');
                  return Container();
                }),
              ),
            );
          });

      testWidgets('should fall back to English if the locale is not initialized (catch block test)',
              (WidgetTester tester) async {
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('xx'), // Uninitialized locale
                Builder(builder: (context) {
                  final formattedDate = EventDateUtils.getFormattedDate(testDateString, context);
                  expect(formattedDate, 'March 17, 2025');
                  return Container();
                }),
              ),
            );
          });
    });

    // --- Tests for getShortFormattedDate ---
    group('getShortFormattedDate', () {
      testWidgets('should return the short formatted date in Spanish (es)',
              (WidgetTester tester) async {
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('es'),
                Builder(builder: (context) {
                  final shortFormattedDate = EventDateUtils.getShortFormattedDate(testDateString, context);
                  expect(shortFormattedDate, 'mar 17');
                  return Container();
                }),
              ),
            );
          });

      testWidgets('should fall back to English if the locale is not initialized (catch block test)',
              (WidgetTester tester) async {
            await tester.pumpWidget(
              buildTestWidget(
                const Locale('xx'), // Uninitialized locale
                Builder(builder: (context) {
                  final shortFormattedDate = EventDateUtils.getShortFormattedDate(testDateString, context);
                  expect(shortFormattedDate, 'Mar 17');
                  return Container();
                }),
              ),
            );
          });
    });
  });
}
