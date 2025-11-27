import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speakers_screen.dart';
import 'package:sec/presentation/view_model_common.dart';

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
  late MockSpeakerViewModel mockViewModel;

  setUpAll(() {
    // If you have other global setup, it can go here.
    // Avoid getIt.reset() in setUpAll if other test suites depend on registrations.
  });

  setUp(() {
    mockViewModel = MockSpeakerViewModel();

    // Register the mock ViewModel before each test.
    getIt.registerSingleton<SpeakerViewModel>(mockViewModel);

    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.speakers).thenReturn(ValueNotifier([]));
    when(mockViewModel.errorMessage).thenReturn('');
    when(mockViewModel.checkToken()).thenAnswer((_) async => false);
    when(mockViewModel.setup(any)).thenAnswer((_) async {});
  });

  tearDown(() {
    // Unregister the singleton after each test to ensure test isolation.
    getIt.unregister<SpeakerViewModel>();
  });

  group('SpeakersScreen', () {
    testWidgets('shows loading indicator when loading', (
      WidgetTester tester,
    ) async {
      when(
        mockViewModel.viewState,
      ).thenReturn(ValueNotifier(ViewState.isLoading));

      await tester.pumpWidget(
        buildTestableWidget(SpeakersScreen(eventId: '1')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no data screen when there are no speakers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(SpeakersScreen(eventId: '1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No speakers registered'),
        findsOneWidget,
      );
    });

    testWidgets('shows speaker grid when speakers are available', (
      WidgetTester tester,
    ) async {
      final speakers = [
        Speaker(
          uid: '1',
          name: 'John Doe',
          bio: 'Bio',
          social: Social(),
          eventUIDS: ['1'],
          image: '',
        ),
      ];
      when(mockViewModel.speakers).thenReturn(ValueNotifier(speakers));

      await tester.pumpWidget(
        buildTestableWidget(SpeakersScreen(eventId: '1')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('admin can see edit and delete buttons', (
      WidgetTester tester,
    ) async {
      final speakers = [
        Speaker(
          uid: '1',
          name: 'John Doe',
          bio: 'Bio',
          social: Social(),
          eventUIDS: ['1'],
          image: '',
        ),
      ];
      when(mockViewModel.speakers).thenReturn(ValueNotifier(speakers));
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);

      await tester.pumpWidget(
        buildTestableWidget(SpeakersScreen(eventId: '1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outlined), findsOneWidget);
    });
  });
}
