import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';

import '../../helpers/test_helpers.dart';
import '../../mocks.mocks.dart';

@GenerateMocks([SecRepository])
void main() {
  late ConfigUseCaseImp useCase;
  late MockSecRepository mockSecRepository;

  setUpAll(() async {
    mockSecRepository = MockSecRepository();
    getIt.registerSingleton<SecRepository>(mockSecRepository);
    useCase = ConfigUseCaseImp();
    useCase.repository = mockSecRepository;
    provideDummy<Result<void>>(const Result.ok(null));
  });

  group('updateConfig', () {
    test(
      'should return success when repository updates config successfully',
      () async {
        // arrange
        final config = Config(
          eventForcedToViewUID: 'event1',
          configName: '',
          primaryColorOrganization: '',
          secondaryColorOrganization: '',
          githubUser: '',
          projectName: '',
          branch: '',
        );
        when(
          mockSecRepository.saveConfig(config),
        ).thenAnswer((_) async => Result.ok(null));

        // act
        final result = await useCase.updateConfig(config);

        // assert
        expect(result, isA<Ok>());
        verify(mockSecRepository.saveConfig(config));
        verifyNoMoreInteractions(mockSecRepository);
      },
    );

    test(
      'should return an error when repository fails to update config',
      () async {
        // arrange
        final config = Config(
          eventForcedToViewUID: 'event1',
          configName: '',
          primaryColorOrganization: '',
          secondaryColorOrganization: '',
          githubUser: '',
          projectName: '',
          branch: '',
        );
        final exception = NetworkException('Update failed');
        when(
          mockSecRepository.saveConfig(config),
        ).thenAnswer((_) async => Result.error(exception));

        // act
        final result = await useCase.updateConfig(config);

        // assert
        expect(result, isA<Error>());
        expect((result as Error).error, exception);
      },
    );
  });
}
