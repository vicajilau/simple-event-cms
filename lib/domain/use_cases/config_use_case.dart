import 'package:sec/core/models/config.dart';
import 'package:sec/core/utils/result.dart';

import '../../core/di/dependency_injection.dart';
import '../repositories/sec_repository.dart';

abstract class ConfigUseCase {
  Future<Result<void>> updateConfig(Config config);
}

class ConfigUseCaseImp implements ConfigUseCase {
  SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<void>> updateConfig(Config config) async {
    return await repository.saveConfig(config);
  }
}
