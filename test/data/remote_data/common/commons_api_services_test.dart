import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart' as github_sdk;
import 'package:http/http.dart' as http;
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
  late MockSecureInfo mockSecureInfo;
  late MockConfig mockConfig;
  late MockGithubData mockGithubData;
  late MockGitHub mockGitHub = MockGitHub();
  late MockClient mockHttpClient;
  late MockRepositoriesService mockRepositoriesService;
  late CommonsServicesImp commonsServices;
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
  // Initial setup for all tests
  setUpAll(() {
    // Allow reassignments in the dependency injector for testing purposes
    getIt.allowReassignment = true;
  });

  // Setup before each test
  setUp(() {
    // Instantiate mocks
    mockSecureInfo = MockSecureInfo();
    mockConfig = MockConfig();
    mockGithubData = MockGithubData();
    mockRepositoriesService = MockRepositoriesService();
    mockHttpClient = MockClient();

    getIt.registerSingleton<SecureInfo>(mockSecureInfo);
    getIt.registerSingleton<Config>(mockConfig);

    when(mockConfig.githubUser).thenReturn('test_user');
    when(mockConfig.projectName).thenReturn('test_repo');
    when(mockConfig.branch).thenReturn('main');
    when(mockGithubData.getProjectName()).thenReturn('test_repo');
    when(mockGithubData.getToken()).thenReturn('fake_token');
    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);
    when(mockGitHub.client).thenReturn(mockHttpClient);

    when(mockSecureInfo.getGithubKey()).thenAnswer((_) async => mockGithubData);
    when(mockSecureInfo.getGithubItem()).thenAnswer((_) async => mockGitHub);

    commonsServices = CommonsServicesImp();
  });

  tearDown(() {
    getIt.reset();
  });

  group('CommonsServicesImp', () {
    const testPath = 'data.json';
    final repoSlug = github_sdk.RepositorySlug('test_user', 'test_repo');

    // --- Mock Helpers ---
    github_sdk.GitHubFile createMockGitFile(String content, [String? sha]) {
      final file = github_sdk.GitHubFile();
      file.content = content.replaceAll('\n', '');
      file.sha = sha;
      return file;
    }

    github_sdk.RepositoryContents createMockRepoContents(
      String content, [
      String? sha,
    ]) {
      final contents = github_sdk.RepositoryContents();
      contents.file = createMockGitFile(content, sha);
      return contents;
    }

    // --- Tests ---

    // [GROUP] updateData
    group('updateData', () {
      final originalData = [MockGitHubModel('1'), MockGitHubModel('2')];
      final data = MockGitHubModel('3');
      const commitMessage = 'Update data';
      test('should throw an exception when token is null', () async {
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(token: null, projectName: ""));
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
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(token: null, projectName: ""));
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
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(token: null, projectName: ""));
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
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(token: null, projectName: ""));
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

      test('should retry on a 409 conflict', () async {
        // Arrange: Simulate a 409 failure on the first attempt and success on the second
        final repoContents = createMockRepoContents('old_content', 'fake_sha');
        when(
          mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'),
        ).thenAnswer((_) async => repoContents);

        // Fails the first time
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('conflict', 409));

        // Act & Assert: The method should call updateDataList internally,
        // which we can also mock or simply verify the retry.
        // Here we simplify by expecting the maximum retries exception.
        await expectLater(
          commonsServices.removeData(
            originalData,
            dataToRemove,
            testPath,
            commitMessage,
          ),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.toString(),
              'message',
              contains('multiple retries'),
            ),
          ),
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
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(token: null, projectName: ""));
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
      test('should remove a list of items and update the file', () async {
        // Arrange
        final repoContents = createMockRepoContents('old_content', 'fake_sha');
        when(
          mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'),
        ).thenAnswer((_) async => repoContents);

        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await commonsServices.removeDataList(
          originalData.toList(),
          dataToRemove,
          testPath,
          commitMessage,
        );

        // Assert
        final capturedBody = verify(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: captureAnyNamed('body'),
          ),
        ).captured.single;
        final decodedBody = json.decode(capturedBody);
        final content = utf8.decode(base64.decode(decodedBody['content']));

        expect(content.contains('"id": "1"'), isTrue);
        expect(content.contains('"id": "2"'), isFalse);
        expect(content.contains('"id": "3"'), isFalse);
      });
    });
