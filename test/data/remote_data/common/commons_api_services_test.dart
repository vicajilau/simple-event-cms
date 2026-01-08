import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart' as github_sdk;
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/github/github_model.dart';
import 'package:sec/core/models/github_json_model.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';

// Import the generated mocks
import '../../../mocks.mocks.dart';

// Mock class for GitHubModel
class MockGitHubModel extends GitHubModel {
  final String id;
  final String name;

  // Corrected constructor
  MockGitHubModel(this.id, {this.name = 'Mock'})
    : super(uid: id, pathUrl: 'mock/path', updateMessage: 'mock update');

  @override
  String get uid => id;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': '$name $id'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockGitHubModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Mock class for GithubJsonModel
class MockGithubJsonModel extends GithubJsonModel {
  final Map<String, dynamic> _data;
  MockGithubJsonModel(this._data);

  @override
  Map<String, dynamic> toJson() => _data;
}

void main() {
  // Declare mock variables
  late SecureInfo mockSecureInfo;
  late MockConfig mockConfig;
  late GithubData mockGithubData;
  late MockGitHub mockGitHub = MockGitHub();
  late MockClient mockHttpClient;
  late MockRepositoriesService mockRepositoriesService;
  late CommonsServicesImp commonsServices;
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  // Initial setup for all tests
  setUpAll(() {
    // Allow reassignments in the dependency injector for testing purposes
    getIt.allowReassignment = true;
  });

  // Setup before each test
  setUp(() async {
    // Instantiate mocks
    mockSecureInfo = SecureInfo();
    mockGithubData = GithubData(token: "fake_token", projectName: "test_repo");
    mockConfig = MockConfig();
    mockRepositoriesService = MockRepositoriesService();
    mockHttpClient = MockClient();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'read' &&
              methodCall.arguments['key'] == 'github_service') {
            return jsonEncode(mockGithubData.toJson());
          }
          return null;
        });

    getIt.registerSingleton<SecureInfo>(mockSecureInfo);
    getIt.registerSingleton<Config>(mockConfig);

