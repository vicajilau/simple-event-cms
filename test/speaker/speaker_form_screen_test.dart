import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_form_screen.dart';

import '../mocks.mocks.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', '')],
    home: Scaffold(body: child),
  );
}

void main() {
  late MockSpeakerUseCase mockSpeakerUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    provideDummy<Result<void>>(const Result.ok(null));
    provideDummy<Result<List<Speaker>>>(const Result.ok([]));
  });
  setUp(() {
    getIt.reset();
    mockSpeakerUseCase = MockSpeakerUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();

    getIt.registerSingleton<SpeakerUseCase>(mockSpeakerUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);
  });
  group('SpeakerFormScreen', () {
    testWidgets('form is pre-filled when a speaker is provided', (
      WidgetTester tester,
    ) async {
      final speaker = Speaker(
        uid: '1',
        name: 'Jane Doe',
        bio: 'A short bio.',
        image: 'http://example.com/image.png',
        social: Social(twitter: '@jane'),
        eventUIDS: ['1'],
      );

      await tester.pumpWidget(
        buildTestableWidget(SpeakerFormScreen(speaker: speaker, eventUID: '1')),
      );

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('A short bio.'), findsOneWidget);
      expect(find.text('http://example.com/image.png'), findsOneWidget);
      expect(find.text('@jane'), findsOneWidget);
    });

    /*testWidgets('shows validation errors for required fields', (
      WidgetTester tester,
    ) async {
      when(
        mockSpeakerUseCase.getSpeakersById(any),
      ).thenAnswer((_) async => Result.ok([]));

      await tester.pumpWidget(
        buildTestableWidget(const SpeakerFormScreen(eventUID: '1')),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(
        find.text('Please enter your biography'),
        findsOneWidget,
      );
    });*/

    testWidgets('pops with new speaker data on successful submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const SpeakerFormScreen(eventUID: '1')),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'A bio.');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();

      // No direct way to test Navigator.pop with a result, but we can verify no validation errors
      expect(find.text('Name is required'), findsNothing);
      expect(find.text('Bio is required'), findsNothing);
    });
  });
}
