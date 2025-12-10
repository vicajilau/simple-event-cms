import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';

// Genera los mocks con `flutter pub run build_runner build`
import '../../../mocks.mocks.dart';

void main() {
  // Declarar las instancias de los mocks y la clase bajo test
  late MockDataLoaderManager mockDataLoaderManager;
  late MockDataUpdateManager mockDataUpdateManager;

  setUp(() {
    // Inicializar los mocks antes de cada test
    mockDataLoaderManager = MockDataLoaderManager();
    mockDataUpdateManager = MockDataUpdateManager();

    // Sobrescribir las instancias estáticas en la clase DataUpdate con nuestros mocks
    DataUpdate.dataLoader = mockDataLoaderManager;
    DataUpdate.dataUpdateInfo = mockDataUpdateManager;
  });

  group('DataUpdate Tests', () {
    // Tests para el método deleteItemAndAssociations
    group('deleteItemAndAssociations', () {
      test(
        'debería llamar a _deleteEvent cuando el itemType es "Event"',
        () async {
          // Arrange
          const itemId = 'event123';
          when(
            mockDataUpdateManager.removeEvent(any),
          ).thenAnswer((_) async => {});

          // Act
          await DataUpdate.deleteItemAndAssociations(itemId, 'Event');

          // Assert
          verify(mockDataUpdateManager.removeEvent(itemId)).called(1);
        },
      );

      test(
        'debería llamar a _deleteSession cuando el itemType es "Session"',
        () async {
          // Arrange
          const sessionId = 'session123';
          when(
            mockDataLoaderManager.loadAllTracks(),
          ).thenAnswer((_) async => []);
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
        },
      );

      test(
        'debería lanzar una excepción para un itemType no soportado en delete',
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

    // Tests para el método addItemAndAssociations
    group('addItemAndAssociations', () {
      test('debería llamar a _addEvent cuando el item es un Event', () async {
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

      test(
        'debería llamar a _addSession cuando el item es una Session',
        () async {
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
        },
      );

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
        'debería lanzar una excepción para un itemType no soportado en add',
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

    // Tests para el método addItemListAndAssociations
    group('addItemListAndAssociations', () {
      test(
        'debería llamar a _addSessions cuando la lista contiene Sessions',
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

      test('debería no hacer nada si la lista está vacía', () async {
        // Arrange
        final emptyList = [];

        // Act
        await DataUpdate.addItemListAndAssociations(emptyList);

        // Assert
        verifyZeroInteractions(mockDataLoaderManager);
        verifyZeroInteractions(mockDataUpdateManager);
      });

      test(
        'debería lanzar una excepción para una lista con un tipo no soportado',
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
}

// Clase auxiliar para los tests de tipos no soportados
class _UnsupportedItem {}
