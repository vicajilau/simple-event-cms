import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart' as github_sdk;
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
          }else if (methodCall.arguments['key'] == 'github_service') {
            return '\"{\\"token\\":"token_mocked",\\"projectName\\":\\"simple-event-cms\\"}\"';
          }
        }
        return null;
      });
  group('SecureInfo', () {
    final githubData = GithubData(token: 'token', projectName: 'projectName');


    test('removeGithubKey should remove the token', () async {

      SecureInfo secureInfo = SecureInfo();
      await secureInfo.saveGithubKey(githubData);
      await secureInfo.removeGithubKey();
      final result = await secureInfo.getGithubKey();

      expect(result.getToken(), isNull);
      expect(result.getProjectName(), isNull);
    });
    test('getGithubKey should return a token', () async {
      SecureInfo secureInfo = SecureInfo();
      final result = await secureInfo.getGithubItem();

      expect(result, isA<github_sdk.GitHub>());
      expect(result.auth.token, "token_mocked");
    });
    test('getGithubKey should a null token', () async {
      SecureInfo secureInfo = SecureInfo();
      final result = await secureInfo.getGithubItem();

      expect(result, isA<github_sdk.GitHub>());
    });
  });
}
