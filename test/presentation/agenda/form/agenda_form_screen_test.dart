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
import 'package:sec/presentation/ui/screens/speaker/speaker_form_screen.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAgendaFormViewModel mockViewModel;

  final String eventId = 'event1';
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
  final session = Session(
    uid: 'session1',
    title: 'Session 1',
    eventUID: eventId,
    agendaDayUID: 'day1',
    speakerUID: 'speaker1',
    type: 'talk',
    description: 'description',
    time: '',
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

  group('AgendaFormData copyWith', () {
    test('The copyWith method should update only the provided fields', () {
      final original = AgendaFormData(
        session: session,
        trackId: 'track1',
        agendaDayId: 'day1',
        eventId: 'event1',
      );

      final updated = original.copyWith(trackId: 'track2');

      expect(updated.trackId, equals('track2'));
      expect(updated.session, equals(original.session));
      expect(updated.agendaDayId, equals(original.agendaDayId));
      expect(updated.eventId, equals(original.eventId));
    });

    test(
      'The copyWith method should keep original values when no params are passed',
      () {
        final original = AgendaFormData(
          session: session,
          trackId: 'track1',
          agendaDayId: 'day1',
          eventId: 'event1',
        );

        final copy = original.copyWith();

        expect(copy.session, equals(original.session));
        expect(copy.trackId, equals(original.trackId));
        expect(copy.agendaDayId, equals(original.agendaDayId));
        expect(copy.eventId, equals(original.eventId));
      },
    );

    test('The copyWith method should create a new instance', () {
      final original = AgendaFormData(eventId: eventId, trackId: 'track1');
      final copy = original.copyWith(trackId: 'track2');

      expect(copy, isNot(same(original)));
    });
  });

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

  testWidgets('should add a new speaker when add button is pressed', (WidgetTester tester) async {
    when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));


    when(mockViewModel.addSpeaker(any, any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
    );
    await tester.pumpAndSettle();

    // Find the add speaker button and tap it.
    final addButton = find.byKey(Key("add_speaker_button"));
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Verify that we have navigated to the SpeakerFormScreen
    expect(find.byType(SpeakerFormScreen), findsOneWidget);

  });
}
