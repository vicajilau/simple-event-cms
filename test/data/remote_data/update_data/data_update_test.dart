import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';

import '../../../mocks.mocks.dart';

void main() {
  late DataUpdateManager mockDataUpdateManager;
  late MockCommonsServices mockCommonsServices;
  late MockDataLoader mockDataLoaderManager;

  setUpAll(() async{
    getIt.reset();
    getIt.registerSingleton<Config>(MockConfig());
    mockCommonsServices = MockCommonsServices();
    getIt.registerSingleton<CommonsServices>(mockCommonsServices);
    mockDataLoaderManager = MockDataLoader();
    getIt.registerSingleton<DataLoaderManager>(mockDataLoaderManager);
    mockDataUpdateManager = DataUpdateManager();
    getIt.registerSingleton<DataUpdateManager>(mockDataUpdateManager);
    when(mockDataLoaderManager.loadEvents()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadSponsors()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadAllDays()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadAllTracks()).thenAnswer((_) async => []);
    when(mockDataLoaderManager.loadAllSessions()).thenAnswer((_) async => []);
    when(mockCommonsServices.updateAllData(any, any, any)).thenAnswer((_) async => Response("{}", 200));
    when(mockCommonsServices.updateAllData(any, any, any)).thenAnswer(
          (_) async => Response('{}', 200),
    );
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
  });
}
