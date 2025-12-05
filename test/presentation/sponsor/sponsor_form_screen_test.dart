import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_form_screen.dart';
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
  group('SponsorFormScreen', () {
    testWidgets('form is pre-filled when a sponsor is provided', (WidgetTester tester) async {
      final sponsor = Sponsor(
        uid: '1',
        name: 'Test Sponsor',
        logo: 'http://example.com/logo.png',
        website: 'http://example.com',
        type: '',
        eventUID: '1',
      );

      await tester.pumpWidget(buildTestableWidget(SponsorFormScreen(sponsor: sponsor, eventUID: '1')));

      expect(find.text('Test Sponsor'), findsOneWidget);
      expect(find.text('http://example.com/logo.png'), findsOneWidget);
      expect(find.text('http://example.com'), findsOneWidget);
    });

    testWidgets('shows validation errors for required fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(SponsorFormScreen(eventUID: '1')));


      await tester.enterText
        (find.byType(TextFormField).at(2), 'url');
      
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();

      expect(find.text('Please enter the Sponsor\'s name'), findsOneWidget);
    });

    /*testWidgets('pops with new sponsor data on successful submission', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SponsorFormScreen(eventUID: '1')));

      await tester.enterText(find.byType(TextFormField).at(0), 'New Sponsor');
      await tester.enterText(find.byType(TextFormField).at(1), 'http://example.com/new_logo.png');
      await tester.enterText(find.byType(TextFormField).at(2), 'http://example.com/new');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();

      expect(find.text('Sponsor name cannot be empty'), findsNothing);
      expect(find.text('Logo URL cannot be empty'), findsNothing);
      expect(find.text('Website URL cannot be empty'), findsNothing);
    });*/
  });
}
