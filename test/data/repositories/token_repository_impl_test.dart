import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/data/repositories/token_repository_impl.dart';
import 'package:sec/domain/repositories/token_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenRepository tokenRepository;

  const MethodChannel channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<SecureInfo>(SecureInfo());
    tokenRepository = TokenRepositoryImpl();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('TokenRepositoryImpl', () {
    test('isTokenSaved returns true when token is stored', () async {
      // Arrange
      final githubData = GithubData(token: 'test_token');
      final githubDataJson = jsonEncode(githubData.toJson());
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read' &&
            methodCall.arguments['key'] == 'github_service') {
          return githubDataJson;
        }
        return null;
      });

      // Act
      final result = await tokenRepository.isTokenSaved();

      // Assert
      expect(result, isTrue);
    });

    test('isTokenSaved returns false when token is not stored', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read' &&
            methodCall.arguments['key'] == 'github_service') {
          return null;
        }
        return null;
      });

      // Act
      final result = await tokenRepository.isTokenSaved();

      // Assert
      expect(result, isFalse);
    });

    test('isTokenSaved returns false when token is empty', () async {
      // Arrange
      final githubData = GithubData(token: '');
      final githubDataJson = jsonEncode(githubData.toJson());
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read' &&
            methodCall.arguments['key'] == 'github_service') {
          return githubDataJson;
        }
        return null;
      });

      // Act
      final result = await tokenRepository.isTokenSaved();

      // Assert
      expect(result, isFalse);
    });

    test('isTokenSaved returns false when storage throws an exception',
        () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'error', message: 'Read failed');
      });

      // Act
      final result = await tokenRepository.isTokenSaved();

      // Assert
      expect(result, isFalse);
    });
  });
}
