import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/secure_info.dart';
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

// No se necesita registerFallbackValue para tu versión de mockito.

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'read') {
      if (methodCall.arguments['key'] == 'read') {
        return '{"token":"token_mocked","projectName":"simple-event-cms"}';
      } else if (methodCall.arguments['key'] == 'github_key') {
        return 'some_github_key';
      }
    }
    return null;
  });
  late SecRepository secRepository;
  late DataLoaderManager mockDataLoaderManager;
  late DataUpdateManager mockDataUpdateManager;
  late MockCommonsServices mockCommonsServices;
  late MockDataUpdate dataUpdate;

  setUp(() {
    // Proporcionar Dummies para el sistema de tipos de `Result`
    provideDummy<Result<List<Event>>>(const Result.ok([]));
    provideDummy<Result<List<Track>>>(const Result.ok([]));
    provideDummy<Result<List<Speaker>>>(const Result.ok([]));
    provideDummy<Result<void>>(const Result.ok(null));
    provideDummy<Result<Event?>>(const Result.ok(null));
    provideDummy<Result<Track?>>(const Result.ok(null));

    // Reset y registro de Mocks
    getIt.reset();

    getIt.registerSingleton<SecureInfo>(
      SecureInfo(),
    );
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
    mockDataUpdateManager = MockDataUpdateManager();
    getIt.registerSingleton<DataUpdateManager>(mockDataUpdateManager);
    dataUpdate = MockDataUpdate();
    getIt.registerSingleton<DataUpdate>(dataUpdate);


    // --- CONFIGURACIÓN POR DEFECTO PARA MOCKS ---


    when(mockCommonsServices.loadData(any)).thenAnswer((_) async => <String, dynamic>{});
    when(mockCommonsServices.updateData(any, any, any, any)).thenAnswer((_) async => Response('', 200));
    when(mockCommonsServices.updateAllData(any, any, any)).thenAnswer((_) async => Response('', 200));
    when(mockCommonsServices.updateDataList(any, any, any)).thenAnswer((_) async => Response('', 200));
    when(mockCommonsServices.removeData(any, any, any, any)).thenAnswer((_) async => Response('', 200));
    when(mockCommonsServices.removeDataList(any, any, any, any)).thenAnswer((_) async => Response('', 200));
    when(mockCommonsServices.updateSingleData(any, any, any)).thenAnswer((_) async => Response('', 200));
    when(mockCommonsServices.loadData(any)).thenAnswer((_) async => <String, dynamic>{});



    secRepository = SecRepositoryImp();
  });

  group('SecRepositoryImp', () {
    // Los tests para los métodos 'load' ya estaban correctos, no necesitan cambios.
    group('loadEvents', () {
      test('should return a list of events when data loader is successful', () async {
        final result = await secRepository.loadEvents();
        expect(result, isA<Ok<List<Event>>>());
        expect((result as Ok<List<Event>>).value, []);
      });

      test('should return a network exception when data loader throws CertainException', () async {
        when(mockDataLoaderManager.loadEvents()).thenThrow(const CertainException('error'));
        final result = await secRepository.loadEvents();
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });
    });

    // ... otros tests de 'load' que ya estaban bien ...

    // --- Tests de 'save' y 'delete' corregidos ---

    group('saveEvent', () {
      final testEvent = Event(
        uid: '1',
        tracks: [],
        eventName: 'Test Event',
        year: '2025',
        primaryColor: '',
        secondaryColor: '',
        eventDates: MockEventDates(),
      );

      test('should return Error on CertainException', () async {
        // Arrange
        when(dataUpdate.addItemAndAssociations(testEvent, testEvent.uid)).thenThrow(const CertainException('error'));
        // Act
        final result = await secRepository.saveEvent(testEvent);
        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect((result.error as NetworkException).message, 'error');
      });

      test('should return Error on generic Exception', () async {
        // Arrange
        when(dataUpdate.addItemAndAssociations(any, any)).thenThrow(Exception('generic error'));
        // Act
        final result = await secRepository.saveEvent(testEvent);
        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
        expect((result.error as NetworkException).message, 'Exception: generic error');
      });
    });

    group('saveSpeaker', () {
      final testSpeaker = Speaker(
        uid: '1',
        name: 'Test Speaker',
        bio: '',
        image: '',
        social: MockSocial(),
        eventUIDS: [],
      );

      test('should return Ok when successful', () async {
        // Act
        final result = await secRepository.saveSpeaker(testSpeaker, 'parentId');
        // Assert
        expect(result, isA<Ok>());
        verify(dataUpdate.addItemAndAssociations(testSpeaker, 'parentId')).called(2);
      });
    });

    group('saveSponsor', () {
      final testSponsor = Sponsor(
        uid: '1',
        name: 'Test Sponsor',
        logo: '',
        type: '',
        website: '',
        eventUID: '',
      );

      test('should return Ok when successful', () async {
        // Act
        final result = await secRepository.saveSponsor(testSponsor, 'parentId');
        // Assert
        expect(result, isA<Ok>());
        verify(dataUpdate.addItemAndAssociations(testSponsor, 'parentId')).called(2);
      });
    });

    group('addSession', () {
      final testSession = Session(
        uid: '1',
        title: 'Test Session',
        time: '',
        speakerUID: '',
        eventUID: '',
        type: '',
        agendaDayUID: '',
      );
      test('should return Ok when successful', () async {
        // Act
        final result = await secRepository.addSession(testSession, 'trackUID');
        // Assert
        expect(result, isA<Ok>());
        verify(dataUpdate.addItemAndAssociations(testSession, 'trackUID')).called(2);
      });
    });

    group('removeEvent', () {
      test('should return Ok when successful', () async {
        // Act
        final result = await secRepository.removeEvent('eventId');
        // Assert
        expect(result, isA<Ok>());
        verify(dataUpdate.deleteItemAndAssociations('events', 'eventId')).called(1);
      });
    });

    group('removeAgendaDay', () {
      test('should return Ok when successful', () async {
        // Act
        final result = await secRepository.removeAgendaDay('agendaDayId', 'eventUID');
        // Assert
        expect(result, isA<Ok>());
        verify(dataUpdate.deleteItemAndAssociations('agendaDays', 'agendaDayId')).called(1);
      });
    });
  });
}
