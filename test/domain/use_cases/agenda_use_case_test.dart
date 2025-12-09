import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';

import '../../helpers/test_helpers.dart';
import '../../mocks.mocks.dart';

@GenerateMocks([SecRepository])
void main() {
  late AgendaUseCaseImpl useCase;
  late MockSecRepository mockSecRepository;

  setUpAll(() async{
    mockSecRepository = MockSecRepository();
    getIt.registerSingleton<SecRepository>(mockSecRepository);
    useCase = AgendaUseCaseImpl();
    useCase.repository = mockSecRepository;
    provideDummy<Result<void>>(Result.ok(null));
    provideDummy<Result<AgendaDay>>(
      Result.ok(AgendaDay(uid: '', date: '', eventsUID: const [])),
    );
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
    provideDummy<Result<List<Speaker>>>(const Result.ok([]));
    provideDummy<Result<List<AgendaDay>>>(
      Result.ok([]),
    );
    provideDummy<Result<List<Track>>>(
      Result.ok([]),
    );
  });

  group('AgendaUseCase', () {
    final speaker = Speaker(
      uid: '1',
      name: 'Test Speaker',
      bio: 'Test Bio',
      eventUIDS: ['event1'],
      image: '',
      social: MockSocial(),
    );
    final session = Session(
      uid: '1',
      title: 'Test Session',
      description: 'Test Description',
      time: '',
      speakerUID: '1',
      eventUID: '',
      agendaDayUID: '',
      type: '',
    );
    final track = Track(
      uid: '1',
      name: 'Test Track',
      color: '',
      sessionUids: [session.uid],
      eventUid: '',
    );
    final agendaDay = AgendaDay(uid: '1', date: '2024-01-01', eventsUID: []);
    final event = Event(
      uid: '1',
      eventName: 'Test Event',
      eventDates: EventDates(
        startDate: '2024-01-01',
        endDate: '2024-01-01',
        timezone: 'gmt',
        uid: 'test_event_date_1',
      ),
      primaryColor: 'ff0000',
      secondaryColor: '00ff00',
      isVisible: true,
      tracks: [track],
      year: '',
    );

    test('saveSpeaker calls repository', () async {
      when(
        mockSecRepository.saveSpeaker(speaker, 'event1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.saveSpeaker(speaker, 'event1');
      verify(mockSecRepository.saveSpeaker(speaker, 'event1'));
    });

    test('addSession calls repository', () async {
      when(
        mockSecRepository.addSession(session, 'track1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.addSession(session, 'track1');
      verify(mockSecRepository.addSession(session, 'track1'));
    });

    test('deleteSession calls repository', () async {
      when(
        mockSecRepository.deleteSession('session1', agendaDayUID: 'agendaDay1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.deleteSession('session1', agendaDayUID: 'agendaDay1');
      verify(
        mockSecRepository.deleteSession('session1', agendaDayUID: 'agendaDay1'),
      );
    });

    test('getAgendaDayById calls repository', () async {
      when(
        mockSecRepository.loadAgendaDayById('agendaDay1'),
      ).thenAnswer((_) async => Result.ok(agendaDay));
      await useCase.getAgendaDayById('agendaDay1');
      verify(mockSecRepository.loadAgendaDayById('agendaDay1'));
    });

    test('getTrackById calls repository', () async {
      when(
        mockSecRepository.loadTrackById('track1'),
      ).thenAnswer((_) async => Result.ok(track));
      await useCase.getTrackById('track1');
      verify(mockSecRepository.loadTrackById('track1'));
    });

    test('loadEvent calls repository', () async {
      when(
        mockSecRepository.loadEventById('event1'),
      ).thenAnswer((_) async => Result.ok(event));
      await useCase.loadEvent('event1');
      verify(mockSecRepository.loadEventById('event1'));
    });

    test('getAgendaDayByEventId calls repository', () async {
      when(
        mockSecRepository.loadAgendaDayByEventId('event1'),
      ).thenAnswer((_) async => Result.ok([agendaDay]));
      await useCase.getAgendaDayByEventId('event1');
      verify(mockSecRepository.loadAgendaDayByEventId('event1'));
    });

    test('getAgendaDayByEventIdFiltered calls repository', () async {
      when(
        mockSecRepository.loadAgendaDayByEventIdFiltered('event1'),
      ).thenAnswer((_) async => Result.ok([agendaDay]));
      await useCase.getAgendaDayByEventIdFiltered('event1');
      verify(mockSecRepository.loadAgendaDayByEventIdFiltered('event1'));
    });

    test('getTracks calls repository', () async {
      when(
        mockSecRepository.loadTracks(),
      ).thenAnswer((_) async => Result.ok([track]));
      await useCase.getTracks();
      verify(mockSecRepository.loadTracks());
    });

    test('getTracksByEventId calls repository', () async {
      when(
        mockSecRepository.loadTracksByEventId('event1'),
      ).thenAnswer((_) async => Result.ok([track]));
      await useCase.getTracksByEventId('event1');
      verify(mockSecRepository.loadTracksByEventId('event1'));
    });

    test('getSpeakersForEventId calls repository', () async {
      when(
        mockSecRepository.getSpeakersForEventId('event1'),
      ).thenAnswer((_) async => Result.ok([speaker]));
      await useCase.getSpeakersForEventId('event1');
      verify(mockSecRepository.getSpeakersForEventId('event1'));
    });

    test('addSpeaker calls repository', () async {
      when(
        mockSecRepository.addSpeaker('event1', speaker),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.addSpeaker('event1', speaker);
      verify(mockSecRepository.addSpeaker('event1', speaker));
    });

    test('saveEvent calls repository', () async {
      when(
        mockSecRepository.saveEvent(event),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.saveEvent(event);
      verify(mockSecRepository.saveEvent(event));
    });

    test('updateTrack calls repository', () async {
      when(
        mockSecRepository.saveTrack(track, 'agendaDay1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.updateTrack(track, 'agendaDay1');
      verify(mockSecRepository.saveTrack(track, 'agendaDay1'));
    });

    test('updateAgendaDay calls repository', () async {
      when(
        mockSecRepository.saveAgendaDay(agendaDay, 'event1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.updateAgendaDay(agendaDay, 'event1');
      verify(mockSecRepository.saveAgendaDay(agendaDay, 'event1'));
    });

    test('removeTrack calls repository', () async {
      when(
        mockSecRepository.removeTrack('track1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.removeTrack('track1');
      verify(mockSecRepository.removeTrack('track1'));
    });
  });
}
