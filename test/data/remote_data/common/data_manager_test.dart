import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';

// Generate mocks with `flutter pub run build_runner build`
import '../../../mocks.mocks.dart';

void main() {
  // Declare mock instances and the class under test
  late DataUpdate dataUpdate;
  late MockDataLoaderManager mockDataLoaderManager;
  late MockDataUpdateManager dataUpdateManager;

  setUp(() async {
    getIt.reset();
    // Initialize mocks before each test
    mockDataLoaderManager = MockDataLoaderManager();
    dataUpdateManager = MockDataUpdateManager();

    getIt.registerSingleton<DataLoaderManager>(mockDataLoaderManager);
    getIt.registerSingleton<DataUpdateManager>(dataUpdateManager);
    dataUpdate = DataUpdate();
    getIt.registerSingleton<DataUpdate>(dataUpdate);
  });

  group('DataUpdate Tests', () {
    // Tests for the deleteItemAndAssociations method
    group('deleteItemAndAssociations', () {
      test('should call _deleteEvent when itemType is "Event"', () async {
        // Arrange
        const itemId = 'event123';
        when(dataUpdateManager.removeEvent(any)).thenAnswer((_) async => {});

        // Act
        await dataUpdate.deleteItemAndAssociations(itemId, 'Event');

        // Assert
        verify(dataUpdateManager.removeEvent(itemId)).called(1);
      });

      test(
        'should call _deleteSession when itemType is "Session without days"',
        () async {
          // Arrange
          const sessionId = 'session123';
          when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
            (_) async => [
              Track(
                uid: 'uid1',
                name: 'test',
                color: '',
                sessionUids: ['session123'],
                eventUid: 'event1',
              ),
            ],
          );
          when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);
          when(
            dataUpdateManager.updateTracks(
              any,
              overrideData: anyNamed('overrideData'),
            ),
          ).thenAnswer((_) async => {});
          when(
            dataUpdateManager.removeSession(any),
          ).thenAnswer((_) async => {});

          // Act
          await dataUpdate.deleteItemAndAssociations(sessionId, 'Session');

          // Assert
          verify(mockDataLoaderManager.loadAllTracks()).called(1);
          verify(dataUpdateManager.removeSession(sessionId)).called(1);
        },
      );

      test('should call _deleteSession when itemType is "Session"', () async {
        // Arrange
        const sessionId = 'session123';
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer(
          (_) async => [
            Track(
              uid: 'uid1',
              name: 'test',
              color: '',
              sessionUids: ['session123'],
              eventUid: 'event1',
            ),
          ],
        );
        when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);
        when(
          dataUpdateManager.updateTracks(
            any,
            overrideData: anyNamed('overrideData'),
          ),
        ).thenAnswer((_) async => {});
        when(dataUpdateManager.removeSession(any)).thenAnswer((_) async => {});

        // Act
        await dataUpdate.deleteItemAndAssociations(sessionId, 'Session');

        // Assert
        verify(mockDataLoaderManager.loadAllTracks()).called(1);
        verify(dataUpdateManager.removeSession(sessionId)).called(1);
      });

      test(
        'should throw an exception for an unsupported itemType in delete',
        () async {
          // Arrange
          const itemId = 'testId';
          const itemType = 'UnsupportedType';

          // Act & Assert
          expect(
            () => dataUpdate.deleteItemAndAssociations(itemId, itemType),
            throwsA(isA<Exception>()),
          );
        },
      );
    });

    // Tests for the addItemAndAssociations method
    group('addItemAndAssociations', () {
      test('should call _addEvent when the item is an Event', () async {
        // Arrange
        final event = Event(
          uid: 'event1',
          tracks: [],
          eventName: 'Test Event',
          year: '',
          primaryColor: '',
          secondaryColor: '',
          eventDates: MockEventDates(),
        );
        when(dataUpdateManager.updateEvent(any)).thenAnswer((_) async => {});

        // Act
        await dataUpdate.addItemAndAssociations(event, null);

        // Assert
        verify(dataUpdateManager.updateEvent(event)).called(1);
      });

      test('should call _addSession when the item is a Session', () async {
        // Arrange
        final session = Session(
          uid: 'session1',
          title: 'Test Session',
          time: '',
          speakerUID: '',
          eventUID: '',
          agendaDayUID: '',
          type: '',
        );
        const parentId = 'track1';
        when(
          dataUpdateManager.updateSession(any, any),
        ).thenAnswer((_) async => {});

        // Act
        await dataUpdate.addItemAndAssociations(session, parentId);

        // Assert
        verify(dataUpdateManager.updateSession(session, parentId)).called(1);
      });

      test('should call _addSpeaker when the item is a Speaker', () async {
        // Arrange
        final speaker = Speaker(
          uid: 'speaker1',
          name: 'John Doe',
          eventUIDS: [],
          bio: '',
          image: '',
          social: MockSocial(),
        );
        const parentId = 'event1';
        when(dataUpdateManager.updateSpeaker(any)).thenAnswer((_) async => {});

        // Act
        await dataUpdate.addItemAndAssociations(speaker, parentId);

        // Assert
        expect(speaker.eventUIDS, contains(parentId));
        verify(dataUpdateManager.updateSpeaker(speaker)).called(1);
      });

      test(
        'should throw an exception for an unsupported itemType in add',
        () async {
          // Arrange
          final unsupportedItem = _UnsupportedItem();

          // Act & Assert
          expect(
            () => dataUpdate.addItemAndAssociations(unsupportedItem, null),
            throwsA(isA<Exception>()),
          );
        },
      );
    });

    // Tests for the addItemListAndAssociations method
    group('addItemListAndAssociations', () {
      test(
        'should call _addSessions when the list contains Sessions',
        () async {
          // Arrange
          final sessions = [
            Session(
              uid: 's1',
              title: 'Session 1',
              time: '',
              speakerUID: '',
              eventUID: '',
              agendaDayUID: '',
              type: '',
            ),
          ];
          when(
            mockDataLoaderManager.loadAllSessions(),
          ).thenAnswer((_) async => []);
          when(
            dataUpdateManager.updateSessions(any),
          ).thenAnswer((_) async => {});

          // Act
          await dataUpdate.addItemListAndAssociations(sessions);

          // Assert
          verify(mockDataLoaderManager.loadAllSessions()).called(1);
          verify(dataUpdateManager.updateSessions(any)).called(1);
        },
      );

      test('should do nothing if the list is empty', () async {
        // Arrange
        final emptyList = [];

        // Act
        await dataUpdate.addItemListAndAssociations(emptyList);

        // Assert
        verifyZeroInteractions(mockDataLoaderManager);
        verifyZeroInteractions(dataUpdateManager);
      });

      test(
        'should throw an exception for a list with an unsupported type',
        () async {
          // Arrange
          final unsupportedList = [_UnsupportedItem()];

          // Act & Assert
          expect(
            () => dataUpdate.addItemListAndAssociations(unsupportedList),
            throwsA(isA<Exception>()),
          );
        },
      );
    });
  });
  group('DataUpdate Tests', () {
    // ... (tests existentes para Event, Session, Track, etc.)

    group('addItemAndAssociations', () {
      // ... (tests existentes)

      test(
        'debería llamar a _addSpeaker cuando el item es un Speaker',
        () async {
          // Arrange
          final speaker = Speaker(
            uid: 'speaker1',
            name: 'John Doe',
            eventUIDS: [],
            bio: '',
            image: '',
            social: MockSocial(),
          );
          const parentId = 'event1';
          when(
            dataUpdateManager.updateSpeaker(any),
          ).thenAnswer((_) async => {});

          // Act
          await dataUpdate.addItemAndAssociations(speaker, parentId);

          // Assert
          expect(speaker.eventUIDS, contains(parentId));
          verify(dataUpdateManager.updateSpeaker(speaker)).called(1);
        },
      );

      test(
        'debería llamar a _addSponsor cuando el item es un Sponsor',
        () async {
          // Arrange
          final sponsor = Sponsor(
            uid: 'sponsor1',
            name: 'Company',
            eventUID: '',
            type: 'gold',
            logo: '',
            website: '',
          );
          const parentId = 'event1';
          when(
            dataUpdateManager.updateSponsors(any),
          ).thenAnswer((_) async => {});

          // Act
          await dataUpdate.addItemAndAssociations(sponsor, parentId);

          // Assert
          expect(sponsor.eventUID, parentId);
          verify(dataUpdateManager.updateSponsors(sponsor)).called(1);
        },
      );

      test(
        'debería llamar a _addOrganization cuando el item es una Config',
        () async {
          // Arrange
          final config = Config(
            configName: 'My Org',
            primaryColorOrganization: '',
            secondaryColorOrganization: '',
            githubUser: '',
            projectName: '',
            branch: '',
          );
          when(
            dataUpdateManager.updateOrganization(any),
          ).thenAnswer((_) async => {});

          // Act
          await dataUpdate.addItemAndAssociations(config, null);

          // Assert
          verify(dataUpdateManager.updateOrganization(config)).called(1);
        },
      );
    });

    group('addItemListAndAssociations', () {
      // ... (tests existentes)

      test(
        'debería llamar a _addSpeakers cuando la lista contiene Speakers',
        () async {
          // Arrange
          final speakers = [
            Speaker(
              uid: 'sp1',
              name: 'Speaker 1',
              bio: '',
              image: '',
              social: MockSocial(),
              eventUIDS: [],
            ),
          ];
          when(
            mockDataLoaderManager.loadSpeakers(),
          ).thenAnswer((_) async => []);
          when(
            dataUpdateManager.updateSpeakers(any),
          ).thenAnswer((_) async => {});

          // Act
          await dataUpdate.addItemListAndAssociations(speakers);

          // Assert
          verify(mockDataLoaderManager.loadSpeakers()).called(1);
          verify(dataUpdateManager.updateSpeakers(any)).called(1);
        },
      );

      test(
        'debería llamar a _addSponsors cuando la lista contiene Sponsors',
        () async {
          // Arrange
          final sponsors = [
            Sponsor(
              uid: 'spons1',
              name: 'Sponsor 1',
              type: 'gold',
              logo: '',
              website: '',
              eventUID: '',
            ),
          ];
          when(
            mockDataLoaderManager.loadSponsors(),
          ).thenAnswer((_) async => []);
          when(
            dataUpdateManager.updateSponsorsList(any),
          ).thenAnswer((_) async => {});

          // Act
          await dataUpdate.addItemListAndAssociations(sponsors);

          // Assert
          verify(mockDataLoaderManager.loadSponsors()).called(1);
          verify(dataUpdateManager.updateSponsorsList(any)).called(1);
        },
      );
    });

    group('deleteItemAndAssociations', () {
      // ... (tests existentes)

      test(
        'debería llamar a _deleteSpeaker cuando el itemType es "Speaker"',
        () async {
          // Arrange
          const speakerId = 'speaker123';
          const eventUID = 'event1';
          when(
            dataUpdateManager.removeSpeaker(any, any),
          ).thenAnswer((_) async {});

          // Act
          await dataUpdate.deleteItemAndAssociations(
            speakerId,
            'Speaker',
            eventUID: eventUID,
          );

          // Assert
          verify(
            dataUpdateManager.removeSpeaker(speakerId, eventUID),
          ).called(1);
        },
      );

      test(
        'debería llamar a _deleteSponsor cuando el itemType es "Sponsor"',
        () async {
          // Arrange
          const sponsorId = 'sponsor123';
          when(dataUpdateManager.removeSponsors(any)).thenAnswer((_) async {});

          // Act
          await dataUpdate.deleteItemAndAssociations(sponsorId, 'Sponsor');

          // Assert
          verify(dataUpdateManager.removeSponsors(sponsorId)).called(1);
        },
      );
    });
  });
  // Tests para Track
  group('Track Tests', () {
    test('debería llamar a _addTrack cuando el item es un Track', () async {
      // Arrange
      final track = Track(
        uid: 'track1',
        sessionUids: [],
        name: 'Track de Test',
        color: '',
        eventUid: '',
      );
      const parentId = 'day1';
      // SIMULAMOS EL CASO PROBLEMÁTICO: AgendaDay se carga con trackUids a null.
      final day = AgendaDay(
        uid: 'day1',
        eventsUID: [],
        date: '',
        trackUids: null,
      );

      when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => [day]);
      when(
        dataUpdateManager.updateAgendaDays(any, overrideData: false),
      ).thenAnswer((_) async => {});
      when(dataUpdateManager.updateTrack(any)).thenAnswer((_) async => {});

      // Act
      // Esta llamada fallaría con el error 'Null check operator' si el código no se corrige.
      await dataUpdate.addItemAndAssociations(track, parentId);

      // Assert
      verify(dataUpdateManager.updateTrack(track)).called(1);

      // Capturamos la lista de días que se pasa a updateAgendaDays para verificar su contenido.
      final captured = verify(
        dataUpdateManager.updateAgendaDays(captureAny, overrideData: false),
      ).captured;

      // Verificamos que el día actualizado ahora contiene el trackId en su lista.
      final updatedDay = captured.first.first as AgendaDay;
      expect(updatedDay.trackUids, isNotNull);
      expect(updatedDay.trackUids, contains(track.uid));
    });

    test(
      'debería lanzar una CertainException al intentar borrar un Track con sesiones asociadas',
      () async {
        // Arrange
        const trackId = 'trackConSesiones';
        final track = Track(
          uid: trackId,
          sessionUids: ['session1'],
          name: 'Track Ocupado',
          color: '',
          eventUid: '',
        );
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => [track]);

        // Act & Assert
        expect(
          () => dataUpdate.deleteItemAndAssociations(trackId, 'Track'),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('debería llamar a _addTrack cuando el item es un Track', () async {
      // Arrange
      final track = Track(
        uid: 'track1',
        sessionUids: [],
        name: 'Track de Test',
        color: '',
        eventUid: '',
      );
      const parentId = 'day1';
      final day = AgendaDay(uid: 'day1', eventsUID: [], date: '');
      when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => [day]);
      when(
        dataUpdateManager.updateAgendaDays(any, overrideData: false),
      ).thenAnswer((_) async => {});
      when(dataUpdateManager.updateTrack(any)).thenAnswer((_) async => {});

      // Act
      await dataUpdate.addItemAndAssociations(track, parentId);

      // Assert
      verify(dataUpdateManager.updateTrack(track)).called(1);
      // Verifica que se actualice el día de la agenda asociado
      verify(
        dataUpdateManager.updateAgendaDays(any, overrideData: false),
      ).called(1);
    });

    test(
      'debería llamar a _addTracks cuando la lista contiene Tracks',
      () async {
        // Arrange
        final tracks = [
          Track(
            uid: 't1',
            name: 'Track 1',
            sessionUids: [],
            color: '',
            eventUid: '',
          ),
        ];
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer((_) async => []);
        when(dataUpdateManager.updateTracks(any)).thenAnswer((_) async => {});

        // Act
        await dataUpdate.addItemListAndAssociations(tracks);

        // Assert
        verify(mockDataLoaderManager.loadAllTracks()).called(1);
        verify(dataUpdateManager.updateTracks(any)).called(1);
      },
    );
  });

  // Tests para AgendaDay
  group('AgendaDay Tests', () {
    test(
      'debería llamar a _addAgendaDay cuando el item es un AgendaDay',
      () async {
        // Arrange
        final day = AgendaDay(uid: 'day1', eventsUID: [], date: '');
        const parentId = 'event1';
        when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);
        when(
          dataUpdateManager.updateAgendaDay(any),
        ).thenAnswer((_) async => {});

        // Act
        await dataUpdate.addItemAndAssociations(day, parentId);

        // Assert
        // Comprueba que el ID del evento padre se ha añadido a la lista del día
        expect(day.eventsUID, contains(parentId));
        verify(dataUpdateManager.updateAgendaDay(day)).called(1);
      },
    );

    test(
      'debería llamar a _addAgendaDays cuando la lista contiene AgendaDays',
      () async {
        // Arrange
        final days = [
          AgendaDay(uid: 'd1', eventsUID: ['event1'], date: ''),
        ];
        when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);
        when(
          dataUpdateManager.updateAgendaDays(
            any,
            overrideData: anyNamed('overrideData'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await dataUpdate.addItemListAndAssociations(days);

        // Assert
        verify(mockDataLoaderManager.loadAllDays()).called(1);
        verify(
          dataUpdateManager.updateAgendaDays(
            any,
            overrideData: anyNamed('overrideData'),
          ),
        ).called(1);
      },
    );
    test(
      'debería llamar a _addAgendaDays cuando la lista contiene AgendaDays y overrideData es true',
      () async {
        // Arrange
        final days = [
          AgendaDay(uid: 'd1', eventsUID: ['event1'], date: ''),
        ];
        when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);
        when(
          dataUpdateManager.updateAgendaDays(any, overrideData: true),
        ).thenAnswer((_) async => {});

        // Act
        await dataUpdate.addItemListAndAssociations(days, overrideData: true);

        // Assert
        verify(mockDataLoaderManager.loadAllDays()).called(1);
        verify(
          dataUpdateManager.updateAgendaDays(any, overrideData: true),
        ).called(1);
      },
    );

    test(
      'debería llamar a _deleteAgendaDay cuando el itemType es "AgendaDay"',
      () async {
        // Arrange
        const dayId = 'day123';
        const eventId = 'event1';
        final agendaDay = AgendaDay(
          uid: dayId,
          eventsUID: [eventId, 'event2'],
          date: '',
        );
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay]);
        // No esperamos que se llame a removeAgendaDay porque aún tiene otro evento asociado
        when(
          dataUpdateManager.removeAgendaDay(any),
        ).thenAnswer((_) async => {});

        // Act
        await dataUpdate.deleteItemAndAssociations(
          dayId,
          'AgendaDay',
          eventUID: eventId,
        );

        // Assert
        // Verifica que no se ha borrado el día, solo se ha desasociado del evento
        verifyNever(dataUpdateManager.removeAgendaDay(dayId));
        // La lógica interna debería llamar a _addAgendaDays para actualizar el día sin el eventId
        // Esto es un efecto secundario de cómo está implementado _deleteAgendaDay
        verify(mockDataLoaderManager.loadAllDays()).called(1);
      },
    );

    test(
      'debería llamar a _deleteAgendaDay y eliminarlo si no tiene más eventos asociados',
      () async {
        // Arrange
        const dayId = 'day123';
        const eventId = 'event1';
        final agendaDay = AgendaDay(
          uid: dayId,
          eventsUID: [eventId],
          date: '',
        ); // Solo un evento asociado
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay]);
        when(
          dataUpdateManager.removeAgendaDay(any),
        ).thenAnswer((_) async => {});

        // Act
        await dataUpdate.deleteItemAndAssociations(
          dayId,
          'AgendaDay',
          eventUID: eventId,
        );

        // Assert
        verify(dataUpdateManager.removeAgendaDay(dayId)).called(1);
      },
    );
  });
  group('AgendaDay Track Management Tests', () {
    test(
      'debería eliminar correctamente un trackId de un AgendaDay usando _removeTrackFromDay',
      () async {
        // Arrange
        const trackIdToRemove = 'track2';
        final initialTracks = [
          Track(
            uid: 'track1',
            name: 'Track 1',
            sessionUids: [],
            color: '',
            eventUid: '',
          ),
          Track(
            uid: trackIdToRemove,
            name: 'Track 2',
            sessionUids: [],
            color: '',
            eventUid: '',
          ),
        ];

        // El día de la agenda empieza con dos tracks
        final agendaDay = AgendaDay(
          uid: 'day1',
          eventsUID: ['event1'],
          trackUids: ['track1', trackIdToRemove],
          date: '',
        );

        // El evento que contiene el track
        final event = Event(
          uid: 'event1',
          tracks: initialTracks,
          eventName: 'Test Event',
          year: '2025',
          primaryColor: '',
          secondaryColor: '',
          eventDates: MockEventDates(),
        );

        // Mocks
        when(
          mockDataLoaderManager.loadAllTracks(),
        ).thenAnswer((_) async => initialTracks);
        when(
          mockDataLoaderManager.loadEvents(),
        ).thenAnswer((_) async => [event]);
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay]);

        // No esperamos llamadas a remove, solo a update
        when(dataUpdateManager.removeTrack(any)).thenAnswer((_) async => {});
        when(dataUpdateManager.updateEvent(any)).thenAnswer((_) async => {});

        // El mock clave: capturamos el día actualizado
        when(
          dataUpdateManager.updateAgendaDay(any),
        ).thenAnswer((_) async => {});

        // Act
        // Llamamos a la función pública que desencadena la lógica a probar
        await dataUpdate.deleteItemAndAssociations(trackIdToRemove, 'Track');

        // Assert
        // Capturamos el objeto AgendaDay que se pasa a updateAgendaDay
        final captured = verify(
          dataUpdateManager.updateAgendaDay(captureAny),
        ).captured;
        final updatedDay = captured.first as AgendaDay;

        // Verificamos que el trackId fue eliminado de la lista
        expect(updatedDay.trackUids, isNotNull);
        expect(updatedDay.trackUids, isNot(contains(trackIdToRemove)));
        expect(
          updatedDay.trackUids,
          contains('track1'),
        ); // El otro track debe permanecer
      },
    );

    test(
      'debería añadir correctamente un trackId a un AgendaDay usando la lógica de _addTrack',
      () async {
        // Arrange
        final trackToAdd = Track(
          uid: 'newTrack',
          name: 'New Track',
          sessionUids: [],
          color: '',
          eventUid: '',
        );
        const parentDayId = 'day1';

        // El día de la agenda empieza sin el nuevo track
        final agendaDay = AgendaDay(
          uid: parentDayId,
          eventsUID: ['event1'],
          trackUids: ['existingTrack'],
          date: '', // podría ser null o tener otros tracks
        );

        // Mocks
        when(
          mockDataLoaderManager.loadAllDays(),
        ).thenAnswer((_) async => [agendaDay]);
        when(dataUpdateManager.updateTrack(any)).thenAnswer((_) async => {});
        // Mock clave para capturar el resultado
        when(
          dataUpdateManager.updateAgendaDays(any, overrideData: false),
        ).thenAnswer((_) async {});

        // Act
        await dataUpdate.addItemAndAssociations(trackToAdd, parentDayId);

        // Assert
        // Verificamos la llamada a updateTrack, que es parte de la función principal
        verify(dataUpdateManager.updateTrack(trackToAdd)).called(1);

        // Capturamos la lista de días que se pasa para la actualización
        final captured = verify(
          dataUpdateManager.updateAgendaDays(captureAny, overrideData: false),
        ).captured;
        final updatedDayList = captured.first as List<AgendaDay>;
        final updatedDay = updatedDayList.first;

        // Verificamos que el nuevo trackId se ha añadido
        expect(updatedDay.trackUids, isNotNull);
        expect(updatedDay.trackUids, contains('existingTrack'));
        expect(updatedDay.trackUids, contains(trackToAdd.uid));
      },
    );
  });
}

// Helper class for unsupported type tests
class _UnsupportedItem {}
