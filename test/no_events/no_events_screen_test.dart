import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/no_events/no_events_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''),
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  group('MaintenanceScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const MaintenanceScreen()));

      expect(find.byIcon(Icons.event_busy_outlined), findsOneWidget);
      expect(find.text('No events to show.'), findsOneWidget);
      expect(find.text('Try again later'), findsOneWidget);
    });
  });
}
