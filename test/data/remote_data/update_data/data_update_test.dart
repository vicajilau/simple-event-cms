import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github_json_model.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';

import '../../../mocks.mocks.dart';

void main() {
  late DataUpdateManager mockDataUpdateManager;
  late MockCommonsServices mockCommonsServices;
  late MockDataLoaderManager mockDataLoaderManager;

  setUpAll(() async {
    final session1 = Session(
      uid: 'session-1',
      title: 'Old Title',
      eventUID: 'event-1',
      agendaDayUID: 'day-1',
      time: '',
      speakerUID: '',
      type: '',
    );
    final track1 = Track(
      uid: 'track-1',
      name: 'Track 1',
      eventUid: 'event-1',
      sessionUids: ['session-1'],
      color: '', // session-1 está aquí inicialmente
    );
    final track2 = Track(
      uid: 'track-2',
      name: 'Track 2',
      eventUid: 'event-1',
      sessionUids: [],
      color: '', // track-2 está vacío
    );
    final day1 = AgendaDay(
      uid: 'day-1',
      eventsUID: ['event-1'],
      trackUids: ['track-1'],
      date: '',
    );
    final day2 = AgendaDay(
      uid: 'day-2',
      eventsUID: ['event-1'],
      trackUids: [],
      date: '',
    );
    final event1 = Event(
      uid: 'event-1',
      location: '',
      description: '',
      tracks: [track1],
      eventName: '',
      year: '',
      primaryColor: '',
      secondaryColor: '',
      eventDates: MockEventDates(),
    );
    getIt.reset();
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
    mockCommonsServices = MockCommonsServices();
    getIt.registerSingleton<CommonsServices>(mockCommonsServices);
    mockDataLoaderManager = MockDataLoaderManager();
    getIt.registerSingleton<DataLoaderManager>(mockDataLoaderManager);
    mockDataUpdateManager = DataUpdateManager();
    getIt.registerSingleton<DataUpdateManager>(mockDataUpdateManager);
    when(mockDataLoaderManager.loadEvents()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadSponsors()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadAllTracks()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadAllSessions()).thenAnswer((_) async => []);
    when(
      mockCommonsServices.updateAllData(any, any, any),
    ).thenAnswer((_) async => Response("{}", 200));
    when(
      mockCommonsServices.loadData(any),
    ).thenAnswer((_) async => <String, dynamic>{});
    when(
      mockDataLoaderManager.loadAllSessions(),
    ).thenAnswer((_) async => [session1]);
    when(
      mockDataLoaderManager.loadAllTracks(),
    ).thenAnswer((_) async => [track1, track2]);
    when(mockDataLoaderManager.loadEvents()).thenAnswer((_) async => [event1]);
    when(
      mockDataLoaderManager.loadAllDays(),
    ).thenAnswer((_) async => [day1, day2]);
  });

  group('DataUpdateManager', () {
    final testEvent = Event(
      uid: '1',
      tracks: [],
      eventName: '',
      year: '',
      primaryColor: '',
      secondaryColor: '',
      eventDates: MockEventDates(),
    );
    final testSpeaker = Speaker(
      uid: '1',
      name: '',
      bio: '',
      image: '',
      social: MockSocial(),
      eventUIDS: [],
    );

    final agendaDay = AgendaDay(
      uid: '1',
      date: DateTime.now().toIso8601String(),
      trackUids: [],
      eventsUID: [],
    );

    final testTrack = Track(
      uid: '1',
      name: '',
      color: '',
      sessionUids: [],
      eventUid: '',
    );

    final testSponsor = Sponsor(
      uid: '1',
      name: '',
      type: '',
      logo: '',
      website: '',
      eventUID: '',
    );

    test('updateSpeaker adds a new speaker if not present', () async {
      // Arrange
      when(mockDataLoaderManager.loadSpeakers()).thenAnswer((_) async => []);

      // Act
      await mockDataUpdateManager.updateSpeaker(testSpeaker);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });

    test('updateSpeaker updates an existing speaker', () async {
      // Arrange
      when(
        mockDataLoaderManager.loadSpeakers(),
      ).thenAnswer((_) async => [testSpeaker]);

      // Act
      await mockDataUpdateManager.updateSpeaker(
        testSpeaker.copyWith(name: 'New Name'),
      );

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });

    test('updateEvent adds a new event if not present', () async {
      // Act
      await mockDataUpdateManager.updateEvent(testEvent);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });

    test('updateEvents adds a news events if not present', () async {
      // Act
      await mockDataUpdateManager.updateEvents([testEvent]);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('should move a session to a new track and update all related data', () async {
      // Arrange
      // Vamos a mover `session1` del `track1` al `track2` y cambiar su día al `day2`.
      final updatedSession = Session(
        uid: 'session-1',
        title: 'Updated Title', // También actualizamos el título
        eventUID: 'event-1',
        agendaDayUID: 'day-2',
        time: '',
        speakerUID: '',
        type: '', // Nuevo día
      );

      // Act
      await mockDataUpdateManager.updateSession(
        updatedSession,
        'track-2',
      ); // Mover a track-2

      // Assert
      final captured =
          verify(
                mockCommonsServices.updateAllData(captureAny, any, any),
              ).captured.first
              as GithubJsonModel;

      // 1. Verificar la lista de SESIONES
      // La sesión debe estar actualizada en la lista final.
      expect(captured.sessions.length, 1);
      expect(captured.sessions.first.title, 'Updated Title');
      expect(captured.sessions.first.agendaDayUID, 'day-2');

      // 2. Verificar la lista de TRACKS
      // La sesión debe ser eliminada del track original y añadida al nuevo.
      final capturedTrack1 = captured.tracks.firstWhere(
        (t) => t.uid == 'track-1',
      );
      final capturedTrack2 = captured.tracks.firstWhere(
        (t) => t.uid == 'track-2',
      );
      expect(capturedTrack1.sessionUids, isNot(contains('session-1')));
      expect(capturedTrack2.sessionUids, contains('session-1'));

      // 3. Verificar la lista de AGENDADAYS
      // El nuevo track (track-2) debe ser añadido al nuevo día de la sesión (day-2).
      // El viejo track (track-1) debería ser removido del día si ya no tiene sesiones ahí (lógica compleja, pero podemos verificar la adición).
      final capturedDay1 = captured.agendadays.firstWhere(
        (d) => d.uid == 'day-1',
      );
      final capturedDay2 = captured.agendadays.firstWhere(
        (d) => d.uid == 'day-2',
      );
      expect(
        capturedDay1.trackUids,
        isNot(contains('track-2')),
      ); // Asegurarse de que no se añade donde no debe
      expect(capturedDay2.trackUids, contains('track-2'));

      // 4. Verificar la lista de EVENTOS
      // El evento debe reflejar la adición del nuevo track si este no estaba antes.
      // La lógica de la función es un poco compleja aquí (elimina y luego añade).
      // Verificamos que el track-2 está ahora en el evento.
      final capturedEvent = captured.events.firstWhere(
        (e) => e.uid == 'event-1',
      );
      expect(capturedEvent.tracks.any((t) => t.uid == 'track-2'), isTrue);
    });

    test('should add a new session if it does not exist', () async {
      // Arrange
      final newSession = Session(
        uid: 'session-new',
        title: 'New Session',
        eventUID: 'event-1',
        agendaDayUID: 'day-1',
        time: '',
        speakerUID: '',
        type: '',
      );

      // Act
      await mockDataUpdateManager.updateSession(newSession, 'track-1');

      // Assert
      final captured =
          verify(
                mockCommonsServices.updateAllData(captureAny, any, any),
              ).captured.first
              as GithubJsonModel;

      // Verificar que la nueva sesión fue añadida
      expect(captured.sessions.length, 2);
      expect(captured.sessions.any((s) => s.uid == 'session-new'), isTrue);

      // Verificar que el track-1 ahora contiene la nueva sesión
      final capturedTrack1 = captured.tracks.firstWhere(
        (t) => t.uid == 'track-1',
      );
      expect(capturedTrack1.sessionUids, contains('session-new'));
    });

    test(
      'should handle moving a session to a null track (un-assigning)',
      () async {
        // Arrange
        final updatedSession = Session(
          uid: 'session-1',
          title: 'Unassigned Session',
          eventUID: 'event-1',
          agendaDayUID: 'day-1',
          time: '',
          speakerUID: '',
          type: '',
        );

        // Act
        await mockDataUpdateManager.updateSession(
          updatedSession,
          null,
        ); // trackUID es null

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );
    test('updateTrack adds a new event if not present', () async {
      // Act
      await mockDataUpdateManager.updateTrack(testTrack);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('updateTrack adds a new track if not present', () async {
      // Act
      await mockDataUpdateManager.updateTrack(testTrack);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('updateTracks adds a news tracks if not present', () async {
      // Act
      await mockDataUpdateManager.updateTracks([testTrack]);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('updateSpeakers adds a news Speakers if not present', () async {
      // Act
      await mockDataUpdateManager.updateSpeakers([testSpeaker]);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('agendaDay adds a news agendaDay if not present', () async {
      // Act
      await mockDataUpdateManager.updateAgendaDay(agendaDay);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('AgendaDays adds a news AgendaDays if not present', () async {
      // Act
      await mockDataUpdateManager.updateAgendaDays([agendaDay]);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('Sponsor adds a news Sponsor if not present', () async {
      // Act
      await mockDataUpdateManager.updateSponsors(testSponsor);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    test('Sponsors adds a news Sponsors if not present', () async {
      // Act
      await mockDataUpdateManager.updateSponsorsList([testSponsor]);

      // Assert
      verify(mockCommonsServices.updateAllData(any, any, any)).called(1);
    });
    group('Speaker Updates', () {
      test(
        'updateSpeakers should call _updateAllEventData with the provided speakers',
        () async {
          // Arrange
          final speakers = [
            Speaker(
              uid: 'speaker-3',
              name: 'New Speaker',
              bio: 'Bio',
              eventUIDS: ['event-1'],
              image: '',
              social: MockSocial(),
            ),
          ];

          // Act
          await mockDataUpdateManager.updateSpeakers(speakers);

          // Assert
          // Se espera que llame a _updateAllEventData, que a su vez llama a _commitDataUpdate
          final captured =
              verify(
                    mockCommonsServices.updateAllData(captureAny, any, any),
                  ).captured.first
                  as GithubJsonModel;

          // Comprueba que los speakers actualizados están en la carga final
          expect(captured.speakers, containsAll(speakers));
        },
      );
    });

    group('Track Updates', () {
      test('updateTrack should add a new track if it does not exist', () async {
        // Arrange
        final newTrack = Track(
          uid: 'track-3',
          name: 'New Track',
          eventUid: 'event-1',
          color: '',
          sessionUids: [],
        );
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 'track-1',
              name: 'Track 1',
              eventUid: 'event-1',
              color: '',
              sessionUids: [],
            ),
            Track(
              uid: 'track-2',
              name: 'Track 2',
              eventUid: 'event-1',
              color: '',
              sessionUids: [],
            ),
          ],
        );

        // Act
        await mockDataUpdateManager.updateTrack(newTrack);

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      });

      test('updateTrack should update an existing track', () async {
        // Arrange
        final updatedTrack = Track(
          uid: 'track-1',
          name: 'Updated Track Name',
          eventUid: 'event-1',
          color: '',
          sessionUids: [],
        );
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 'track-1',
              name: 'Original Name',
              eventUid: 'event-1',
              color: '',
              sessionUids: [],
            ),
          ],
        );

        // Act
        await mockDataUpdateManager.updateTrack(updatedTrack);

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      });

      test(
        'updateTracks should call _updateAllEventData with overrideData false',
        () async {
          // Arrange
          final tracks = [
            Track(
              uid: 'track-3',
              name: 'Track 3',
              eventUid: 'event-1',
              color: '',
              sessionUids: [],
            ),
          ];

          // Act
          await mockDataUpdateManager.updateTracks(tracks, overrideData: false);

          // Assert
          final captured =
              verify(
                    mockCommonsServices.updateAllData(captureAny, any, any),
                  ).captured.first
                  as GithubJsonModel;

          // Verifica que el nuevo track se ha añadido a los existentes
          expect(captured.tracks.any((t) => t.uid == 'track-3'), isTrue);
        },
      );

      test(
        'updateTracks should call _updateAllEventData with overrideData true',
        () async {
          // Arrange
          final tracks = [
            Track(
              uid: 'track-3',
              name: 'Track 3',
              eventUid: 'event-1',
              color: '',
              sessionUids: [],
            ),
          ];

          // Act
          await mockDataUpdateManager.updateTracks(tracks, overrideData: true);

          // Assert
          final captured =
              verify(
                    mockCommonsServices.updateAllData(captureAny, any, any),
                  ).captured.first
                  as GithubJsonModel;

          // Con override, solo los nuevos tracks deben existir
          expect(captured.tracks, tracks);
        },
      );
    });

    group('AgendaDay Updates', () {
      test(
        'updateAgendaDay should add a new day if it does not exist',
        () async {
          // Arrange
          final newDay = AgendaDay(
            uid: 'day-3',
            eventsUID: ['event-1'],
            date: '',
          );
          when(mockDataLoaderManager.loadAllDays()).thenAnswer(
            (_) async => [
              AgendaDay(uid: 'day-1', eventsUID: ['event-1'], date: ''),
            ],
          );

          // Act
          await mockDataUpdateManager.updateAgendaDay(newDay);

          // Assert
          final captured =
              verify(
                    mockCommonsServices.updateAllData(captureAny, any, any),
                  ).captured.first
                  as GithubJsonModel;

          expect(captured.agendadays.length, 2);
          expect(captured.agendadays.any((d) => d.uid == 'day-3'), isTrue);
        },
      );

      test('updateAgendaDay should update an existing day', () async {
        // Arrange
        final updatedDay = AgendaDay(
          uid: 'day-1',
          eventsUID: ['event-1'],
          date: '',
        );
        when(mockDataLoaderManager.loadAllDays()).thenAnswer(
          (_) async => [
            AgendaDay(uid: 'day-1', eventsUID: ['event-1'], date: ''),
          ],
        );

        // Act
        await mockDataUpdateManager.updateAgendaDay(updatedDay);

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      });

      test(
        'updateAgendaDays with overrideData=true should remove old days for the event and add new ones',
        () async {
          // Arrange
          final oldDays = [
            AgendaDay(uid: 'day-1', eventsUID: ['event-1'], date: ''),
            AgendaDay(uid: 'day-2', eventsUID: ['event-2'], date: ''),
          ];
          final newDays = [
            AgendaDay(uid: 'day-3', eventsUID: ['event-1'], date: ''),
          ];
          when(
            mockDataLoaderManager.loadAllDays(),
          ).thenAnswer((_) async => oldDays);

          // Act
          await mockDataUpdateManager.updateAgendaDays(
            newDays,
            overrideData: true,
          );

          // Assert
          final captured =
              verify(
                    mockCommonsServices.updateAllData(captureAny, any, any),
                  ).captured.first
                  as GithubJsonModel;

          expect(
            captured.agendadays.any((d) => d.uid == 'day-1'),
            isFalse,
            reason: 'Old day for event-1 should be removed',
          );
          expect(
            captured.agendadays.any((d) => d.uid == 'day-2'),
            isTrue,
            reason: 'Day for other event should be kept',
          );
          expect(
            captured.agendadays.any((d) => d.uid == 'day-3'),
            isTrue,
            reason: 'New day should be added',
          );
          expect(captured.agendadays.length, 2);
        },
      );
    });

    group('Sponsor Updates', () {
      test(
        'updateSponsors should add a new sponsor if it does not exist',
        () async {
          // Arrange
          final newSponsor = Sponsor(
            uid: 'sponsor-3',
            name: 'New Sponsor',
            type: '',
            logo: '',
            website: '',
            eventUID: '',
          );
          when(mockDataLoaderManager.loadSponsors()).thenAnswer(
            (_) async => [
              Sponsor(
                uid: 'sponsor-1',
                name: 'Sponsor 1',
                type: '',
                logo: '',
                website: '',
                eventUID: '',
              ),
            ],
          );

          // Act
          await mockDataUpdateManager.updateSponsors(newSponsor);

          // Assert
          final captured =
              verify(
                    mockCommonsServices.updateAllData(captureAny, any, any),
                  ).captured.first
                  as GithubJsonModel;

          expect(captured.sponsors.length, 2);
          expect(captured.sponsors.any((s) => s.uid == 'sponsor-3'), isTrue);
        },
      );

      test('updateSponsors should update an existing sponsor', () async {
        // Arrange
        final updatedSponsor = Sponsor(
          uid: 'sponsor-1',
          name: 'Updated Sponsor Name',
          type: '',
          logo: '',
          website: '',
          eventUID: '',
        );
        when(mockDataLoaderManager.loadSponsors()).thenAnswer(
          (_) async => [
            Sponsor(
              uid: 'sponsor-1',
              name: 'Original Name',
              type: '',
              logo: '',
              website: '',
              eventUID: '',
            ),
          ],
        );

        // Act
        await mockDataUpdateManager.updateSponsors(updatedSponsor);

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      });

      test(
        'updateSponsorsList should call _updateAllEventData with the provided sponsors',
        () async {
          // Arrange
          final sponsors = [
            Sponsor(
              uid: 'sponsor-3',
              name: 'New Sponsor',
              type: '',
              logo: '',
              website: '',
              eventUID: '',
            ),
          ];

          // Act
          await mockDataUpdateManager.updateSponsorsList(sponsors);

          // Assert
          final captured =
              verify(
                    mockCommonsServices.updateAllData(captureAny, any, any),
                  ).captured.first
                  as GithubJsonModel;

          expect(captured.sponsors, containsAll(sponsors));
        },
      );
    });
  });
  group('Session Updates', () {
    test(
      'updateSessions should call _updateAllEventData with the provided sessions',
      () async {
        // Arrange
        final sessions = [
          Session(
            uid: 'session-3',
            title: 'New Session',
            time: '',
            speakerUID: '',
            eventUID: '',
            agendaDayUID: '',
            type: '',
          ),
        ];

        // Act
        await mockDataUpdateManager.updateSessions(sessions);

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );
  });

  group('Remove Operations', () {
    test(
      'removeSpeaker should throw CertainException if speaker is in a session',
      () {
        // Arrange
        when(mockDataLoaderManager.loadAllSessions()).thenAnswer(
          (_) async => [
            Session(
              uid: 'session-1',
              speakerUID: 'speaker-in-use',
              title: '',
              time: '',
              eventUID: '',
              agendaDayUID: '',
              type: '',
            ),
          ],
        );

        // Act & Assert
        // Verifica que se lanza una excepción específica cuando se intenta borrar un ponente en uso.
        expect(
          () =>
              mockDataUpdateManager.removeSpeaker('speaker-in-use', 'event-1'),
          throwsA(isA<CertainException>()),
        );
      },
    );

    test(
      'removeSpeaker should remove speaker entirely if it belongs to only one event',
      () async {
        // Arrange
        final speaker = Speaker(
          uid: 'speaker-1',
          name: 'Speaker',
          bio: '',
          eventUIDS: ['event-1'],
          image: '',
          social: MockSocial(),
        );
        final speaker2 = Speaker(
          uid: 'speaker-2',
          name: 'Speaker2',
          bio: '',
          eventUIDS: ['event-2'],
          image: '',
          social: MockSocial(),
        );
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenAnswer((_) async => [speaker,speaker2]);
        when(
          mockDataLoaderManager.loadAllSessions(),
        ).thenAnswer((_) async => []);

        // Act
        await mockDataUpdateManager.removeSpeaker('speaker-1', 'event-1');

        // Assert
        // Verifica que la lista final de ponentes está vacía.
        verify(
          mockCommonsServices.updateAllData(any, any, any),
        ).called(1);
      },
    );

    test(
      'removeSpeaker should only remove eventUID if speaker belongs to multiple events',
      () async {
        // Arrange
        final speaker = Speaker(
          uid: 'speaker-1',
          name: 'Speaker',
          bio: '',
          eventUIDS: ['event-1', 'event-2'],
          image: '',
          social: MockSocial(),
        );
        when(
          mockDataLoaderManager.loadSpeakers(),
        ).thenAnswer((_) async => [speaker]);
        when(
          mockDataLoaderManager.loadAllSessions(),
        ).thenAnswer((_) async => []);

        // Act
        await mockDataUpdateManager.removeSpeaker('speaker-1', 'event-1');

        // Assert
        // Verifica que el ponente todavía existe pero ya no está asociado a 'event-1'.
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );

    test(
      'removeSponsors should call overwriteItems with remaining sponsors',
      () async {
        // Arrange
        final sponsors = [
          Sponsor(
            uid: 'sponsor-1',
            name: 'Sponsor 1',
            type: '',
            logo: '',
            website: '',
            eventUID: '',
          ),
          Sponsor(
            uid: 'sponsor-2',
            name: 'Sponsor 2',
            type: '',
            logo: '',
            website: '',
            eventUID: '',
          ),
        ];
        when(
          mockDataLoaderManager.loadSponsors(),
        ).thenAnswer((_) async => sponsors);

        // Act
        await mockDataUpdateManager.removeSponsors('sponsor-1');

        // Assert
        // Verifica que la lista final solo contiene los patrocinadores que no se borraron.
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );

    test('removeEvent should remove event and all its related data', () async {
      // Arrange
      final eventToRemove = 'event-1';
      when(mockDataLoaderManager.loadEvents()).thenAnswer(
        (_) async => [
          Event(
            uid: 'event-1',
            location: '',
            description: '',
            tracks: [],
            eventName: '',
            year: '',
            primaryColor: '',
            secondaryColor: '',
            eventDates: MockEventDates(),
          ),
          Event(
            uid: 'event-2',
            location: '',
            description: '',
            tracks: [],
            eventName: '',
            year: '',
            primaryColor: '',
            secondaryColor: '',
            eventDates: MockEventDates(),
          ),
        ],
      );
      when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
        (_) async => [
          Track(
            uid: 'track-1',
            eventUid: 'event-1',
            name: '',
            color: '',
            sessionUids: [],
          ),
        ],
      );
      when(mockDataLoaderManager.loadAllSessions()).thenAnswer(
        (_) async => [
          Session(
            uid: 'session-1',
            eventUID: 'event-1',
            title: '',
            time: '',
            speakerUID: '',
            agendaDayUID: '',
            type: '',
          ),
        ],
      );
      when(mockDataLoaderManager.loadSpeakers()).thenAnswer(
        (_) async => [
          Speaker(
            uid: 'speaker-1',
            eventUIDS: ['event-1', 'event-2'],
            name: '',
            bio: '',
            image: '',
            social: MockSocial(),
          ),
        ],
      );
      when(mockDataLoaderManager.loadAllDays()).thenAnswer(
        (_) async => [
          AgendaDay(uid: 'day-1', eventsUID: ['event-1'], date: ''),
        ],
      );

      // Act
      await mockDataUpdateManager.removeEvent(eventToRemove);

      // Assert
      // Verifica que el evento y todos sus datos asociados (tracks, sessions, etc.) han sido eliminados.
      verify(mockCommonsServices.updateAllData(captureAny, any, any)).called(1);
    });

    test(
      'removeAgendaDay should call overwriteItems with remaining agenda days',
      () async {
        // Arrange
        final days = [
          AgendaDay(uid: 'day-1', eventsUID: ['e1'], date: ''),
          AgendaDay(uid: 'day-2', eventsUID: ['e1'], date: ''),
        ];
        when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => days);

        // Act
        await mockDataUpdateManager.removeAgendaDay('day-1');

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );

    test(
      'removeSession should remove session and its references from tracks',
      () async {
        // Arrange
        final sessionIdToRemove = 'session-1';
        when(mockDataLoaderManager.loadAllSessions()).thenAnswer(
          (_) async => [
            Session(
              uid: sessionIdToRemove,
              title: '',
              time: '',
              speakerUID: '',
              eventUID: '',
              agendaDayUID: '',
              type: '',
            ),
          ],
        );
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 'track-1',
              sessionUids: [sessionIdToRemove],
              name: '',
              color: '',
              eventUid: '',
            ),
          ],
        );

        // Act
        await mockDataUpdateManager.removeSession(sessionIdToRemove);

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );

    test(
      'removeTrack should call overwriteItems with remaining tracks',
      () async {
        // Arrange
        final tracks = [
          Track(
            uid: 'track-1',
            name: '',
            color: '',
            sessionUids: [],
            eventUid: '',
          ),
          Track(
            uid: 'track-2',
            name: '',
            color: '',
            sessionUids: [],
            eventUid: '',
          ),
        ];
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => tracks);

        // Act
        await mockDataUpdateManager.removeTrack('track-1');

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );
  });

  group('overwriteItems', () {
    test(
      'should call _updateAllEventData with correct list for Event type',
      () async {
        // Arrange
        final items = [
          Event(
            uid: 'event-1',
            location: '',
            description: '',
            tracks: [],
            eventName: '',
            year: '',
            primaryColor: '',
            secondaryColor: '',
            eventDates: MockEventDates(),
          ),
        ];

        // Act
        await mockDataUpdateManager.overwriteItems(items, "Event");

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );

    test(
      'should call _updateAllEventData with correct list for Speaker type',
      () async {
        // Arrange
        final items = [
          Speaker(
            uid: 'speaker-1',
            name: '',
            bio: '',
            image: '',
            social: MockSocial(),
            eventUIDS: [],
          ),
        ];

        // Act
        await mockDataUpdateManager.overwriteItems(items, "Speaker");

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );

    test(
      'should call _updateAllEventData with correct list for Sponsor type',
      () async {
        // Arrange
        final items = [
          Sponsor(
            uid: 'sponsor-1',
            name: '',
            type: '',
            logo: '',
            website: '',
            eventUID: '',
          ),
        ];

        // Act
        await mockDataUpdateManager.overwriteItems(items, "Sponsor");

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );

    // Puedes añadir tests similares para Track, Session, y AgendaDay para una cobertura completa.
    test(
      'should call _updateAllEventData with correct list for Track type',
      () async {
        // Arrange
        final items = [
          Track(
            uid: 'track-1',
            name: '',
            color: '',
            sessionUids: [],
            eventUid: '',
          ),
        ];

        // Act
        await mockDataUpdateManager.overwriteItems(items, "Track");

        // Assert
        verify(
          mockCommonsServices.updateAllData(captureAny, any, any),
        ).called(1);
      },
    );
  });
}
