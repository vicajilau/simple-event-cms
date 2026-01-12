import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:github/github.dart';
import 'package:sec/core/config/config_loader.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/core/di/dependency_injection.dart';

// Generar mocks para las dependencias externas
import '../../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSecureInfo mockSecureInfo;
  late MockCheckOrg mockCheckOrg;
  late MockGitHub mockGitHub;
  late MockRepositoriesService mockRepositoriesService;

  setUp(() async {
    mockSecureInfo = MockSecureInfo();
    mockCheckOrg = MockCheckOrg();
    mockGitHub = MockGitHub();
    mockRepositoriesService = MockRepositoriesService();

    // Reset GetIt and register mocks
    getIt.registerSingleton<SecureInfo>(mockSecureInfo);
    getIt.registerSingleton<CheckOrg>(mockCheckOrg);

    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    getIt.reset();
  });

  group('ConfigLoader - getLocalOrganization', () {
    test('should return Config when rootBundle loads successfully', () async {
      // --- MOCKING ROOTBUNDLE ---
      final mockConfigData = {
        'configName': 'Random Organization',
        'primaryColorOrganization': '#4285F4',
        'secondaryColorOrganization': '#4285F4',
        'github_user': 'test_user',
        'project_name': 'simple-event-cms',
        'branch': 'main',
        'eventForcedToViewUID': null,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final Uint8List encoded = utf8.encoder.convert(
              json.encode(mockConfigData),
            );
            return encoded.buffer.asByteData();
          });

      final result = await ConfigLoader.getLocalOrganization();

      expect(result.githubUser, 'test_user');
      expect(result.branch, 'main');
    });
  });

  group('ConfigLoader - loadOrganization', () {
    test(
      'should return remote config and set error to false on success',
      () async {
        rootBundle.clear();
        // 1. Mock Local Bundle
        final localJson = json.encode({
          'configName': 'Random Organization',
          'primaryColorOrganization': '#4285F4',
          'secondaryColorOrganization': '#4285F4',
          'github_user': 'remote_user',
          'project_name': 'remote_proj',
          'branch': 'prod',
          'eventForcedToViewUID': null,
        });
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              return utf8.encoder.convert(localJson).buffer.asByteData();
            });

        // 2. Mock Secure Storage & GitHub
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(projectName: 'remote_proj'));

        final base64Content = base64.encode(utf8.encode(localJson));

        final mockContent = GitHubFile()..content = base64Content;
        final mockContents = RepositoryContents()..file = mockContent;

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenAnswer((_) async => mockContents);

        // Act
        final result = await ConfigLoader.loadOrganization();

        // Assert
        expect(result.githubUser, 'remote_user');
        verify(mockCheckOrg.setError(false)).called(1);
      },
    );
    test(
      'should return remote config and set error to false  with res.file == null',
      () async {
        rootBundle.clear();
        // 1. Mock Local Bundle
        final localJson = json.encode({
          'configName': 'Random Organization',
          'primaryColorOrganization': '#4285F4',
          'secondaryColorOrganization': '#4285F4',
          'github_user': 'remote_user',
          'project_name': 'remote_proj',
          'branch': 'prod',
          'eventForcedToViewUID': null,
        });
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              return utf8.encoder.convert(localJson).buffer.asByteData();
            });

        // 2. Mock Secure Storage & GitHub
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(projectName: 'remote_proj'));


        final mockContents = RepositoryContents()..file = null;

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenAnswer((_) async => mockContents);

        // Assert
        verify(mockCheckOrg.setError(true)).called(1);
      },
    );
    test(
      'should return remote config and set error to false on success when githubItem is null',
      () async {
        rootBundle.clear();
        // 1. Mock Local Bundle
        final localJson = json.encode({
          'configName': 'Random Organization',
          'primaryColorOrganization': '#4285F4',
          'secondaryColorOrganization': '#4285F4',
          'github_user': 'remote_user',
          'project_name': 'remote_proj',
          'branch': 'prod',
          'eventForcedToViewUID': null,
        });
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              return utf8.encoder.convert(localJson).buffer.asByteData();
            });

        // 2. Mock Secure Storage & GitHub
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData());

        final base64Content = base64.encode(utf8.encode(localJson));

        final mockContent = GitHubFile()..content = base64Content;
        final mockContents = RepositoryContents()..file = mockContent;

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenAnswer((_) async => mockContents);

        // Act
        final result = await ConfigLoader.loadOrganization();

        // Assert
        expect(result.githubUser, 'remote_user');
        verify(mockCheckOrg.setError(false)).called(1);
      },
    );
    test(
      'should return remote config with local error if remote fails',
      () async {
        rootBundle.clear();
        // 1. Mock Local Bundle
        final localJson = json.encode({
          'configName': 'Random Organization',
          'primaryColorOrganization': '#4285F4',
          'secondaryColorOrganization': '#4285F4',
          'github_user': '',
          'project_name': '',
          'branch': 'prod',
          'eventForcedToViewUID': null,
        });
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              return utf8.encoder.convert(localJson).buffer.asByteData();
            });

        final result = await ConfigLoader.loadOrganization();

        // Assert
        expect(result.githubUser, '');
        verify(mockCheckOrg.setError(true)).called(1);
      },
    );
  });
}
