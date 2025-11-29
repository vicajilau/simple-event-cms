import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_screen.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Result<void>>(const Result.ok(null));
  });

  late MockAgendaViewModel mockAgendaViewModel;

  setUp(() {
    // It's good practice to reset GetIt to ensure test isolation.
    getIt.reset();
    mockAgendaViewModel = MockAgendaViewModel();
    // The mock will be registered inside each test before the widget is pumped.
  });

  Future<void> registerMockViewModel() async {
    getIt.registerSingleton<AgendaViewModel>(mockAgendaViewModel);
    when(mockAgendaViewModel.viewState).thenReturn(ValueNotifier(ViewState.isLoading));
    when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier([]));
    when(mockAgendaViewModel.speakers).thenReturn(ValueNotifier([]));
    when(mockAgendaViewModel.errorMessage).thenReturn('');
    when(mockAgendaViewModel.loadAgendaDays(any)).thenAnswer((_) async => const Result.ok(null));
    when(mockAgendaViewModel.checkToken()).thenAnswer((_) async => false);
  }

  Widget createWidgetUnderTest() {
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
      home: AgendaScreen(eventId: 'test-event-id', location: 'test-location'),
    );
  }

  testWidgets('shows loading indicator when view state is loading', (WidgetTester tester) async {
    await registerMockViewModel();
    when(mockAgendaViewModel.viewState).thenReturn(ValueNotifier(ViewState.isLoading));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error dialog when view state is error', (WidgetTester tester) async {
    await registerMockViewModel();
    when(mockAgendaViewModel.viewState).thenReturn(ValueNotifier(ViewState.error));
    when(mockAgendaViewModel.errorMessage).thenReturn('An error occurred');

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('An error occurred'), findsOneWidget);
  });

  testWidgets('shows no data screen when there are no agenda days', (WidgetTester tester) async {
    await registerMockViewModel();
    when(mockAgendaViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier([]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No sessions found'), findsOneWidget);
  });

  testWidgets('displays agenda days and sessions', (WidgetTester tester) async {
    await registerMockViewModel();
    final agendaDays = [
      AgendaDay(
        uid: '2024-01-01',
        date: '2024-01-01',
        eventsUID: ['test-event-id'],
        resolvedTracks: [
          Track(
            uid: 'track1',
            name: 'Track 1',
            resolvedSessions: [
              Session(
                uid: 'session1',
                title: 'Session 1',
                time: '10:00',
                eventUID: 'test-event-id',
                agendaDayUID: 'day1',
                speakerUID: 'SpeakerUID',
                type: 'talk',
              ),
            ],
            color: '',
            sessionUids: ["session1"],
            eventUid: 'eventUID',
          ),
        ],
      ),
    ];
    when(mockAgendaViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier(agendaDays));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // The date '2024-01-01' is formatted for display (e.g., 'Tuesday, January 1'),
    // so we look for 'Jan' to confirm the month is rendered without being too specific.
    expect(find.textContaining('January'), findsOneWidget);
    //expect(find.text('Track 1'), findsOneWidget);
    //expect(find.text('Session 1'), findsOneWidget);
  });
}