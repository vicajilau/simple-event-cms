import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/repositories/sec_repository_imp.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import '../../mocks.mocks.dart';


@GenerateMocks([DataLoaderManager])
void main() {
  late SecRepository secRepository;
  late MockDataLoader mockDataLoaderManager;

  setUp(() {
    getIt.reset();
    mockDataLoaderManager = MockDataLoader();
    getIt.registerSingleton<DataLoaderManager>(mockDataLoaderManager);
    secRepository = SecRepositoryImp();
  });

  group('SecRepositoryImp', () {
    group('loadEvents', () {
      test('should return a list of events when data loader is successful', () async {
        // Arrange
        when(mockDataLoaderManager.loadEvents()).thenAnswer((_) async => []);

        // Act
        final result = await secRepository.loadEvents();

        // Assert
        expect(result, isA<Ok<List<Event>>>());
        expect((result as Ok<List<Event>>).value, []);
      });

      test('should return a network exception when data loader throws CertainException', () async {
        // Arrange
        when(mockDataLoaderManager.loadEvents())
            .thenThrow(const CertainException('error'));

        // Act
        final result = await secRepository.loadEvents();

        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, isA<NetworkException>());
      });

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
      test('should return a list of speakers when data loader is successful', () async {
        // Arrange
        List<Speaker> speakers = [];
        when(mockDataLoaderManager.loadSpeakers()).thenAnswer((_) async => speakers);

        // Act
        final result = await secRepository.loadESpeakers();

        // Assert
        expect(result, isA<Ok<List<Speaker>>>());
        expect((result as Ok<List<Speaker>>).value, speakers);
      });

      test('should return an empty list when data loader returns null', () async {
        // Arrange
        when(mockDataLoaderManager.loadSpeakers()).thenAnswer((_) async => null);

        // Act
        final result = await secRepository.loadESpeakers();

        // Assert
        expect(result, isA<Ok<List<Speaker>>>());
        expect((result as Ok<List<Speaker>>).value, []);
      });
    });

    group('loadSponsors', () {
      test('should return a list of sponsors when data loader is successful', () async {
        // Arrange
        when(mockDataLoaderManager.loadSponsors()).thenAnswer((_) async => []);

        // Act
        final result = await secRepository.loadSponsors();

        // Assert
        expect(result, isA<Ok<List<Sponsor>>>());
        expect((result as Ok<List<Sponsor>>).value, []);
      });
    });
  });
}
