import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureInfo secureInfo;

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUp(() async {
    secureInfo = SecureInfo();

    getIt.reset();
    getIt.registerSingleton<SecureInfo>(secureInfo);
  });

  // Group of tests for the getGithubItem method
  group('getGithubItem', () {
    test(
      'should return a GitHub instance with token authentication if token no exists',
      () async {
        final githubData = GithubData(token: null);
        final githubDataJson = jsonEncode(githubData.toJson());
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'read' &&
                  methodCall.arguments['key'] == 'github_service') {
                return githubDataJson;
              }
              return null;
            });

        final githubItem = await secureInfo.getGithubItem();
        expect(
          githubItem.auth.isAnonymous,
          isTrue,
        );
      },
    );

    test(
      'should return a GitHub instance with anonymous authentication if token is null',
      () async {
        final githubData = GithubData(token: 'token_fake');
        final githubDataJson = jsonEncode(githubData.toJson());
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'read' &&
              methodCall.arguments['key'] == 'github_service') {
            return githubDataJson;
          }
          return null;
        });
        final githubItem = await secureInfo.getGithubItem();
        expect(
          githubItem.auth.isAnonymous,
          isFalse,
        );
      },
    );
  });
}
