import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/config.dart';

void main() {
  group('Config Model', () {
    final json = {
      'configName': 'Test Config',
      'primaryColorOrganization': '#FFFFFF',
      'secondaryColorOrganization': '#000000',
      'github_user': 'test-user',
      'project_name': 'test-project',
      'branch': 'main',
      'eventForcedToViewUID': 'event1'
    };

    test('fromJson should return a valid Config object', () {
      final config = Config.fromJson(json);

      expect(config.configName, 'Test Config');
      expect(config.primaryColorOrganization, '#FFFFFF');
      expect(config.secondaryColorOrganization, '#000000');
      expect(config.githubUser, 'test-user');
      expect(config.projectName, 'test-project');
      expect(config.branch, 'main');
      expect(config.eventForcedToViewUID, 'event1');
    });

    test('toJson should return a valid JSON object', () {
      final config = Config(
        configName: 'Test Config',
        primaryColorOrganization: '#FFFFFF',
        secondaryColorOrganization: '#000000',
        githubUser: 'test-user',
        projectName: 'test-project',
        branch: 'main',
        eventForcedToViewUID: 'event1',
      );

      final result = config.toJson();

      expect(result['configName'], 'Test Config');
      expect(result['primaryColorOrganization'], '#FFFFFF');
      expect(result['secondaryColorOrganization'], '#000000');
      expect(result['github_user'], 'test-user');
      expect(result['project_name'], 'test-project');
      expect(result['branch'], 'main');
      expect(result['eventForcedToViewUID'], 'event1');
    });
  });
}
