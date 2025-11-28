import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/core/models/event.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../mocks.mocks.dart';

void main() {
  late AgendaFormViewModelImpl viewModel;
  late MockAgendaUseCase mockAgendaUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;

  setUpAll(() async {
    await getIt.reset(); // ADDED
    mockAgendaUseCase = MockAgendaUseCase();
    getIt.registerSingleton<AgendaUseCase>(mockAgendaUseCase);
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);
    viewModel = AgendaFormViewModelImpl();
    getIt.registerSingleton<AgendaFormViewModel>(viewModel);
    provideDummy<Result<void>>(const Result.ok(null));
    provideDummy<Result<List<Speaker>>>(const Result.ok([]));
    provideDummy<Result<Track>>(
      Result.ok(
        Track(
          uid: '',
          name: '',
          sessionUids: const [],
          eventUid: '',
          color: '',
          resolvedSessions: const [],
        ),
      ),
    );
    provideDummy<Result<List<Track>>>(
      Result.ok([
        Track(
          uid: '',
          name: '',
          sessionUids: const [],
          eventUid: '',
          color: '',
          resolvedSessions: const [],
        ),
      ]),
    );
    provideDummy<Result<AgendaDay>>(
      Result.ok(AgendaDay(uid: '', date: '', eventsUID: const [])),
    );
    provideDummy<Result<List<AgendaDay>>>(
      Result.ok([AgendaDay(uid: '', date: '', eventsUID: const [])]),
    );
    provideDummy<Result<Event>>(
      Result.ok(
        Event(
          uid: '',
          tracks: [],
          eventName: '',
          year: '',
          primaryColor: '',
          secondaryColor: '',
          eventDates: MockEventDates(),
        ),
      ),
    );
  });

  group('AgendaFormViewModelImpl', () {
    const eventId = 'eventId';
    final speaker = Speaker(
      name: 'name',
      uid: '',
      bio: '',
      image: '',
      social: MockSocial(),
      eventUIDS: [],
    );
    final track = Track(
      uid: 'uid',
      name: 'name',
      sessionUids: [],
      eventUid: eventId,
      color: 'color',
      resolvedSessions: [],
    );
    final agendaDay = AgendaDay(uid: 'uid', date: 'date', eventsUID: []);
    final event = Event(
      uid: 'uid',
      tracks: [],
      eventName: '',
      year: '',
      primaryColor: '',
      secondaryColor: '',
      eventDates: MockEventDates(),
    );

    test('checkToken returns true when token is saved', () async {
      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);
      final result = await viewModel.checkToken();
      expect(result, isTrue);
    });

    test('checkToken returns false when token is not saved', () async {
      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => false);
      final result = await viewModel.checkToken();
      expect(result, isFalse);
    });

    group('addSession', () {
      final session = Session(
        uid: 'uid',
        title: 'title',
        time: 'time',
        eventUID: eventId,
        agendaDayUID: 'agendaDayUID',
        speakerUID: '',
        type: '',
      );
      test('should add session successfully', () async {
        when(
          mockAgendaUseCase.addSession(session, track.uid),
        ).thenAnswer((_) async => const Result.ok(null));
        await viewModel.addSession(session, track.uid);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should set viewState to error when adding session fails', () async {
        when(
          mockAgendaUseCase.addSession(session, track.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        await viewModel.addSession(session, track.uid);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('getSpeakersForEventId', () {
      test('should return speakers successfully', () async {
        final speakers = [speaker];
        when(
          mockAgendaUseCase.getSpeakersForEventId(eventId),
        ).thenAnswer((_) async => Result.ok(speakers));
        final result = await viewModel.getSpeakersForEventId(eventId);
        expect(result, speakers);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return empty list when it fails', () async {
        when(
          mockAgendaUseCase.getSpeakersForEventId(eventId),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.getSpeakersForEventId(eventId);
        expect(result, []);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('getTrackById', () {
      test('should return track successfully', () async {
        when(
          mockAgendaUseCase.getTrackById(track.uid),
        ).thenAnswer((_) async => Result.ok(track));
        final result = await viewModel.getTrackById(track.uid);
        expect(result, track);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return null when it fails', () async {
        when(
          mockAgendaUseCase.getTrackById(track.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.getTrackById(track.uid);
        expect(result, isNull);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('getAgendaDayById', () {
      test('should return agenda day successfully', () async {
        when(
          mockAgendaUseCase.getAgendaDayById(agendaDay.uid),
        ).thenAnswer((_) async => Result.ok(agendaDay));
        final result = await viewModel.getAgendaDayById(agendaDay.uid);
        expect(result, agendaDay);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return null when it fails', () async {
        when(
          mockAgendaUseCase.getAgendaDayById(agendaDay.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.getAgendaDayById(agendaDay.uid);
        expect(result, isNull);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('loadEvent', () {
      test('should return event successfully', () async {
        when(
          mockAgendaUseCase.loadEvent(event.uid),
        ).thenAnswer((_) async => Result.ok(event));
        final result = await viewModel.loadEvent(event.uid);
        expect(result, event);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return null when it fails', () async {
        when(
          mockAgendaUseCase.loadEvent(event.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.loadEvent(event.uid);
        expect(result, isNull);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('getAgendaDayByEventId', () {
      test('should return agenda days successfully', () async {
        final agendaDays = [agendaDay];
        when(
          mockAgendaUseCase.getAgendaDayByEventId(eventId),
        ).thenAnswer((_) async => Result.ok(agendaDays));
        final result = await viewModel.getAgendaDayByEventId(eventId);
        expect(result, agendaDays);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return null when it fails', () async {
        when(
          mockAgendaUseCase.getAgendaDayByEventId(eventId),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.getAgendaDayByEventId(eventId);
        expect(result, isNull);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('getTracksByEventId', () {
      test('should return tracks successfully', () async {
        final tracks = [track];
        when(
          mockAgendaUseCase.getTracksByEventId(eventId),
        ).thenAnswer((_) async => Result.ok(tracks));
        final result = await viewModel.getTracksByEventId(eventId);
        expect(result, tracks);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return null when it fails', () async {
        when(
          mockAgendaUseCase.getTracksByEventId(eventId),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.getTracksByEventId(eventId);
        expect(result, isNull);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('getEventById', () {
      test('should return event successfully', () async {
        when(
          mockAgendaUseCase.loadEvent(event.uid),
        ).thenAnswer((_) async => Result.ok(event));
        final result = await viewModel.getEventById(event.uid);
        expect(result, event);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return null when it fails', () async {
        when(
          mockAgendaUseCase.loadEvent(event.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.getEventById(event.uid);
        expect(result, isNull);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('addSpeaker', () {
      test('should add speaker successfully', () async {
        when(
          mockAgendaUseCase.addSpeaker(eventId, speaker),
        ).thenAnswer((_) async => const Result.ok(null));
        await viewModel.addSpeaker(eventId, speaker);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should set viewState to error when adding speaker fails', () async {
        when(
          mockAgendaUseCase.addSpeaker(eventId, speaker),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        await viewModel.addSpeaker(eventId, speaker);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('updateEvent', () {
      test('should update event successfully', () async {
        when(
          mockAgendaUseCase.saveEvent(event),
        ).thenAnswer((_) async => const Result.ok(null));
        await viewModel.updateEvent(event);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should set viewState to error when updating event fails', () async {
        when(
          mockAgendaUseCase.saveEvent(event),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        await viewModel.updateEvent(event);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('updateTrack', () {
      test('should update track successfully', () async {
        when(
          mockAgendaUseCase.updateTrack(track, agendaDay.uid),
        ).thenAnswer((_) async => const Result.ok(null));
        await viewModel.updateTrack(track, agendaDay.uid);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should set viewState to error when updating track fails', () async {
        when(
          mockAgendaUseCase.updateTrack(track, agendaDay.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        await viewModel.updateTrack(track, agendaDay.uid);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('updateAgendaDay', () {
      test('should update agenda day successfully', () async {
        when(
          mockAgendaUseCase.updateAgendaDay(agendaDay, eventId),
        ).thenAnswer((_) async => const Result.ok(null));
        await viewModel.updateAgendaDay(agendaDay, eventId);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test(
        'should set viewState to error when updating agenda day fails',
        () async {
          when(
            mockAgendaUseCase.updateAgendaDay(agendaDay, eventId),
          ).thenAnswer((_) async => const Result.error(NetworkException('')));
          await viewModel.updateAgendaDay(agendaDay, eventId);
          expect(viewModel.viewState.value, ViewState.error);
        },
      );
    });

    group('addTrack', () {
      test('should add track successfully', () async {
        when(
          mockAgendaUseCase.updateTrack(track, agendaDay.uid),
        ).thenAnswer((_) async => const Result.ok(null));
        final result = await viewModel.addTrack(track, agendaDay.uid);
        expect(result, isTrue);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should return false when it fails', () async {
        when(
          mockAgendaUseCase.updateTrack(track, agendaDay.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        final result = await viewModel.addTrack(track, agendaDay.uid);
        expect(result, isFalse);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('removeTrack', () {
      test('should remove track successfully', () async {
        when(
          mockAgendaUseCase.removeTrack(track.uid),
        ).thenAnswer((_) async => const Result.ok(null));
        await viewModel.removeTrack(track.uid);
        expect(viewModel.viewState.value, ViewState.loadFinished);
      });

      test('should set viewState to error when removing track fails', () async {
        when(
          mockAgendaUseCase.removeTrack(track.uid),
        ).thenAnswer((_) async => const Result.error(NetworkException('')));
        await viewModel.removeTrack(track.uid);
        expect(viewModel.viewState.value, ViewState.error);
      });
    });

    group('saveSession', () {
      final session = Session(
        uid: 'uid',
        title: 'title',
        time: 'time',
        eventUID: eventId,
        agendaDayUID: 'agendaDayUID',
        speakerUID: '',
        type: '',
      );

      testWidgets('should save session and return agenda days', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              when(
                mockAgendaUseCase.addSession(any, any),
              ).thenAnswer((_) async => const Result.ok(null));
              tester.runAsync(() async {
                final result = await viewModel.saveSession(
                  context,
                  session.uid,
                  session.title,
                  const TimeOfDay(hour: 10, minute: 0),
                  const TimeOfDay(hour: 11, minute: 0),
                  speaker,
                  'description',
                  'talk',
                  eventId,
                  agendaDay.uid,
                  [track],
                  track.uid,
                  null,
                  [agendaDay],
                );
                expect(result, [agendaDay]);
                expect(viewModel.viewState.value, ViewState.loadFinished);
              });
              return Container();
            },
          ),
        ));
      });
    });

    test('setup does nothing', () async {
      await viewModel.setup();
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
