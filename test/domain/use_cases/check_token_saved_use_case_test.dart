import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/token_repository.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';

import '../../helpers/test_helpers.dart';
import '../../mocks.mocks.dart';


@GenerateMocks([TokenRepository])
void main() {
  late CheckTokenSavedUseCaseImpl useCase;
  late MockTokenRepository mockTokenRepository;

  setUpAll(() async{
    mockTokenRepository = MockTokenRepository();
    getIt.registerSingleton<TokenRepository>(mockTokenRepository);
    useCase = CheckTokenSavedUseCaseImpl();
    useCase.repository = mockTokenRepository;
    provideDummy<Result<void>>(Result.ok(null));
  });

  test('should return true when token is saved', () async {
    // arrange
    when(mockTokenRepository.isTokenSaved()).thenAnswer((_) async => true);
    // act
    final result = await useCase.checkToken();
    // assert
    expect(result, true);
    verify(mockTokenRepository.isTokenSaved());
    verifyNoMoreInteractions(mockTokenRepository);
  });

  test('should return false when token is not saved', () async {
    // arrange
    when(mockTokenRepository.isTokenSaved()).thenAnswer((_) async => false);
    // act
    final result = await useCase.checkToken();
    // assert
    expect(result, false);
    verify(mockTokenRepository.isTokenSaved());
    verifyNoMoreInteractions(mockTokenRepository);
  });
}
