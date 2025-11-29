import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/core/models/event.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_screen.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAgendaFormViewModel mockViewModel;

  final agendaDay = AgendaDay(
    uid: 'day1',
    date: '2024-01-01',
    eventsUID: ['event1'],
  );
  final track = Track(
    uid: 'track1',
    name: 'Track 1',
    sessionUids: [],
    eventUid: 'event1',
    color: '',
    resolvedSessions: [],
  );
  final speaker = Speaker(
    uid: 'speaker1',
    name: 'Speaker 1',
    bio: '',
    image: '',
    social: Social(),
    eventUIDS: ['event1'],
  );
  final event = Event(
    uid: 'event1',
    tracks: [],
    eventName: '',
    year: '',
    primaryColor: '',
    secondaryColor: '',
    eventDates: MockEventDates(),
  );

  setUpAll(() async {
    await getIt.reset(); // ADDED
    mockViewModel = MockAgendaFormViewModel();
    getIt.registerSingleton<AgendaFormViewModel>(mockViewModel);

    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.isLoading));
    when(
      mockViewModel.getSpeakersForEventId(any),
    ).thenAnswer((_) async => [speaker]);
    when(
      mockViewModel.getTracksByEventId(any),
    ).thenAnswer((_) async => [track]);
    when(
      mockViewModel.getAgendaDayByEventId(any),
    ).thenAnswer((_) async => [agendaDay]);
    when(mockViewModel.getEventById(any)).thenAnswer((_) async => event);
    when(
      mockViewModel.saveSession(
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
      ),
    ).thenAnswer((_) async => [agendaDay]);
  });

  Widget createWidgetUnderTest({required AgendaFormData data}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      home: AgendaFormScreen(data: data),
    );
  }

  testWidgets('shows loading indicator when view state is loading', (
    WidgetTester tester,
  ) async {
    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.isLoading));
    await tester.pumpWidget(
      createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  /*testWidgets('shows error dialog when view state is error', (
    WidgetTester tester,
  ) async {
    when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.error));
    when(mockViewModel.errorMessage).thenReturn('An error occurred');

    await tester.pumpWidget(
      createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
    );
    await tester.pump();

    expect(find.text('An error occurred'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pump();

    verify(mockViewModel.setErrorKey(null)).called(1);
  });*/

  /*testWidgets('create new session and save it', (WidgetTester tester) async {
    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));

    await tester.pumpWidget(
      createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'New Session');
    await tester.tap(find.text('Select a day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024-01-01'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select a room'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Track 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Start time:'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').first);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('End time:'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select a speaker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speaker 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select a talk type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('talk'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      mockViewModel.saveSession(
        any,
        any,
        'New Session',
        any,
        any,
        speaker,
        any,
        'talk',
        'event1',
        'day1',
        any,
        'track1',
        any,
        any,
      ),
    ).called(1);
  });*/

  /*testWidgets('edit existing session and save it', (WidgetTester tester) async {
    final session = Session(
      uid: 'session1',
      title: 'Session 1',
      eventUID: 'event1',
      agendaDayUID: 'day1',
      speakerUID: 'speaker1',
      type: 'talk',
      description: 'description',
      time: '',
    );
    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));

    await tester.pumpWidget(
      createWidgetUnderTest(
        data: AgendaFormData(
          session: session,
          trackId: 'track1',
          eventId: 'event1',
          agendaDayId: 'day1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Updated Session');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      mockViewModel.saveSession(
        any,
        'session1',
        'Updated Session',
        any,
        any,
        speaker,
        'description',
        'talk',
        'event1',
        'day1',
        any,
        'track1',
        'track1',
        []
      ),
    ).called(1);
  });*/

  /*testWidgets('add new track', (WidgetTester tester) async {
    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.addTrack(any, any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'New Track');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(mockViewModel.addTrack(any, any)).called(1);
  });*/
}
