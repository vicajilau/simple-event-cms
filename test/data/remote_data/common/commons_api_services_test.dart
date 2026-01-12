import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
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
  late SecureInfo secureInfo;
  late MockConfig mockConfig;
  late GithubData mockGithubData;
  late MockGitHub mockGitHub = MockGitHub();
  late MockClient mockHttpClient;
  late MockRepositoriesService mockRepositoriesService;
  late CommonsServicesImp commonsServices;
  late github_sdk.GitHubFile repoContentsFile;
  late github_sdk.RepositoryContents repoContent;

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
    secureInfo = SecureInfo();
    mockGithubData = GithubData(token: "fake_token", projectName: "test_repo");
    mockConfig = MockConfig();
    mockRepositoriesService = MockRepositoriesService();
    repoContent = MockRepositoryContents();
    repoContentsFile = MockGitHubFile();
    when(repoContentsFile.content).thenReturn("");

    mockHttpClient = MockClient();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'read' &&
              methodCall.arguments['key'] == 'github_service') {
            return jsonEncode(mockGithubData.toJson());
          }
          return null;
        });

    getIt.registerSingleton<SecureInfo>(secureInfo);
    getIt.registerSingleton<Config>(mockConfig);

    when(mockConfig.githubUser).thenReturn('test_user');
    when(mockConfig.projectName).thenReturn('test_repo');
    when(mockConfig.branch).thenReturn('main');
    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);
    when(mockGitHub.client).thenReturn(mockHttpClient);
    when(repoContentsFile.sha).thenReturn("fake_sha");
    when(repoContent.file).thenReturn(repoContentsFile);

    final localJson = json.encode({
      'configName': 'Random Organization',
      'primaryColorOrganization': '#4285F4',
      'secondaryColorOrganization': '#4285F4',
      'github_user': 'remote_user',
      'project_name': 'remote_proj',
      'branch': 'prod',
      'eventForcedToViewUID': null,
    });
    final base64Content = base64.encode(utf8.encode(localJson));

    final mockContent = repoContentsFile..content = base64Content;
    final mockContents = repoContent..file = mockContent;
    when(
      mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
    ).thenAnswer((_) async => mockContents);
    when(
      mockHttpClient.put(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async => Response("{}", 200));

    secureInfo.saveGithubKey(mockGithubData);
    commonsServices = CommonsServicesImp();
    getIt.registerSingleton<github_sdk.GitHub>(mockGitHub);
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
        secureInfo.saveGithubKey(GithubData(token: null, projectName: ""));
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
      test('should throw an exception when sha is null', () async {
        final localJson = json.encode({
          'configName': 'Random Organization',
          'primaryColorOrganization': '#4285F4',
          'secondaryColorOrganization': '#4285F4',
          'github_user': 'remote_user',
          'project_name': 'remote_proj',
          'branch': 'prod',
          'eventForcedToViewUID': null,
        });
        final base64Content = base64.encode(utf8.encode(localJson));

        final mockContent = repoContentsFile..content = base64Content;
        mockContent.sha = null;

        final mockContents = repoContent..file = mockContent;
        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenAnswer((_) async => mockContents);
        when(mockContents.file?.sha).thenReturn(null);
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

        expect(
          () => commonsServices.updateData(
            originalData,
            data,
            testPath,
            commitMessage,
          ),
          throwsA(isA<GithubException>()),
        );
      });
      test(
        'should throw an exception when github.repositories.getContents thows a gitHubError & you cant create the file in github',
        () async {
          when(
            mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
          ).thenThrow(github_sdk.GitHubError(mockGitHub, "Not Found"));
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
            () => commonsServices.updateData(
              originalData,
              data,
              testPath,
              commitMessage,
            ),
            throwsA(isA<GithubException>()),
          );
        },
      );

      test(
        'should throw an exception when github.repositories.getContents thows a gitHubError but you can create the file in github',
        () async {
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          final mockSecureInfo = MockSecureInfo();
          getIt.unregister<SecureInfo>();
          getIt.registerSingleton<SecureInfo>(mockSecureInfo);

          when(
            mockSecureInfo.getGithubKey(),
          ).thenAnswer((_) async => mockGithubData);
          when(
            mockSecureInfo.getGithubItem(),
          ).thenAnswer((_) async => mockGitHub);

          final localJson = json.encode({
            'configName': 'Random Organization',
            'primaryColorOrganization': '#4285F4',
            'secondaryColorOrganization': '#4285F4',
            'github_user': 'remote_user',
            'project_name': 'remote_proj',
            'branch': 'prod',
            'eventForcedToViewUID': null,
          });
          final base64Content = base64.encode(utf8.encode(localJson));

          MockContentCreation contentCreation = MockContentCreation();
          MockGitHubFile mockGitHubFile = MockGitHubFile();
          when(mockGitHubFile.content).thenReturn(base64Content);
          when(contentCreation.content).thenReturn(mockGitHubFile);
          when(
            mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
          ).thenThrow(github_sdk.GitHubError(mockGitHub, "Not Found"));
          when(
            mockRepositoriesService.createFile(any, any),
          ).thenAnswer((_) async => contentCreation);
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
            () => commonsServices.updateData(
              originalData,
              data,
              testPath,
              commitMessage,
            ),
            returnsNormally,
          );
        },
      );

      test(
        'should throw an exception when github.repositories.getContents thows a gitHubError & you have a response.content null',
        () async {
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          final mockSecureInfo = MockSecureInfo();
          getIt.unregister<SecureInfo>();
          getIt.registerSingleton<SecureInfo>(mockSecureInfo);

          when(
            mockSecureInfo.getGithubKey(),
          ).thenAnswer((_) async => mockGithubData);
          when(
            mockSecureInfo.getGithubItem(),
          ).thenAnswer((_) async => mockGitHub);

          MockContentCreation contentCreation = MockContentCreation();
          when(contentCreation.content).thenReturn(null);
          when(
            mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
          ).thenThrow(github_sdk.GitHubError(mockGitHub, "Not Found"));
          when(
            mockRepositoriesService.createFile(any, any),
          ).thenAnswer((_) async => contentCreation);
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
            () => commonsServices.updateData(
              originalData,
              data,
              testPath,
              commitMessage,
            ),
            throwsA(isA<GithubException>()),
          );
        },
      );

      test(
        'should throw an exception when repoContentsFile.sha is null',
        () async {
          when(repoContentsFile.sha).thenReturn(null);
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
            () => commonsServices.updateData(
              originalData,
              data,
              testPath,
              commitMessage,
            ),
            throwsA(isA<GithubException>()),
          );
        },
      );
      test('updateData returns a different statuscode of 200', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => Response("{}", 400));
        expect(
          () => commonsServices.updateData(
            originalData,
            data,
            testPath,
            commitMessage,
          ),
          throwsA(isA<NetworkException>()),
        );
      });
      test('updateData works successfully', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

        expect(
          () => commonsServices.updateData(
            originalData,
            data,
            testPath,
            commitMessage,
          ),
          returnsNormally,
        );
      });
      test('updateData throws an exception when getToken() is null', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData = GithubData());
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

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
        secureInfo.saveGithubKey(GithubData(token: null, projectName: ""));
        expect(
          () => commonsServices.updateDataList(
            originalData,
            testPath,
            commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
      test('should throw an exception when sha is null', () async {
        final localJson = json.encode({
          'configName': 'Random Organization',
          'primaryColorOrganization': '#4285F4',
          'secondaryColorOrganization': '#4285F4',
          'github_user': 'remote_user',
          'project_name': 'remote_proj',
          'branch': 'prod',
          'eventForcedToViewUID': null,
        });
        final base64Content = base64.encode(utf8.encode(localJson));

        final mockContent = repoContentsFile..content = base64Content;
        mockContent.sha = null;

        final mockContents = repoContent..file = mockContent;
        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenAnswer((_) async => mockContents);
        when(mockContents.file?.sha).thenReturn(null);
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

        expect(
              () => commonsServices.updateDataList(
            originalData,
            testPath,
            commitMessage,
          ),
          throwsA(isA<GithubException>()),
        );
      });
      test(
        'should throw an exception when github.repositories.getContents thows a gitHubError & you cant create the file in github',
            () async {
          when(
            mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
          ).thenThrow(github_sdk.GitHubError(mockGitHub, "Not Found"));
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
                () => commonsServices.updateDataList(
              originalData,
              testPath,
              commitMessage,
            ),
            throwsA(isA<GithubException>()),
          );
        },
      );

      test(
        'should throw an exception when github.repositories.getContents thows a gitHubError but you can create the file in github',
            () async {
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          final mockSecureInfo = MockSecureInfo();
          getIt.unregister<SecureInfo>();
          getIt.registerSingleton<SecureInfo>(mockSecureInfo);

          when(
            mockSecureInfo.getGithubKey(),
          ).thenAnswer((_) async => mockGithubData);
          when(
            mockSecureInfo.getGithubItem(),
          ).thenAnswer((_) async => mockGitHub);

          final localJson = json.encode({
            'configName': 'Random Organization',
            'primaryColorOrganization': '#4285F4',
            'secondaryColorOrganization': '#4285F4',
            'github_user': 'remote_user',
            'project_name': 'remote_proj',
            'branch': 'prod',
            'eventForcedToViewUID': null,
          });
          final base64Content = base64.encode(utf8.encode(localJson));

          MockContentCreation contentCreation = MockContentCreation();
          MockGitHubFile mockGitHubFile = MockGitHubFile();
          when(mockGitHubFile.content).thenReturn(base64Content);
          when(contentCreation.content).thenReturn(mockGitHubFile);
          when(
            mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
          ).thenThrow(github_sdk.GitHubError(mockGitHub, "Not Found"));
          when(
            mockRepositoriesService.createFile(any, any),
          ).thenAnswer((_) async => contentCreation);
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
                () => commonsServices.updateDataList(
              originalData,
              testPath,
              commitMessage,
            ),
            returnsNormally,
          );
        },
      );

      test(
        'should throw an exception when github.repositories.getContents thows a gitHubError & you have a response.content null',
            () async {
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          final mockSecureInfo = MockSecureInfo();
          getIt.unregister<SecureInfo>();
          getIt.registerSingleton<SecureInfo>(mockSecureInfo);

          when(
            mockSecureInfo.getGithubKey(),
          ).thenAnswer((_) async => mockGithubData);
          when(
            mockSecureInfo.getGithubItem(),
          ).thenAnswer((_) async => mockGitHub);

          MockContentCreation contentCreation = MockContentCreation();
          when(contentCreation.content).thenReturn(null);
          when(
            mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
          ).thenThrow(github_sdk.GitHubError(mockGitHub, "Not Found"));
          when(
            mockRepositoriesService.createFile(any, any),
          ).thenAnswer((_) async => contentCreation);
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
                () => commonsServices.updateDataList(
              originalData,
              testPath,
              commitMessage,
            ),
            throwsA(isA<GithubException>()),
          );
        },
      );

      test(
        'should throw an exception when repoContentsFile.sha is null',
            () async {
          when(repoContentsFile.sha).thenReturn(null);
          secureInfo.saveGithubKey(
            GithubData(token: "fake_token", projectName: "test_project"),
          );
          expect(
                () => commonsServices.updateDataList(
              originalData,
              testPath,
              commitMessage,
            ),
            throwsA(isA<GithubException>()),
          );
        },
      );
      test('updateData returns a different statuscode of 200', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => Response("{}", 400));
        expect(
              () => commonsServices.updateDataList(
            originalData,
            testPath,
            commitMessage,
          ),
          throwsA(isA<NetworkException>()),
        );
      });
      test('should updateDataList successfully', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);
        expect(
          () async => await commonsServices.updateDataList(
            originalData,
            testPath,
            commitMessage,
          ),
          returnsNormally,
        );
      });
    });
    // [GROUP] updateSingleData
    group('updateSingleData', () {
      final data = MockGitHubModel('3');
      const commitMessage = 'Update data';
      test('should throw an exception when token is null', () async {
        secureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

        expect(
          () async => await commonsServices.updateSingleData(data, testPath, commitMessage),
          throwsA(isA<Exception>()),
        );
      });
      test('should updateSingleData works successfully', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

        expect(
          () => commonsServices.updateSingleData(data, testPath, commitMessage),
          returnsNormally,
        );
      });
    });
    // [GROUP] removeData
    group('removeData', () {
      final originalData = [MockGitHubModel('1'), MockGitHubModel('2')];
      final dataToRemove = MockGitHubModel('2');
      const commitMessage = 'Remove data';

      test('should throw an exception when token is null', () async {
        secureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

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
      test('should removeData successfully', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

        expect(
          () => commonsServices.removeData(
            originalData,
            dataToRemove,
            testPath,
            commitMessage,
          ),
          returnsNormally,
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
        secureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

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
      test('should removeDataList successfully', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

        expect(
          () => commonsServices.removeDataList(
            originalData.toList(),
            dataToRemove,
            testPath,
            commitMessage,
          ),
          returnsNormally,
        );
      });
    });
    // [GROUP] getGithubItem

    group('updateAllData', () {
      test('should throw an exception when token is null', () async {
        final fullDataModel = MockGithubJsonModel({'newData': 'is here'});
        const commitMessage = 'Update all data';
        secureInfo.saveGithubKey(GithubData(token: null, projectName: ""));

        expect(
          () => commonsServices.updateAllData(
            fullDataModel,
            testPath,
            commitMessage,
          ),
          throwsA(isA<Exception>()),
        );
      });
      test('should run updateAllData successfully', () async {
        secureInfo.saveGithubKey(
          GithubData(token: "fake_token", projectName: "test_project"),
        );
        final mockSecureInfo = MockSecureInfo();
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);

        when(
          mockSecureInfo.getGithubKey(),
        ).thenAnswer((_) async => mockGithubData);
        when(
          mockSecureInfo.getGithubItem(),
        ).thenAnswer((_) async => mockGitHub);

        final fullDataModel = MockGithubJsonModel({'newData': 'is here'});
        const commitMessage = 'Update all data';

        expect(
          () => commonsServices.updateAllData(
            fullDataModel,
            testPath,
            commitMessage,
          ),
          returnsNormally,
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
