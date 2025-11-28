import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/github/github_data.dart';

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
  group('SecureInfo', () {
    final githubData = GithubData(token: 'token', projectName: 'projectName');

    test('removeGithubKey should remove the token', () async {
      await SecureInfo.saveGithubKey(githubData);
      await SecureInfo.removeGithubKey();
      final result = await SecureInfo.getGithubKey();

      expect(result.token, isNull);
      expect(result.projectName, isNull);
    });
  });
}