    when(mockConfig.githubUser).thenReturn('test_user');
    when(mockConfig.projectName).thenReturn('test_repo');
    when(mockConfig.branch).thenReturn('main');
    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);
    when(mockGitHub.client).thenReturn(mockHttpClient);

    mockSecureInfo.saveGithubKey(mockGithubData);
    commonsServices = CommonsServicesImp();
  });

  tearDown(() {
    getIt.reset();
  });

  group('CommonsServicesImp', () {
    const testPath = 'data.json';
    final repoSlug = github_sdk.RepositorySlug('test_user', 'test_repo');

    // --- Tests ---

    // [GROUP] updateData
    group('updateData', () {
      final originalData = [MockGitHubModel('1'), MockGitHubModel('2')];
      final data = MockGitHubModel('3');
      const commitMessage = 'Update data';
      test('should throw an exception when token is null', () async {
        mockSecureInfo.saveGithubKey(GithubData(token: null, projectName: ""));
        expect(
          () => commonsServices.updateData(
            originalData,
            data,
            testPath,
            commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
    // [GROUP] updateDataList
    group('updateDataList', () {
      final originalData = [MockGitHubModel('1'), MockGitHubModel('2')];
      const commitMessage = 'Update data';
      test('should throw an exception when token is null', () async {
        mockSecureInfo.saveGithubKey(GithubData(token: null, projectName: ""));
        expect(
          () => commonsServices.updateDataList(
            originalData,
            testPath,
            commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
    // [GROUP] updateSingleData
    group('updateSingleData', () {
      final data = MockGitHubModel('3');
      const commitMessage = 'Update data';
      test('should throw an exception when token is null', () async {
        mockSecureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

        expect(
          () => commonsServices.updateSingleData(data, testPath, commitMessage),
          throwsA(isA<Exception>()),
        );
      });
    });
    // [GROUP] removeData
    group('removeData', () {
      final originalData = [MockGitHubModel('1'), MockGitHubModel('2')];
      final dataToRemove = MockGitHubModel('2');
      const commitMessage = 'Remove data';

      test('should throw an exception when token is null', () async {
        mockSecureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

        expect(
          () => commonsServices.removeData(
            originalData,
            dataToRemove,
            testPath,
            commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
      test('should throw GithubException if the file does not exist', () async {
        // Arrange
        when(
          mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'),
        ).thenThrow(github_sdk.NotFound(mockGitHub, 'Not Found'));

        // Act & Assert
        expect(
          () => commonsServices.removeData(
            originalData,
            dataToRemove,
            testPath,
            commitMessage,
          ),
          throwsA(isA<GithubException>()),
        );
      });
    });

    group('removeDataList', () {
      final originalData = [
        MockGitHubModel('1'),
        MockGitHubModel('2'),
        MockGitHubModel('3'),
      ];
      final dataToRemove = [MockGitHubModel('2'), MockGitHubModel('3')];
      const commitMessage = 'Remove data list';

      test('should throw an exception when token is null', () async {
        mockSecureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

        expect(
          () => commonsServices.removeDataList(
            originalData.toList(),
            dataToRemove,
            testPath,
            commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
    // [GROUP] getGithubItem

    group('updateAllData', () {
      test('should throw an exception when token is null', () async {
        final fullDataModel = MockGithubJsonModel({'newData': 'is here'});
        const commitMessage = 'Update all data';
        mockSecureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

        expect(
          () => commonsServices.updateAllData(
            fullDataModel,
            testPath,
            commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('CommonsServicesImp - loadData', () {
      const testPath = 'data.json';
      const fullPath = 'events/$testPath';
      final repoSlug = github_sdk.RepositorySlug('test_user', 'test_repo');


      // Dynamically create a test for each specific exception type
      final exceptionMap = {
        'RepositoryNotFound': github_sdk.RepositoryNotFound(mockGitHub, ''),
        'UserNotFound': github_sdk.UserNotFound(mockGitHub, ''),
        'OrganizationNotFound': github_sdk.OrganizationNotFound(mockGitHub, ''),
        'TeamNotFound': github_sdk.TeamNotFound(mockGitHub, 0),
        'AccessForbidden': github_sdk.AccessForbidden(mockGitHub),
        'NotReady': github_sdk.NotReady(mockGitHub, ""),
      };

      exceptionMap.forEach((name, exception) {
        test('should throw NetworkException for $name', () {
          // Arrange
          when(
            mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => commonsServices.loadData(testPath),
            throwsA(isA<NetworkException>()),
          );
        });
      });

      test(
        'should throw NetworkException for an unknown generic exception',
        () async {
          // Arrange: Setup mock to throw a standard Exception
          when(
            mockRepositoriesService.getContents(
              repoSlug,
              fullPath,
              ref: 'main',
            ),
          ).thenThrow(Exception('A very generic error'));

          // Act & Assert: Verify that the catch-all NetworkException is thrown
          expect(
            () => commonsServices.loadData(testPath),
            throwsA(
              isA<NetworkException>().having(
                (e) => e.message,
                'message',
                contains('Error fetching data'),
              ),
            ),
          );
        },
      );

      test(
        'should throw NetworkException if RepositoryContents.file is null',
        () async {
          // Arrange: Setup mock to return contents with a null file
          final repoContents =
              github_sdk.RepositoryContents(); // file is null by default
          when(
            mockRepositoriesService.getContents(
              repoSlug,
              fullPath,
              ref: 'main',
            ),
          ).thenAnswer((_) async => repoContents);

          // Act & Assert: Verify the correct exception is thrown
          expect(
            () => commonsServices.loadData(testPath),
            throwsA(
              isA<NetworkException>().having(
                (e) => e.message,
                'message',
                contains('Error fetching data'),
              ),
            ),
          );
        },
      );

      test(
        'should throw NetworkException if GitHubFile.content is null',
        () async {
          // Arrange: Setup mock to return a file with null content
          final repoContents = github_sdk.RepositoryContents();
          repoContents.file =
              github_sdk.GitHubFile(); // content is null by default
          when(
            mockRepositoriesService.getContents(
              repoSlug,
              fullPath,
              ref: 'main',
            ),
          ).thenAnswer((_) async => repoContents);

          // Act & Assert: Verify the correct exception is thrown
          expect(
            () => commonsServices.loadData(testPath),
            throwsA(
              isA<NetworkException>().having(
                (e) => e.message,
                'message',
                contains('Error fetching data'),
              ),
            ),
          );
        },
      );

      /*test('should return an empty map if content is empty (results in "No element" error)', () async {
        // Arrange: Setup mock to return an empty string, which causes json.decode to fail
        const emptyContent = '';
        final repoContents = createMockRepoContents(emptyContent);
        when(mockRepositoriesService.getContents(repoSlug, fullPath, ref: 'main'))
            .thenAnswer((_) async => repoContents);

        // Act: Call the method
        final result = await commonsServices.loadData(testPath);

        // Assert: Verify the result is an empty map
        expect(result, <String, dynamic>{});
      });*/
    });
  });
}