// [GROUP] getGithubItem

    group('updateAllData', () {
      test('should throw an exception when token is null', () async {
        final fullDataModel = MockGithubJsonModel({'newData': 'is here'});
        const commitMessage = 'Update all data';
        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => GithubData(token: null, projectName: ""));
        expect(
              () => commonsServices.updateAllData(
                fullDataModel,
                testPath,
                commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
      test('should replace the entire content of the file', () async {
        // Arrange
        final fullDataModel = MockGithubJsonModel({'newData': 'is here'});
        const commitMessage = 'Update all data';

        final repoContents = createMockRepoContents('old_content', 'fake_sha');
        when(
          mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'),
        ).thenAnswer((_) async => repoContents);

        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await commonsServices.updateAllData(
          fullDataModel,
          testPath,
          commitMessage,
        );

        // Assert
        final capturedBody = verify(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: captureAnyNamed('body'),
          ),
        ).captured.single;
        final decodedBody = json.decode(capturedBody);
        final content = utf8.decode(base64.decode(decodedBody['content']));

        expect(content, contains('"newData": "is here"'));
      });
    });

    group('CommonsServicesImp - loadData', () {
      const testPath = 'data.json';
      const fullPath = 'events/$testPath';
      final repoSlug = github_sdk.RepositorySlug('test_user', 'test_repo');

      // Helper function to create a mock GitHubFile
      github_sdk.GitHubFile createMockGitFile(String content) {
        final file = github_sdk.GitHubFile();
        // Encode the content to Base64, simulating the GitHub API response
        file.content = base64.encode(utf8.encode(content));
        return file;
      }

      // Helper function to create a mock RepositoryContents
      github_sdk.RepositoryContents createMockRepoContents(String content) {
        final contents = github_sdk.RepositoryContents();
        contents.file = createMockGitFile(content);
        return contents;
      }

      test('should return decoded JSON map on successful data fetch', () async {
        // Arrange: Setup mock to return valid file content
        final jsonData = {'key': 'value', 'number': 123};
        final repoContents = createMockRepoContents(json.encode(jsonData));

        when(
          mockRepositoriesService.getContents(repoSlug, fullPath, ref: 'main'),
        ).thenAnswer((_) async => repoContents);

        // Act: Call the method under test
        final result = await commonsServices.loadData(testPath);

        // Assert: Verify the result is the expected decoded map
        expect(result, equals(jsonData));
        verify(
          mockRepositoriesService.getContents(repoSlug, fullPath, ref: 'main'),
        ).called(1);
      });

      test(
        'should return an empty map when GitHub returns a 404 "Not Found" error',
        () async {
          // Arrange: Setup mock to throw a NotFound error
          when(
            mockRepositoriesService.getContents(
              repoSlug,
              fullPath,
              ref: 'main',
            ),
          ).thenThrow(github_sdk.NotFound(mockGitHub, 'Not Found'));

          // Act: Call the method under test
          final result = await commonsServices.loadData(testPath);

          // Assert: Verify the result is an empty map
          expect(result, equals(<String, dynamic>{}));
        },
      );

      test('should throw NetworkException on RateLimitHit', () async {
        // Arrange: Setup mock to throw a RateLimitHit error
        when(
          mockRepositoriesService.getContents(repoSlug, fullPath, ref: 'main'),
        ).thenThrow(github_sdk.RateLimitHit(mockGitHub));

        // Act & Assert: Verify that the correct exception is thrown
        expect(
          () => commonsServices.loadData(testPath),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('GitHub API rate limit exceeded'),
            ),
          ),
        );
      });

      test('should throw NetworkException on InvalidJSON', () async {
        // Arrange: Setup mock to throw an InvalidJSON error
        when(
          mockRepositoriesService.getContents(repoSlug, fullPath, ref: 'main'),
        ).thenThrow(github_sdk.InvalidJSON(mockGitHub, 'Bad JSON'));

        // Act & Assert: Verify that the correct exception is thrown
        expect(
          () => commonsServices.loadData(testPath),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('Invalid JSON received from GitHub'),
            ),
          ),
        );
      });

      test('should throw NetworkException for a generic GitHubError', () async {
        // Arrange: Setup mock to throw a generic GitHubError
        when(
          mockRepositoriesService.getContents(repoSlug, fullPath, ref: 'main'),
        ).thenThrow(github_sdk.GitHubError(mockGitHub, 'Some other error'));

        // Act & Assert: Verify that the correct exception is thrown
        expect(
          () => commonsServices.loadData(testPath),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('An unknown GitHub error occurred'),
            ),
          ),
        );
      });

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

      test(
        'should throw JsonDecodeException if content is not valid JSON',
        () async {
          // Arrange: Setup mock to return a file with invalid JSON content
          const invalidJsonContent = 'this is not json';
          final repoContents = createMockRepoContents(invalidJsonContent);
          when(
            mockRepositoriesService.getContents(
              repoSlug,
              fullPath,
              ref: 'main',
            ),
          ).thenAnswer((_) async => repoContents);

          // Act & Assert: Verify that a JsonDecodeException is thrown
          expect(
            () => commonsServices.loadData(testPath),
            throwsA(isA<JsonDecodeException>()),
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
