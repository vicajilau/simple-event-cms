import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/di/config_dependency_helper.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';

void main() {
  group('ConfigDependencyHelper', () {
    final config = Config(
      configName: 'Test Config',
      projectName: 'test-project',
      githubUser: 'test-user',
      branch: 'main',
      primaryColorOrganization: '',
      secondaryColorOrganization: '',
    );

    setUp(() {
      getIt.reset();
    });

    test('setOrganization should register or update the Config singleton', () {
      setOrganization(config);
      expect(getIt.isRegistered<Config>(), isTrue);
      expect(getIt<Config>(), config);

      final newConfig = Config(
        configName: 'New Config',
        projectName: 'new-project',
        githubUser: 'new-user',
        branch: 'dev',
        primaryColorOrganization: '',
        secondaryColorOrganization: '',
      );
      setOrganization(newConfig);
      expect(getIt<Config>(), newConfig);
    });
  });
}
