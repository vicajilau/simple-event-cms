import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart' as github_sdk;
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/config.dart';
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
  late MockSecureInfo mockSecureInfo;
  late MockConfig mockConfig;
  late MockGithubData mockGithubData;
  late MockGitHub mockGitHub;
  late MockRepositoriesService mockRepositoriesService;
  late MockClient mockHttpClient;
  late CommonsServicesImp commonsServices;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockSecureInfo = MockSecureInfo();
    mockConfig = MockConfig();
    mockGithubData = MockGithubData();
    mockGitHub = MockGitHub();
    mockRepositoriesService = MockRepositoriesService();
    mockHttpClient = MockClient();

    getIt.registerSingleton<SecureInfo>(mockSecureInfo);
    getIt.registerSingleton<Config>(mockConfig);

    when(mockConfig.githubUser).thenReturn('test_user');
    when(mockConfig.projectName).thenReturn('test_repo');
    when(mockConfig.branch).thenReturn('main');
    when(mockGithubData.projectName).thenReturn('test_repo');
    when(mockGithubData.token).thenReturn('fake_token');
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
      final file =  github_sdk.GitHubFile();
      file.content = content.replaceAll('\n', '');
      file.sha = sha;
      return file;
    }

    github_sdk.RepositoryContents createMockRepoContents(String content, [String? sha]) {
      final contents = github_sdk.RepositoryContents();
      contents.file = createMockGitFile(content, sha);
      return contents;
    }

    // --- Tests ---

    // [GROUP] removeData
    group('removeData', () {
      final originalData = [MockGitHubModel('1'), MockGitHubModel('2')];
      final dataToRemove = MockGitHubModel('2');
      const commitMessage = 'Remove data';


      test('should throw GithubException if the file does not exist', () async {
        // Arrange
        when(mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'))
            .thenThrow(github_sdk.NotFound(mockGitHub, 'Not Found'));

        // Act & Assert
        expect(
                () => commonsServices.removeData(
                originalData, dataToRemove, testPath, commitMessage),
            throwsA(isA<GithubException>()));
      });

      test('should retry on a 409 conflict', () async {
        // Arrange: Simulate a 409 failure on the first attempt and success on the second
        final repoContents = createMockRepoContents('old_content', 'fake_sha');
        when(mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'))
            .thenAnswer((_) async => repoContents);

        // Fails the first time
        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('conflict', 409));

        // Act & Assert: The method should call updateDataList internally,
        // which we can also mock or simply verify the retry.
        // Here we simplify by expecting the maximum retries exception.
        await expectLater(
            commonsServices.removeData(originalData, dataToRemove, testPath, commitMessage),
            throwsA(isA<NetworkException>().having((e) => e.toString(), 'message', contains('multiple retries')))
        );
      });
    });

    group('removeDataList', () {
      final originalData = [MockGitHubModel('1'), MockGitHubModel('2'), MockGitHubModel('3')];
      final dataToRemove = [MockGitHubModel('2'), MockGitHubModel('3')];
      const commitMessage = 'Remove data list';

      test('should remove a list of items and update the file', () async {
        // Arrange
        final repoContents = createMockRepoContents('old_content', 'fake_sha');
        when(mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'))
            .thenAnswer((_) async => repoContents);

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await commonsServices.removeDataList(originalData.toList(), dataToRemove, testPath, commitMessage);

        // Assert
        final capturedBody = verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: captureAnyNamed('body'))).captured.single;
        final decodedBody = json.decode(capturedBody);
        final content = utf8.decode(base64.decode(decodedBody['content']));

        // The bug in removeDataList causes this to fail, but the test is correct.
        // It's expected that only '1' remains, but the bug keeps '2' and '3'.
        // When you fix the bug, this test will pass.
        expect(content.contains('"id": "1"'), isTrue);
        expect(content.contains('"id": "2"'), isFalse);
        expect(content.contains('"id": "3"'), isFalse);
      });
    });

    group('updateAllData', () {
      test('should replace the entire content of the file', () async {
        // Arrange
        final fullDataModel = MockGithubJsonModel({'newData': 'is here'});
        const commitMessage = 'Update all data';

        final repoContents = createMockRepoContents('old_content', 'fake_sha');
        when(mockRepositoriesService.getContents(repoSlug, testPath, ref: 'main'))
            .thenAnswer((_) async => repoContents);

        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await commonsServices.updateAllData(fullDataModel, testPath, commitMessage);

        // Assert
        final capturedBody = verify(mockHttpClient.put(any, headers: anyNamed('headers'), body: captureAnyNamed('body'))).captured.single;
        final decodedBody = json.decode(capturedBody);
        final content = utf8.decode(base64.decode(decodedBody['content']));

        expect(content, contains('"newData": "is here"'));
      });
    });
  });
}
