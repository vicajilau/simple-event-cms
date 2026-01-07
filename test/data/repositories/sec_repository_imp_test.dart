import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';
import 'package:sec/data/repositories/sec_repository_imp.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

import '../../mocks.mocks.dart';

void main() {
  late SecRepository secRepository;
  late MockDataLoaderManager mockDataLoaderManager;
  late MockDataUpdateManager mockDataUpdateManager;
  late DataUpdate dataUpdate;
  late MockCommonsServices mockCommonsServices;

  setUp(() async {
    getIt.reset();
    mockCommonsServices = MockCommonsServices();
    mockDataLoaderManager = MockDataLoaderManager();
    mockDataUpdateManager = MockDataUpdateManager();
    when(
      mockDataLoaderManager.loadSponsors(),
    ).thenAnswer((_) => Future.value([]));
    when(
      mockDataLoaderManager.loadSpeakers(),
    ).thenAnswer((_) => Future.value([]));
    when(
      mockDataLoaderManager.loadAllSessions(),
    ).thenAnswer((_) => Future.value([]));
    when(
      mockDataLoaderManager.loadAllTracks(),
    ).thenAnswer((_) => Future.value([]));
    when(mockDataLoaderManager.loadAllEventData()).thenAnswer((_) async => {});
    when(
      mockDataLoaderManager.loadAllDays(),
    ).thenAnswer((_) => Future.value([]));
    when(
      mockDataLoaderManager.loadEvents(),
    ).thenAnswer((_) => Future.value([]));
    when(
      mockCommonsServices.updateAllData(any, any, any),
    ).thenAnswer((_) async => Response('{}', 200));

    when(
      mockDataUpdateManager.updateAgendaDay(any),
    ).thenAnswer((_) async => {});
    when(
      mockDataUpdateManager.updateAgendaDays(any),
    ).thenAnswer((_) async => {});

    when(mockDataUpdateManager.updateEvents(any)).thenAnswer((_) async => {});
    when(
      mockDataUpdateManager.updateOrganization(any),
    ).thenAnswer((_) => Future.value());
    when(
      mockDataUpdateManager.updateSession(any, any),
    ).thenAnswer((_) async => {});
    when(mockDataUpdateManager.updateSpeaker(any)).thenAnswer((_) async => {});
    when(mockDataUpdateManager.updateSpeakers(any)).thenAnswer((_) async => {});
    when(mockDataUpdateManager.updateSponsors(any)).thenAnswer((_) async => {});
    when(
      mockDataUpdateManager.updateSponsorsList(any),
    ).thenAnswer((_) async => {});
    when(mockDataUpdateManager.updateSessions(any)).thenAnswer((_) async => {});
    when(mockDataUpdateManager.updateTrack(any)).thenAnswer((_) async => {});
    when(mockDataUpdateManager.updateTracks(any)).thenAnswer((_) async => {});

    when(
      mockCommonsServices.updateData(any, any, any, any),
    ).thenAnswer((_) async => Response("{}", 200));
    when(
      mockCommonsServices.updateAllData(any, any, any),
    ).thenAnswer((_) async => Response("{}", 200));
    when(
      mockCommonsServices.updateDataList(any, any, any),
    ).thenAnswer((_) async => Response("{}", 200));
    when(
      mockCommonsServices.updateSingleData(any, any, any),
    ).thenAnswer((_) async => Response("{}", 200));

    getIt.registerSingleton<Config>(
      Config(
        configName: 'test_name',
        primaryColorOrganization: '#0000000',
        secondaryColorOrganization: '#0000000',
        githubUser: 'test_user',
        projectName: 'test_project',
        branch: 'test_branch',
      ),
    );
    getIt.registerSingleton<CommonsServices>(mockCommonsServices);
    getIt.registerSingleton<DataLoaderManager>(mockDataLoaderManager);
    getIt.registerSingleton<DataUpdateManager>(mockDataUpdateManager);
    dataUpdate = DataUpdate();
    getIt.registerSingleton<DataUpdate>(dataUpdate);

    secRepository = SecRepositoryImp();
  });

  group('SecRepositoryImp', () {
    group('loadEvents', () {
      test(
        'should return a list of events when data loader is successful',
        () async {
          // Arrange
          when(mockDataLoaderManager.loadEvents()).thenAnswer((_) async => []);

          // Act
          final result = await secRepository.loadEvents();

          // Assert
          expect(result, isA<Ok<List<Event>>>());
          expect((result as Ok<List<Event>>).value, []);
        },
      );

      test(
        'should return a network exception when data loader throws CertainException',
        () async {
          // Arrange
          when(
            mockDataLoaderManager.loadEvents(),
          ).thenThrow(const CertainException('error'));

          // Act
          final result = await secRepository.loadEvents();

          // Assert
          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );

      test(
        'should return an exception when data loader throws Error',
        () async {
          // Arrange
          when(
            mockDataLoaderManager.loadEvents(),
          ).thenThrow(AssertionError('error'));

          // Act
          final result = await secRepository.loadEvents();

          // Assert
          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );

      test('should return a network exception for other exceptions', () async {
        // Arrange
        when(mockDataLoaderManager.loadEvents()).thenThrow(Exception('error'));

        // Act
        final result = await secRepository.loadEvents();

        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadESpeakers', () {
      test(
        'should return a list of speakers when data loader is successful',
        () async {
          // Arrange
          List<Speaker> speakers = [];
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => speakers);

          // Act
          final result = await secRepository.loadESpeakers();

          // Assert
          expect(result, isA<Ok<List<Speaker>>>());
          expect((result as Ok<List<Speaker>>).value, speakers);
        },
      );

      test(
        'should return an empty list when data loader returns null',
        () async {
          // Arrange
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => null);

          // Act
          final result = await secRepository.loadESpeakers();

          // Assert
          expect(result, isA<Ok<List<Speaker>>>());
          expect((result as Ok<List<Speaker>>).value, []);
        },
      );

      test(
        'should return a network exception when data loader throws CertainException',
        () async {
          // Arrange
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenThrow(const CertainException('error'));

          // Act
          final result = await secRepository.loadESpeakers();

          // Assert
          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );

      test('should return a network exception for other exceptions', () async {
        // Arrange
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenThrow(Exception('error'));

        // Act
        final result = await secRepository.loadESpeakers();

        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return an error', () async {
        // Arrange
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenThrow(AssertionError('error'));

        // Act
        final result = await secRepository.loadESpeakers();

        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadSponsors', () {
      test(
        'should return a list of sponsors when data loader is successful',
        () async {
          // Arrange
          when(
            mockDataLoaderManager.loadSponsors(),
          ).thenAnswer((_) async => []);

          // Act
          final result = await secRepository.loadSponsors();

          // Assert
          expect(result, isA<Ok<List<Sponsor>>>());
          expect((result as Ok<List<Sponsor>>).value, []);
        },
      );

      test(
        'should return a network exception when data loader throws CertainException',
        () async {
          // Arrange
          when(
            mockDataLoaderManager.loadSponsors(),
          ).thenThrow(const CertainException('error'));

          // Act
          final result = await secRepository.loadSponsors();

          // Assert
          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return a network exception for other exceptions', () async {
        // Arrange
        when(
          mockDataLoaderManager.loadSponsors(),
        ).thenThrow(Exception('error'));

        // Act
        final result = await secRepository.loadSponsors();

        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return an error', () async {
        // Arrange
        when(
          mockDataLoaderManager.loadSponsors(),
        ).thenThrow(AssertionError('error'));

        // Act
        final result = await secRepository.loadSponsors();

        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('saveTracks', () {
      final tracks = [
        Track(
          uid: 't1',
          name: 'Track 1',
          eventUid: 'event1',
          color: '',
          sessionUids: [],
        ),
      ];
      final existingTrack = Track(
        uid: 't2',
        name: 'track 1',
        eventUid: 'event1',
        color: '',
        sessionUids: [],
      );
      final anotherTrack = Track(
        uid: 't3',
        name: 'track 3',
        eventUid: 'event1',
        color: '',
        sessionUids: [],
      );

      test('should return Error if track with same name exists', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [existingTrack]);

        final result = await secRepository.saveTracks(tracks);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect(
          (result.error as NetworkException).message,
          'A track with the name "Track 1" already exists.',
        );
      });

      test(
        'should return CertainException when you try to save tracks',
        () async {
          when(
            dataUpdate.addItemListAndAssociations(tracks),
          ).thenThrow(CertainException('error trying to save'));

          final result = await secRepository.saveTracks(tracks);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
          expect(
            (result.error as NetworkException).message,
            'error trying to save',
          );
        },
      );

      test('should return Error when you try to save tracks', () async {
        when(
          dataUpdate.addItemListAndAssociations(tracks),
        ).thenThrow(ArgumentError('error trying to save'));

        final result = await secRepository.saveTracks(tracks);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect(
          (result.error as NetworkException).message,
          'Error in saveTracks, please try again',
        );
      });

      test('save tracks successfully', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [anotherTrack]);
        when(
          mockDataUpdateManager.updateTracks(any),
        ).thenAnswer((_) async => []);

        final result = await secRepository.saveTracks(tracks);

        expect(result, isA<Ok<void>>());
      });

      test('should return Exception when you try to save tracks', () async {
        when(
          dataUpdate.addItemListAndAssociations(tracks),
        ).thenThrow(Exception('error trying to save'));

        final result = await secRepository.saveTracks(tracks);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect(
          (result.error as NetworkException).message,
          'Error in saveTracks, please try again',
        );
      });
    });
    group('saveEvent', () {
      final event = Event(
        uid: 'event1',
        tracks: [],
        eventName: '',
        year: '',
        primaryColor: '',
        secondaryColor: '',
        eventDates: MockEventDates(),
      );
      test('should return Ok when saving is successful', () async {
        when(mockDataLoaderManager.loadEvents()).thenAnswer((_) async => []);
        when(mockDataUpdateManager.updateEvent(event)).thenAnswer((_) async {});
        final result = await secRepository.saveEvent(event);

        expect(result, isA<Ok<void>>());
      });
      test('should return CertainException when saving has an error', () async {
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenAnswer((_) async => [event]);
        when(
          mockDataUpdateManager.updateEvent(event),
        ).thenThrow(CertainException('error'));
        final result = await secRepository.saveEvent(event);

        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return CertainException when saving has an error', () async {
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenAnswer((_) async => [event]);
        when(
          mockDataUpdateManager.updateEvent(event),
        ).thenThrow(Exception('error'));
        final result = await secRepository.saveEvent(event);

        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Error when saving has an error', () async {
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenAnswer((_) async => [event]);
        when(
          mockDataUpdateManager.updateEvent(event),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.saveEvent(event);

        expect((result as Error).error, isA<NetworkException>());
      });
    });
    group('removeEvent', () {
      final event1 = Event(
        uid: 'event1',
        tracks: [],
        eventName: '',
        year: '',
        primaryColor: '',
        secondaryColor: '',
        eventDates: MockEventDates(),
      );
      final event2 = Event(
        uid: 'event2',
        tracks: [],
        eventName: '',
        year: '',
        primaryColor: '',
        secondaryColor: '',
        eventDates: MockEventDates(),
      );

      test('should return Ok when removing is successful', () async {
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenAnswer((_) async => [event1, event2]);
        when(
          mockDataUpdateManager.removeEvent('event1'),
        ).thenAnswer((_) async {});

        final result = await secRepository.removeEvent('event1');

        expect(result, isA<Ok<void>>());
      });
      test('should return Exception when removing is successful', () async {
        when(
          dataUpdate.deleteItemAndAssociations('event1', "Event"),
        ).thenThrow(Exception('error'));

        final result = await secRepository.removeEvent('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Error when removing is not successful', () async {
        when(
          dataUpdate.deleteItemAndAssociations('event1', "Event"),
        ).thenThrow(ArgumentError('error'));

        final result = await secRepository.removeEvent('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test(
        'should return CertainException when removing is not successful',
        () async {
          when(
            dataUpdate.deleteItemAndAssociations('event1', "Event"),
          ).thenThrow(CertainException('error'));

          final result = await secRepository.removeEvent('event1');

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
    });
    group('RemoveAgendaDay', () {
      final agendaDay1 = AgendaDay(
        uid: 'day1',
        date: '',
        eventsUID: ['event1'],
      );
      final agendaDay2 = AgendaDay(
        uid: 'day2',
        date: '',
        eventsUID: ['event1'],
      );

      test('should return Ok when removing is successful', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay1, agendaDay2]);
        when(
          mockDataUpdateManager.removeAgendaDay('day1'),
        ).thenAnswer((_) async {});
        final result = await secRepository.removeAgendaDay('day1', 'event1');

        expect(result, isA<Ok<void>>());
      });
      test('should return Error when removing is not successful', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay1, agendaDay2]);
        when(
          mockDataUpdateManager.removeAgendaDay('day1'),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.removeAgendaDay('day1', 'event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Exception when removing is not successful', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay1, agendaDay2]);
        when(
          mockDataUpdateManager.removeAgendaDay('day1'),
        ).thenThrow(Exception('error'));

        final result = await secRepository.removeAgendaDay('day1', 'event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test(
        'should return CertainException when removing is not successful',
        () async {
          when(
            mockDataLoaderManager.loadAllDays(),
          ).thenAnswer((_) async => [agendaDay1, agendaDay2]);
          when(
            mockDataUpdateManager.removeAgendaDay('day1'),
          ).thenThrow(CertainException('error'));

          final result = await secRepository.removeAgendaDay('day1', 'event1');

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
    });
    group('saveTrack', () {
      final track = Track(
        uid: 'track1',
        name: 'New Track',
        eventUid: 'event1',
        color: '',
        sessionUids: [],
      );
      const agendaDayId = 'day1';

      test('should return Error if track with same name exists', () async {
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 't2',
              name: 'new track',
              eventUid: 'event1',
              color: '',
              sessionUids: [],
            ),
          ],
        );

        final result = await secRepository.saveTrack(track, agendaDayId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect(
          (result.error as NetworkException).message,
          'A track with the name "New Track" already exists.',
        );
      });
      test('return Certain exception when you try to save track', () async {
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 't2',
              name: 'new track2',
              eventUid: 'event1',
              color: '',
              sessionUids: [],
            ),
          ],
        );

        when(
          dataUpdate.addItemAndAssociations(track, 'event1'),
        ).thenThrow(CertainException('error trying to save'));

        final result = await secRepository.saveTrack(track, agendaDayId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect(
          (result.error as NetworkException).message,
          'error trying to save',
        );
      });
      test('return Exception when you try to save track', () async {
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 't2',
              name: 'new track2',
              eventUid: 'event1',
              color: '',
              sessionUids: [],
            ),
          ],
        );

        when(
          dataUpdate.addItemAndAssociations(track, 'event1'),
        ).thenThrow(Exception('error trying to save'));

        final result = await secRepository.saveTrack(track, agendaDayId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect(
          (result.error as NetworkException).message,
          'An unexpected error occurred. Please try again later.',
        );
      });
      test('return Error when you try to save track', () async {
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 't2',
              name: 'new track2',
              eventUid: 'event1',
              color: '',
              sessionUids: [],
            ),
          ],
        );

        when(
          dataUpdate.addItemAndAssociations(track, 'event1'),
        ).thenThrow(ArgumentError('error trying to save'));

        final result = await secRepository.saveTrack(track, agendaDayId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect(
          (result.error as NetworkException).message,
          'An unexpected error occurred. Please try again later.',
        );
      });
    });

    group('loadAgendaDayById', () {
      final agendaDay = AgendaDay(uid: 'day1', date: '', eventsUID: []);

      test('should return AgendaDay when found', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay]);

        final result = await secRepository.loadAgendaDayById('day1');

        expect(result, isA<Ok<AgendaDay>>());
        expect((result as Ok<AgendaDay>).value, agendaDay);
      });

      test('should return Error when not found', () async {
        when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);

        final result = await secRepository.loadAgendaDayById('day1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

      test('should return CertainException when not found', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenThrow(const CertainException('error'));

        final result = await secRepository.loadAgendaDayById('day1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

      test('should return Exception when not found', () async {
        when(mockDataLoaderManager.loadAllDays()).thenThrow(Exception('error'));

        final result = await secRepository.loadAgendaDayById('day1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadTrackById', () {
      final track = Track(
        uid: 'track1',
        name: '',
        color: '',
        sessionUids: [],
        eventUid: '',
      );

      test('should return Track when found', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [track]);

        final result = await secRepository.loadTrackById('track1');

        expect(result, isA<Ok<Track>>());
        expect((result as Ok<Track>).value, track);
      });

      test('should return Error when not found', () async {
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer((_) async => []);

        final result = await secRepository.loadTrackById('track1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return CertainException when not found', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenThrow(const CertainException('error'));

        final result = await secRepository.loadTrackById('track1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Exception when not found', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenThrow(Exception('error'));

        final result = await secRepository.loadTrackById('track1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadAgendaDayByEventId', () {
      final agendaDay = AgendaDay(uid: 'day1', eventsUID: ['event1'], date: '');
      final otherAgendaDay = AgendaDay(
        uid: 'day2',
        eventsUID: ['event2'],
        date: '',
      );

      test('should return list of AgendaDay for a given eventId', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay, otherAgendaDay]);

        final result = await secRepository.loadAgendaDayByEventId('event1');

        expect(result, isA<Ok<List<AgendaDay>>>());
        expect((result as Ok<List<AgendaDay>>).value, [agendaDay]);
      });

      test('should return CertainException when loadAllDays fails', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenThrow(const CertainException('error'));

        final result = await secRepository.loadAgendaDayByEventId('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Exception when loadAllDays fails', () async {
        when(mockDataLoaderManager.loadAllDays()).thenThrow(Exception('error'));

        final result = await secRepository.loadAgendaDayByEventId('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Error when loadAllDays fails', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenThrow(AssertionError('error'));

        final result = await secRepository.loadAgendaDayByEventId('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadAgendaDayByEventIdFiltered', () {
      final session1 = Session(
        uid: 's1',
        agendaDayUID: 'day1',
        title: '',
        time: '',
        speakerUID: '',
        eventUID: '',
        type: '',
      );
      final track1 = Track(
        uid: 't1',
        eventUid: 'event1',
        resolvedSessions: [session1],
        name: '',
        color: '',
        sessionUids: [],
      );
      final agendaDay1 = AgendaDay(
        uid: 'day1',
        eventsUID: ['event1'],
        resolvedTracks: [track1],
        date: '',
      );

      final session2 = Session(
        uid: 's2',
        agendaDayUID: 'day2',
        title: '',
        time: '',
        speakerUID: '',
        eventUID: '',
        type: '',
      );
      final track2 = Track(
        uid: 't2',
        eventUid: 'event2',
        resolvedSessions: [session2],
        name: '',
        color: '',
        sessionUids: [],
      );
      final agendaDay2 = AgendaDay(
        uid: 'day2',
        eventsUID: ['event2'],
        resolvedTracks: [track2],
        date: '',
      );
      test('should return a filtered list of agenda days', () async {
        // Arrange

        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay1, agendaDay2]);
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [track1, track2]);

        // Act
        final result = await secRepository.loadAgendaDayByEventIdFiltered(
          'event1',
        );

        // Assert
        expect(result, isA<Ok<List<AgendaDay>>>());
        final list = (result as Ok<List<AgendaDay>>).value;
        expect(list.length, 1);
        expect(list.first.uid, 'day1');
      });
      test('should return a certainException when loadAllDays fails', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenThrow(const CertainException('error'));
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [track1, track2]);

        // Act
        final result = await secRepository.loadAgendaDayByEventIdFiltered(
          'event1',
        );

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return a Exception when loadAllDays fails', () async {
        when(mockDataLoaderManager.loadAllDays()).thenThrow(Exception('error'));
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [track1, track2]);

        // Act
        final result = await secRepository.loadAgendaDayByEventIdFiltered(
          'event1',
        );

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return an Error when loadAllDays fails', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenThrow(AssertionError('error'));
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [track1, track2]);

        // Act
        final result = await secRepository.loadAgendaDayByEventIdFiltered(
          'event1',
        );

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadTracksByEventId', () {
      final track1 = Track(
        uid: 't1',
        eventUid: 'event1',
        name: '',
        color: '',
        sessionUids: [],
      );
      final track2 = Track(
        uid: 't2',
        eventUid: 'event2',
        name: '',
        color: '',
        sessionUids: [],
      );

      test('should return list of Tracks for a given eventId', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [track1, track2]);

        final result = await secRepository.loadTracksByEventId('event1');

        expect(result, isA<Ok<List<Track>>>());
        expect((result as Ok<List<Track>>).value, [track1]);
      });
      test(
        'should return an CertainException when loadAllTracks fails',
        () async {
          when(
            mockDataLoaderManager.loadAllTracks(),
          ).thenThrow(const CertainException('error'));

          final result = await secRepository.loadTracksByEventId('event1');

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return an Exception when loadAllTracks fails', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenThrow(Exception('error'));

        final result = await secRepository.loadTracksByEventId('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return an Error when loadAllTracks fails', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenThrow(AssertionError('error'));

        final result = await secRepository.loadTracksByEventId('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadTracks', () {
      final tracks = [
        Track(uid: 't1', name: '', color: '', sessionUids: [], eventUid: ''),
        Track(uid: 't2', name: '', color: '', sessionUids: [], eventUid: ''),
      ];

      test('should return all tracks', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => tracks);

        final result = await secRepository.loadTracks();

        expect(result, isA<Ok<List<Track>>>());
        expect((result as Ok<List<Track>>).value, tracks);
      });

      test('should return Exception on exception', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenThrow(Exception('error'));

        final result = await secRepository.loadTracks();

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

      test('should return CertainException on exception', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenThrow(CertainException('error'));

        final result = await secRepository.loadTracks();

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Error on exception', () async {
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenThrow(AssertionError('error'));

        final result = await secRepository.loadTracks();

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('loadEventById', () {
      final event1 = Event(
        uid: 'event1',
        tracks: [],
        eventName: '',
        year: '',
        primaryColor: '',
        secondaryColor: '',
        eventDates: MockEventDates(),
      );
      final event2 = Event(
        uid: 'event2',
        tracks: [],
        eventName: '',
        year: '',
        primaryColor: '',
        secondaryColor: '',
        eventDates: MockEventDates(),
      );

      test('should return Event when found', () async {
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenAnswer((_) async => [event1, event2]);

        final result = await secRepository.loadEventById('event1');

        expect(result, isA<Ok<Event>>());
        expect((result as Ok<Event>).value, event1);
      });

      test('should return CertainException when not found', () async {
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenThrow(CertainException('error'));

        final result = await secRepository.loadEventById('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

      test('should return Exception when not found', () async {
        when(mockDataLoaderManager.loadEvents()).thenThrow(Exception('error'));

        final result = await secRepository.loadEventById('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

      test('should return Error when not found', () async {
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenThrow(AssertionError('error'));

        final result = await secRepository.loadEventById('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('getSpeakersForEventId', () {
      final speaker1 = Speaker(
        uid: 's1',
        eventUIDS: ['event1'],
        name: '',
        bio: '',
        image: '',
        social: MockSocial(),
      );
      final speaker2 = Speaker(
        uid: 's2',
        eventUIDS: ['event2'],
        name: '',
        bio: '',
        image: '',
        social: MockSocial(),
      );

      test('should return list of Speakers for a given eventId', () async {
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenAnswer((_) async => [speaker1, speaker2]);

        final result = await secRepository.getSpeakersForEventId('event1');

        expect(result, isA<Ok<List<Speaker>>>());
        expect((result as Ok<List<Speaker>>).value, [speaker1]);
      });

      test('should return empty list if data loader returns null', () async {
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenAnswer((_) async => null);

        final result = await secRepository.getSpeakersForEventId('event1');

        expect(result, isA<Ok<List<Speaker>>>());
        expect((result as Ok<List<Speaker>>).value, []);
      });

      test(
        'should return empty list if data loader returns empty list',
        () async {
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => []);

          final result = await secRepository.getSpeakersForEventId('event1');

          expect(result, isA<Ok<List<Speaker>>>());
          expect((result as Ok<List<Speaker>>).value, []);
        },
      );
      test(
        'should return CertainException if data loader throws exception',
        () async {
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenThrow(CertainException('error'));

          final result = await secRepository.getSpeakersForEventId('event1');

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return Exception if data loader throws exception', () async {
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenThrow(Exception('error'));

        final result = await secRepository.getSpeakersForEventId('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return Error if data loader throws exception', () async {
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenThrow(AssertionError('error'));

        final result = await secRepository.getSpeakersForEventId('event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('saveConfig', () {
      final config = Config(
        uid: 'config1',
        configName: '',
        primaryColorOrganization: '',
        secondaryColorOrganization: '',
        githubUser: '',
        projectName: '',
        branch: '',
      );

      test('should return Ok when saving is successful', () async {
        final result = await secRepository.saveConfig(config);

        expect(result, isA<Ok<void>>());
      });
    });

    group('saveAgendaDays', () {
      final oldAgendaDays = [AgendaDay(uid: 'dayOld', date: '', eventsUID: [])];
      final agendaDays = [AgendaDay(uid: 'day1', date: '', eventsUID: [])];
      const eventUID = 'event1';

      test('should return Ok when saving is successful', () async {
        when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => oldAgendaDays);

        final result = await secRepository.saveAgendaDays(agendaDays, eventUID);

        expect(result, isA<Ok<void>>());
      });

      test('should return Error on CertainException', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenThrow(const CertainException('error'));

        final result = await secRepository.saveAgendaDays(agendaDays, eventUID);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

      test('should return Error on generic exception', () async {
        when(mockDataLoaderManager.loadAllDays()).thenThrow(Exception('error'));

        final result = await secRepository.saveAgendaDays(agendaDays, eventUID);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

      test('should return Error on generic error', () async {
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenThrow(AssertionError('error'));

        final result = await secRepository.saveAgendaDays(agendaDays, eventUID);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });
    group('saveSpeaker', () {
      final speaker = Speaker(
        uid: 's1',
        eventUIDS: ['event1'],
        name: '',
        bio: '',
        image: '',
        social: MockSocial(),
      );
      const parentId = 'event1';

      test('should return Ok when saving is successful', () async {
        final result = await secRepository.saveSpeaker(speaker, parentId);

        expect(result, isA<Ok<void>>());
      });
      test(
        'should return a certainException when saving is not successful',
        () async {
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => []);
          when(
            dataUpdate.addItemAndAssociations(speaker, parentId),
          ).thenThrow(CertainException('error'));

          final result = await secRepository.saveSpeaker(speaker, parentId);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return a exception when saving is not successful', () async {
        when(mockDataLoaderManager.loadSpeakers()).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(speaker, parentId),
        ).thenThrow(Exception('error'));

        final result = await secRepository.saveSpeaker(speaker, parentId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return an error when saving is not successful', () async {
        when(mockDataLoaderManager.loadSpeakers()).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(speaker, parentId),
        ).thenThrow(AssertionError('error'));

        final result = await secRepository.saveSpeaker(speaker, parentId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('saveSponsor', () {
      final sponsor = Sponsor(
        uid: 'sponsor1',
        name: '',
        logo: '',
        type: '',
        website: '',
        eventUID: '',
      );
      const parentId = 'event1';

      test('should return Ok when saving is successful', () async {
        final result = await secRepository.saveSponsor(sponsor, parentId);

        expect(result, isA<Ok<void>>());
      });
      test(
        'should return a certainException when saving is not successful',
        () async {
          when(
            mockDataLoaderManager.loadSponsors(),
          ).thenAnswer((_) async => []);
          when(
            dataUpdate.addItemAndAssociations(sponsor, parentId),
          ).thenThrow(CertainException('error'));

          final result = await secRepository.saveSponsor(sponsor, parentId);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return a exception when saving is not successful', () async {
        when(mockDataLoaderManager.loadSponsors()).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(sponsor, parentId),
        ).thenThrow(Exception('error'));
        final result = await secRepository.saveSponsor(sponsor, parentId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return an error when saving is not successful', () async {
        when(mockDataLoaderManager.loadSponsors()).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(sponsor, parentId),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.saveSponsor(sponsor, parentId);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('addSession', () {
      final session = Session(
        uid: 's1',
        agendaDayUID: 'day1',
        title: '',
        time: '',
        speakerUID: '',
        eventUID: '',
        type: '',
      );
      const trackUID = 't1';

      test('should return Ok when adding is successful', () async {
        final result = await secRepository.addSession(session, trackUID);

        expect(result, isA<Ok<void>>());
      });
      test(
        'should return a certainException when saving is not successful',
        () async {
          when(
            mockDataLoaderManager.loadAllSessions(),
          ).thenAnswer((_) async => []);
          when(
            dataUpdate.addItemAndAssociations(session, trackUID),
          ).thenThrow(CertainException('error'));
          final result = await secRepository.addSession(session, trackUID);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return a exception when saving is not successful', () async {
        when(
          mockDataLoaderManager.loadAllSessions(),
        ).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(session, trackUID),
        ).thenThrow(Exception('error'));
        final result = await secRepository.addSession(session, trackUID);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test('should return an error when saving is not successful', () async {
        when(
          mockDataLoaderManager.loadAllSessions(),
        ).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(session, trackUID),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.addSession(session, trackUID);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('addSpeaker', () {
      final speaker = Speaker(
        uid: 's1',
        eventUIDS: ['event1'],
        name: '',
        bio: '',
        image: '',
        social: MockSocial(),
      );
      const eventId = 'event1';

      test('should return Ok when adding is successful', () async {
        final result = await secRepository.addSpeaker(eventId, speaker);

        expect(result, isA<Ok<void>>());
      });
      test('should return a exception when saving is not successful', () async {
        when(mockDataLoaderManager.loadSpeakers()).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(speaker, eventId),
        ).thenThrow(Exception('error'));
        final result = await secRepository.addSpeaker(eventId, speaker);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
      test(
        'should return a CertainException when saving is not successful',
        () async {
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => []);
          when(
            dataUpdate.addItemAndAssociations(speaker, eventId),
          ).thenThrow(CertainException('error'));
          final result = await secRepository.addSpeaker(eventId, speaker);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return an error when saving is not successful', () async {
        when(mockDataLoaderManager.loadSpeakers()).thenAnswer((_) async => []);
        when(
          dataUpdate.addItemAndAssociations(speaker, eventId),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.addSpeaker(eventId, speaker);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('removeSpeaker', () {
      final speaker = Speaker(
        uid: 's1',
        eventUIDS: ['event1'],
        name: '',
        bio: '',
        image: '',
        social: MockSocial(),
      );

      test('should return Ok when removing is successful', () async {
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenAnswer((_) async => [speaker]);
        when(
          dataUpdate.deleteItemAndAssociations(
            speaker.uid,
            'Speaker',
            eventUID: 'event1',
          ),
        ).thenAnswer((_) async {});
        final result = await secRepository.removeSpeaker(speaker.uid, 'event1');

        expect(result, isA<Ok<void>>());
      });
      test(
        'should return a exception when removing is not successful',
        () async {
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => [speaker]);
          when(
            dataUpdate.deleteItemAndAssociations(
              speaker.uid,
              'Speaker',
              eventUID: 'event1',
            ),
          ).thenThrow(Exception('error'));
          final result = await secRepository.removeSpeaker(
            speaker.uid,
            'event1',
          );

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test(
        'should return a CertainException when removing is not successful',
        () async {
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => [speaker]);
          when(
            dataUpdate.deleteItemAndAssociations(
              speaker.uid,
              'Speaker',
              eventUID: 'event1',
            ),
          ).thenThrow(CertainException('error'));
          final result = await secRepository.removeSpeaker(
            speaker.uid,
            'event1',
          );

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return an error when removing is not successful', () async {
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenAnswer((_) async => [speaker]);
        when(
          dataUpdate.deleteItemAndAssociations(
            speaker.uid,
            'Speaker',
            eventUID: 'event1',
          ),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.removeSpeaker(speaker.uid, 'event1');

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('removeSponsor', () {
      final sponsor = Sponsor(
        uid: 'sponsor-1',
        name: 'Sponsor 1',
        type: '',
        logo: '',
        website: '',
        eventUID: '',
      );

      test('should return Ok when removing is successful', () async {
        when(
          mockDataLoaderManager.loadSponsors(),
        ).thenAnswer((_) async => [sponsor]);
        when(
          dataUpdate.deleteItemAndAssociations(
            sponsor.uid,
            'Sponsor',
            eventUID: 'event1',
          ),
        ).thenAnswer((_) async {});
        final result = await secRepository.removeSponsor(sponsor.uid);

        expect(result, isA<Ok<void>>());
      });
      test(
        'should return a exception when removing is not successful',
        () async {
          when(
            mockDataLoaderManager.loadSponsors(),
          ).thenAnswer((_) async => [sponsor]);
          when(
            dataUpdate.deleteItemAndAssociations(
              sponsor.uid,
              'Sponsor',
              eventUID: 'event1',
            ),
          ).thenThrow(Exception('error'));
          final result = await secRepository.removeSponsor(sponsor.uid);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test(
        'should return a CertainException when removing is not successful',
        () async {
          when(
            mockDataLoaderManager.loadSponsors(),
          ).thenAnswer((_) async => [sponsor]);
          when(
            dataUpdate.deleteItemAndAssociations(
              sponsor.uid,
              'Sponsor',
              eventUID: 'event1',
            ),
          ).thenThrow(CertainException('error'));
          final result = await secRepository.removeSponsor(sponsor.uid);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return an error when removing is not successful', () async {
        when(
          mockDataLoaderManager.loadSponsors(),
        ).thenAnswer((_) async => [sponsor]);
        when(
          dataUpdate.deleteItemAndAssociations(
            sponsor.uid,
            'Sponsor',
            eventUID: 'event1',
          ),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.removeSponsor(sponsor.uid);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('removeSession', () {
      final session = Session(
        uid: 's1',
        agendaDayUID: 'day1',
        title: '',
        time: '',
        speakerUID: '',
        eventUID: '',
        type: '',
      );

      test(
        'should return a exception when removing is not successful',
        () async {
          when(
            mockDataLoaderManager.loadAllSessions(),
          ).thenAnswer((_) async => [session]);
          when(
            dataUpdate.deleteItemAndAssociations(
              session.uid,
              'Session',
              agendaDayUidSelected: 'day1',
            ),
          ).thenThrow(Exception('error'));
          final result = await secRepository.deleteSession(session.uid);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test(
        'should return a CertainException when removing is not successful',
        () async {
          when(
            mockDataLoaderManager.loadAllSessions(),
          ).thenAnswer((_) async => [session]);
          when(
            dataUpdate.deleteItemAndAssociations(
              session.uid,
              'Session',
              agendaDayUidSelected: 'day1',
            ),
          ).thenThrow(CertainException('error'));
          final result = await secRepository.deleteSession(session.uid);

          expect(result, isA<Error>());
          expect((result as Error).error, isA<NetworkException>());
        },
      );
      test('should return an error when removing is not successful', () async {
        when(
          mockDataLoaderManager.loadAllSessions(),
        ).thenAnswer((_) async => [session]);
        when(
          dataUpdate.deleteItemAndAssociations(
            session.uid,
            'Session',
            agendaDayUidSelected: 'day1',
          ),
        ).thenThrow(AssertionError('error'));
        final result = await secRepository.deleteSession(session.uid);

        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    group('saveAgendaDay', () {
      final agendaDay = AgendaDay(uid: 'day1', date: '', eventsUID: []);
      const eventUID = 'event1';

      test(
        'should return Result.ok when dataUpdate.addItemAndAssociations completes successfully',
        () async {
          final result = await secRepository.saveAgendaDay(agendaDay, eventUID);

          expect(result, isA<Ok>());
          verify(
            dataUpdate.addItemAndAssociations(agendaDay, eventUID),
          ).called(1);
        },
      );

      test(
        'should return Result.error with NetworkException when dataUpdate throws CertainException',
        () async {
          final exception = CertainException('Database connection failed');
          when(
            dataUpdate.addItemAndAssociations(agendaDay, eventUID),
          ).thenThrow(exception);

          final result = await secRepository.saveAgendaDay(agendaDay, eventUID);

          expect(result, isA<Error>());
          verify(
            dataUpdate.addItemAndAssociations(agendaDay, eventUID),
          ).called(1);
        },
      );

      test(
        'should return Result.error with generic NetworkException when dataUpdate throws generic Exception',
        () async {
          when(
            dataUpdate.addItemAndAssociations(agendaDay, eventUID),
          ).thenThrow(Exception('A generic error'));

          final result = await secRepository.saveAgendaDay(agendaDay, eventUID);

          expect(result, isA<Error>());
          verify(
            dataUpdate.addItemAndAssociations(agendaDay, eventUID),
          ).called(1);
        },
      );

      test(
        'should return Result.error with generic NetworkException when dataUpdate throws other object',
        () async {
          when(
            dataUpdate.addItemAndAssociations(agendaDay, eventUID),
          ).thenThrow('A string error');

          final result = await secRepository.saveAgendaDay(agendaDay, eventUID);

          expect(result, isA<Error>());
          verify(
            dataUpdate.addItemAndAssociations(agendaDay, eventUID),
          ).called(1);
        },
      );
    });
  });
}
