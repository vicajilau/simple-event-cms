import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart' as gh;
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/github/github_model.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';

import '../../../mocks.mocks.dart';

// Simple model for use in tests
class CommonsApiServicesTest extends GitHubModel {
  final String name;

  CommonsApiServicesTest({
    required super.uid,
    required this.name,
    required super.pathUrl,
    required super.updateMessage,
  });

  @override
  Map<String, dynamic> toJson() => {'uid': uid, 'name': name};

  factory CommonsApiServicesTest.fromJson(Map<String, dynamic> json) {
    return CommonsApiServicesTest(
      uid: json['uid'],
      name: json['name'],
      pathUrl: '',
      updateMessage: '',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // MOCKS Y VARIABLES
  WidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  // Instances of mocks and the class to be tested
  late MockGitHub mockGitHub;
  late MockRepositoriesService mockRepositoriesService;
  late CommonsServices commonsServices;
  late MockConfig mockConfig;

  // Configuration data for tests
  const String testUser = 'test_user';
  const String testRepo = 'test_repo';
  const String testBranch = 'main';
  const String testPath = 'data.json';
  final repoSlug = gh.RepositorySlug(testUser, testRepo);
  setUpAll(() async {
    // Initialize mocks
    mockGitHub = MockGitHub();
    mockRepositoriesService = MockRepositoriesService();
    mockConfig = MockConfig();

    // Configura el comportamiento por defecto de los mocks
    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);
    when(mockConfig.githubUser).thenReturn(testUser);
    when(mockConfig.projectName).thenReturn(testRepo);
    when(mockConfig.branch).thenReturn(testBranch);
    when(
      mockGitHub.repositories.getContents,
    ).thenAnswer((_) => mockRepositoriesService.getContents);

    // Set up dependency injection for tests
    await getIt.reset();
    getIt.registerSingleton<Config>(mockConfig);
    getIt.registerSingleton<SecureInfo>(SecureInfo());
    // Register the GitHub mock as a factory so it can be overridden in tests if necessary
    getIt.registerFactory<gh.GitHub>(() => mockGitHub);

    // SecureInfo is a class with static methods, it cannot be mocked directly,
    // so we mock its expected behavior as if it were an injectable dependency.
    // For the real code, we ensure that SecureInfo returns the necessary data.
    // In this test, we assume that SecureInfo.getGithubKey() will work as expected.
    // For a more robust solution, SecureInfo should not have static methods.
    // For simplicity, we proceed here assuming we can control the configuration.

    commonsServices = CommonsServicesImp();
    final githubData = GithubData(token: 'test_token');
    final githubDataJson = jsonEncode(githubData.toJson());
    // Mock Secure Storage
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'read') {
            return githubDataJson;
          }
          return null;
        });
  });

  group('loadData', () {
    test('should throw NetworkException if the file content is null', () async {
      when(
        mockRepositoriesService.getContents(
          repoSlug,
          'events/$testPath',
          ref: testBranch,
        ),
      ).thenAnswer((_) async => MockRepositoryContents());

      // Act & Assert
      expect(
        () => commonsServices.loadData(testPath),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('updateData', () {
    final modelToUpdate = CommonsApiServicesTest(
      uid: '1',
      name: 'Updated Name',
      pathUrl: '',
      updateMessage: '',
    );
    final originalList = [
      CommonsApiServicesTest(
        uid: '1',
        name: 'Original Name',
        pathUrl: '',
        updateMessage: '',
      ),
    ];
    final commitMessage = 'feat: update test model';

    test('should throw GithubException if getting the SHA fails', () async {
      // Arrange
      when(
        mockRepositoriesService.getContents(
          repoSlug,
          testPath,
          ref: testBranch,
        ),
      ).thenThrow(Exception("Generic Error"));

      // Act & Assert
      expect(
        () => commonsServices.updateData(
          originalList,
          modelToUpdate,
          testPath,
          commitMessage,
        ),
        throwsA(isA<GithubException>()),
      );
    });
  });
}
