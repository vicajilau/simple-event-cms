import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/domain/repositories/token_repository.dart';

abstract class CheckTokenSavedUseCase {
  Future<bool> checkToken();
}

class CheckTokenSavedUseCaseImpl implements CheckTokenSavedUseCase {
  TokenRepository repository = getIt<TokenRepository>();

  @override
  Future<bool> checkToken() async {
    return await repository.isTokenSaved();
  }
}
