import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';

// Generate mocks with `flutter pub run build_runner build`
import '../../../mocks.mocks.dart';

void main() {
  // Declare mock instances and the class under test
  late MockDataLoaderManager mockDataLoaderManager;
  late MockDataUpdateManager mockDataUpdateManager;

  setUp(() {
    // Initialize mocks before each test
    mockDataLoaderManager = MockDataLoaderManager();
    mockDataUpdateManager = MockDataUpdateManager();

    // Override static instances in the DataUpdate class with our mocks
    DataUpdate.dataLoader = mockDataLoaderManager;
    DataUpdate.dataUpdateInfo = mockDataUpdateManager;
  });

  group('DataUpdate Tests', () {
    // Tests for the deleteItemAndAssociations method
    group('deleteItemAndAssociations', () {
      test('should call _deleteEvent when itemType is "Event"', () async {
        // Arrange
        const itemId = 'event123';
        when(
          mockDataUpdateManager.removeEvent(any),
        ).thenAnswer((_) async => {});

        // Act
        await DataUpdate.deleteItemAndAssociations(itemId, 'Event');

        // Assert
        verify(mockDataUpdateManager.removeEvent(itemId)).called(1);
      });

      test('should call _deleteSession when itemType is "Session"', () async {
        // Arrange
        const sessionId = 'session123';
        when(mockDataLoaderManager.loadAllTracks()).thenAnswer((_) async => []);
        when(
          mockDataUpdateManager.updateTracks(
            any,
            overrideData: anyNamed('overrideData'),
          ),
        ).thenAnswer((_) async => {});
        when(
          mockDataUpdateManager.removeSession(any),
        ).thenAnswer((_) async => {});

        // Act
        await DataUpdate.deleteItemAndAssociations(sessionId, 'Session');

        // Assert
        verify(mockDataLoaderManager.loadAllTracks()).called(1);
        verify(mockDataUpdateManager.removeSession(sessionId)).called(1);
      });

      test(
        'should throw an exception for an unsupported itemType in delete',
        () async {
          // Arrange
          const itemId = 'testId';
          const itemType = 'UnsupportedType';

          // Act & Assert
          expect(
            () => DataUpdate.deleteItemAndAssociations(itemId, itemType),
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
        when(
          mockDataUpdateManager.updateEvent(any),
        ).thenAnswer((_) async => {});

        // Act
        await DataUpdate.addItemAndAssociations(event, null);

        // Assert
        verify(mockDataUpdateManager.updateEvent(event)).called(1);
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
          mockDataUpdateManager.updateSession(any, any),
        ).thenAnswer((_) async => {});

        // Act
        await DataUpdate.addItemAndAssociations(session, parentId);

        // Assert
        verify(
          mockDataUpdateManager.updateSession(session, parentId),
        ).called(1);
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
        when(
          mockDataUpdateManager.updateSpeaker(any),
        ).thenAnswer((_) async => {});

        // Act
        await DataUpdate.addItemAndAssociations(speaker, parentId);

        // Assert
        expect(speaker.eventUIDS, contains(parentId));
        verify(mockDataUpdateManager.updateSpeaker(speaker)).called(1);
      });

      test(
        'should throw an exception for an unsupported itemType in add',
        () async {
          // Arrange
          final unsupportedItem = _UnsupportedItem();

          // Act & Assert
          expect(
            () => DataUpdate.addItemAndAssociations(unsupportedItem, null),
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
            mockDataUpdateManager.updateSessions(any),
          ).thenAnswer((_) async => {});

          // Act
          await DataUpdate.addItemListAndAssociations(sessions);

          // Assert
          verify(mockDataLoaderManager.loadAllSessions()).called(1);
          verify(mockDataUpdateManager.updateSessions(any)).called(1);
        },
      );

      test('should do nothing if the list is empty', () async {
        // Arrange
        final emptyList = [];

        // Act
        await DataUpdate.addItemListAndAssociations(emptyList);

        // Assert
        verifyZeroInteractions(mockDataLoaderManager);
        verifyZeroInteractions(mockDataUpdateManager);
      });

      test(
        'should throw an exception for a list with an unsupported type',
        () async {
          // Arrange
          final unsupportedList = [_UnsupportedItem()];

          // Act & Assert
          expect(
            () => DataUpdate.addItemListAndAssociations(unsupportedList),
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
            eventUIDS: [], bio: '', image: '', social: MockSocial(),
          );
          const parentId = 'event1';
          when(
            mockDataUpdateManager.updateSpeaker(any),
          ).thenAnswer((_) async => {});

          // Act
          await DataUpdate.addItemAndAssociations(speaker, parentId);

          // Assert
          expect(speaker.eventUIDS, contains(parentId));
          verify(mockDataUpdateManager.updateSpeaker(speaker)).called(1);
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
            type: '',
            logo: '',
            website: '',
          );
          const parentId = 'event1';
          when(
            mockDataUpdateManager.updateSponsors(any),
          ).thenAnswer((_) async => {});

          // Act
          await DataUpdate.addItemAndAssociations(sponsor, parentId);

          // Assert
          expect(sponsor.eventUID, parentId);
          verify(mockDataUpdateManager.updateSponsors(sponsor)).called(1);
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
            mockDataUpdateManager.updateOrganization(any),
          ).thenAnswer((_) async => {});

          // Act
          await DataUpdate.addItemAndAssociations(config, null);

          // Assert
          verify(mockDataUpdateManager.updateOrganization(config)).called(1);
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
            mockDataUpdateManager.updateSpeakers(any),
          ).thenAnswer((_) async => {});

          // Act
          await DataUpdate.addItemListAndAssociations(speakers);

          // Assert
          verify(mockDataLoaderManager.loadSpeakers()).called(1);
          verify(mockDataUpdateManager.updateSpeakers(any)).called(1);
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
              type: '',
              logo: '',
              website: '',
              eventUID: '',
            ),
          ];
          when(
            mockDataLoaderManager.loadSponsors(),
          ).thenAnswer((_) async => []);
          when(
            mockDataUpdateManager.updateSponsorsList(any),
          ).thenAnswer((_) async => {});

          // Act
          await DataUpdate.addItemListAndAssociations(sponsors);

          // Assert
          verify(mockDataLoaderManager.loadSponsors()).called(1);
          verify(mockDataUpdateManager.updateSponsorsList(any)).called(1);
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
            mockDataUpdateManager.removeSpeaker(any, any),
          ).thenAnswer((_) async {});

          // Act
          await DataUpdate.deleteItemAndAssociations(
            speakerId,
            'Speaker',
            eventUID: eventUID,
          );

          // Assert
          verify(
            mockDataUpdateManager.removeSpeaker(speakerId, eventUID),
          ).called(1);
        },
      );

      test(
        'debería llamar a _deleteSponsor cuando el itemType es "Sponsor"',
        () async {
          // Arrange
          const sponsorId = 'sponsor123';
          when(
            mockDataUpdateManager.removeSponsors(any),
          ).thenAnswer((_) async {});

          // Act
          await DataUpdate.deleteItemAndAssociations(sponsorId, 'Sponsor');

          // Assert
          verify(mockDataUpdateManager.removeSponsors(sponsorId)).called(1);
        },
      );
    });
  });
}

// Helper class for unsupported type tests
class _UnsupportedItem {}
