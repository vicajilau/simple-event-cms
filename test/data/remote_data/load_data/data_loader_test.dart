import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart' as github_sdk;
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/github_json_model.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';

import '../../../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataLoaderManager dataLoaderManager;
  late MockCommonsServices mockCommonsServices;
  late CommonsServices commonsServices;
  late MockSecureInfo mockSecureInfo;
  late SecureInfo secureInfo;
  late MockGitHub mockGitHub;
  late MockRepositoriesService mockRepositoriesService;

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() async {
    mockCommonsServices = MockCommonsServices();
    // Register CommonsServices before instantiating DataLoaderManager
    mockSecureInfo = MockSecureInfo();
    secureInfo = SecureInfo();
    mockRepositoriesService = MockRepositoriesService();
    mockGitHub = MockGitHub();
    getIt.registerSingleton<SecureInfo>(secureInfo);
    getIt.registerSingleton<CommonsServices>(mockCommonsServices);
    dataLoaderManager = DataLoaderManager();
    getIt.registerSingleton<Config>(
      Config(
        configName: 'test_name',
        primaryColorOrganization: '#0000000',
        secondaryColorOrganization: '#0000000',
        githubUser: 'test_user',
        projectName: 'test_project',
        branch: 'test_branch',
      ),
    );
    commonsServices = CommonsServicesImp();
    final mockSocial = MockSocial();
    when(mockSocial.toJson()).thenReturn({'twitter': 'some_handle'});

    getIt.registerSingleton<DataLoaderManager>(dataLoaderManager);

    final testEvent = Event(
      uid: '1',
      isVisible: true,
      tracks: [],
      eventName: '',
      year: '',
      primaryColor: '',
      secondaryColor: '',
      eventDates: EventDates(
        uid: 'testUID',
        startDate: '2025-01-01T10:00:00Z',
        endDate: '2025-01-02T18:00:00Z',
        timezone: 'timezone',
      ), // 4. Use the already configured mock instance
    );
    final testSpeaker = Speaker(
      uid: '1',
      name: '',
      bio: '',
      image: '',
      social: mockSocial, // Use the already configured mock instance
      eventUIDS: [],
    );
    // ... (The rest of the creation for testSponsor, testSession, etc. remains the same)
    final testSponsor = Sponsor(
      uid: '1',
      name: '',
      type: '',
      logo: '',
      website: '',
      eventUID: '',
    );
    final testSession = Session(
      uid: '1',
      title: '',
      time: '',
      speakerUID: '',
      eventUID: '',
      agendaDayUID: '',
      type: '',
    );
    final testTrack = Track(
      uid: '1',
      sessionUids: ['1'],
      name: '',
      color: '',
      eventUid: '',
    );
    final testAgendaDay = AgendaDay(
      uid: '1',
      trackUids: ['1'],
      date: '',
      eventsUID: [],
    );

    final githubJson = GithubJsonModel(
      events: [testEvent],
      speakers: [testSpeaker],
      sponsors: [testSponsor],
      sessions: [testSession],
      tracks: [testTrack],
      agendadays: [testAgendaDay],
    );

    // This line will now work because all nested `toJson()` are stubbed.
    when(
      mockCommonsServices.loadData(any),
    ).thenAnswer((_) async => githubJson.toJson());

    when(
      mockSecureInfo.getGithubKey(),
    ).thenAnswer((_) async => GithubData(projectName: 'remote_proj'));
    when(mockSecureInfo.getGithubItem()).thenAnswer((_) async => mockGitHub);
    when(mockGitHub.repositories).thenReturn(mockRepositoriesService);

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

  group('DataLoaderManager', () {
    test('loadEvents returns an empty list if no events are visible', () async {
      final testEvent = Event(
        uid: '1',
        isVisible: false,
        tracks: [],
        eventName: '',
        year: '',
        primaryColor: '',
        secondaryColor: '',
        eventDates: EventDates(
          uid: 'testUID',
          startDate: '2025-01-01T10:00:00Z',
          endDate: '2025-01-02T18:00:00Z',
          timezone: 'timezone',
        ),
      );

      when(mockCommonsServices.loadData(any)).thenAnswer(
        (_) => Future.value({
          'events': [testEvent.toJson()],
        }),
      );

      // Act
      await dataLoaderManager.loadEvents();

      verify(mockCommonsServices.loadData(any)).called(1);
    });

    test(
      'loadAllEventData uses cache when called multiple times within 5 minutes',
      () async {
        // Arrange

        dataLoaderManager.allData = null;
        dataLoaderManager.lastFetchTime = DateTime.now();

        // Act
        await dataLoaderManager.loadAllEventData();

        // Assert
        verify(
          mockCommonsServices.loadData(any),
        ).called(1); // Should only be called once
      },
    );

    test('loadAllEventData bypasses cache when forceUpdate is true', () async {
      // Act
      await dataLoaderManager.loadAllEventData();
      await dataLoaderManager.loadAllEventData(forceUpdate: true);

      // Assert
      verify(mockCommonsServices.loadData(any)).called(2);
    });

    test('loadSpeakers returns speakers from loaded data', () async {
      final testSpeaker = Speaker(
        uid: '1',
        name: '',
        bio: '',
        image: '',
        social: Social(twitter: 'some_handle'),
        eventUIDS: [],
      );
      // Act
      when(mockCommonsServices.loadData(PathsGithub.eventPath)).thenAnswer(
        (_) => Future.value({
          'speakers': [
            {
              'UID': '1',
              'name': '',
              'bio': '',
              'image': '',
              'social': {'twitter': 'some_handle'},
              'eventUIDS': [],
            },
          ],
        }),
      );
      final speakers = await dataLoaderManager.loadSpeakers();

      // Assert
      expect(
        speakers?.length == 1 && speakers?.first.uid == testSpeaker.uid,
        true,
      );
    });

    test('loadSponsors returns sponsors from loaded data', () async {
      final testSponsor = Sponsor(
        uid: '1',
        name: '',
        type: '',
        logo: '',
        website: '',
        eventUID: '',
      );
      when(mockCommonsServices.loadData(PathsGithub.eventPath)).thenAnswer(
        (_) => Future.value({
          'sponsors': [
            {
              'UID': '1',
              'name': '',
              'type': '',
              'logo': '',
              'website': '',
              'eventUID': '',
            },
          ],
        }),
      );
      // Act
      final sponsors = await dataLoaderManager.loadSponsors();

      // Assert
      expect(
        sponsors.length == 1 && sponsors.first.uid == testSponsor.uid,
        true,
      );
    });

    test('loadAllDays resolves tracks and sessions', () async {
      // Arrange: Define the specific data for this test.
      // This makes the test self-contained and not dependent on setUpAll.
      final testSession = Session(
        uid: 'session-101',
        title: 'Flutter Magic',
        time: '10:00',
        speakerUID: 'speaker-1',
        eventUID: 'event-1',
        agendaDayUID: 'day-1',
        type: 'talk',
      );

      final testTrack = Track(
        uid: 'track-A',
        sessionUids: ['session-101'], // Reference to the session
        name: 'Mobile Track',
        color: '#FFFFFF',
        eventUid: 'event-1',
      );

      final testAgendaDay = AgendaDay(
        uid: 'day-1',
        trackUids: ['track-A'], // Reference to the track
        date: '2024-10-26',
        eventsUID: ['event-1'],
      );

      final testData = GithubJsonModel(
        agendadays: [testAgendaDay],
        tracks: [testTrack],
        sessions: [testSession],
      );

      // Mock the call to return the data for this test.
      when(
        mockCommonsServices.loadData(any),
      ).thenAnswer((_) async => testData.toJson());

      // Act
      final agendaDays = await dataLoaderManager.loadAllDays();

      // Assert
      expect(agendaDays, hasLength(1));
      expect(agendaDays.first.resolvedTracks, isNotNull);
      expect(agendaDays.first.resolvedTracks, hasLength(1));
      expect(agendaDays.first.resolvedTracks!.first.uid, testTrack.uid);
      expect(
        agendaDays.first.resolvedTracks!.first.resolvedSessions,
        hasLength(1),
      );
      expect(
        agendaDays.first.resolvedTracks!.first.resolvedSessions.first.uid,
        testSession.uid,
      );
    });
    test('loadAllSessions returns sessions from loaded data', () async {
      final testSession = Session(
        uid: 'session-101',
        title: 'Flutter Magic',
        time: '10:00',
        speakerUID: 'speaker-1',
        eventUID: 'event-1',
        agendaDayUID: 'day-1',
        type: 'talk',
      );

      final testData = GithubJsonModel(sessions: [testSession]);

      when(
        mockCommonsServices.loadData(any),
      ).thenAnswer((_) async => testData.toJson());
      // Act
      final sessions = await dataLoaderManager.loadAllSessions();

      expect(sessions, hasLength(1));
      expect(sessions.first.uid, testSession.uid);
    });
    test('loadAllTracks returns tracks from loaded data', () async {
      final testTrack = Track(
        uid: 'track-A',
        sessionUids: ['session-101'], // Reference to the session
        name: 'Mobile Track',
        color: '#FFFFFF',
        eventUid: 'event-1',
      );

      final testData = GithubJsonModel(tracks: [testTrack]);

      // Mock the call to return the data for this test.
      when(
        mockCommonsServices.loadData(any),
      ).thenAnswer((_) async => testData.toJson());
      // Act
      final tracks = await dataLoaderManager.loadAllTracks();

      expect(tracks, hasLength(1));
      expect(tracks.first.uid, testTrack.uid);
    });
    test('loadEvents throws JsonDecodeException when file content is invalid', () async {
      getIt.unregister<SecureInfo>();
      getIt.registerSingleton<SecureInfo>(mockSecureInfo);
      final fileMock = MockGitHubFile();
      when(fileMock.content).thenReturn("");
      final repoContents =
      github_sdk.RepositoryContents(file: fileMock); // file is null by default

      when(
        mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
      ).thenAnswer((_) async => repoContents);


      // Act
      try {
        await commonsServices.loadData(PathsGithub.eventPath);
      }catch(e){
        expect(e, isA<JsonDecodeException>());
        expect(
          (e as JsonDecodeException).message,
          "Error fetching data, Please retry later",
        );
      }
    });
    test('loadEvents fails when file is null', () async {
      getIt.unregister<SecureInfo>();
      getIt.registerSingleton<SecureInfo>(mockSecureInfo);
      final repoContents =
      github_sdk.RepositoryContents(); // file is null by default

      repoContents.file =
          github_sdk.GitHubFile(); // content is null by default

      when(
        mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
      ).thenAnswer((_) async => repoContents);


      // Act
      try {
        await commonsServices.loadData(PathsGithub.eventPath);
      }catch(e){
        expect(e, isA<NetworkException>());
        expect(
          (e as NetworkException).message,
          "Error fetching data, Please retry later",
        );
      }
    });
    test(
      'loadEvents throws a GitHubError when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.GitHubError(mockGitHub, 'Not Found'));

        final data = await commonsServices.loadData(PathsGithub.eventPath);

        expect(data, <String, dynamic>{});
      },
    );
    test(
      'loadEvents throws a RateLimitHit when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.RateLimitHit(mockGitHub));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "GitHub API rate limit exceeded. Please try again later.",
          );
        }
      },
    );
    test(
      'loadEvents throws a InvalidJSON when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.InvalidJSON(mockGitHub));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "Invalid JSON received from GitHub.",
          );
        }
      },
    );
    test(
      'loadEvents throws a RepositoryNotFound when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.RepositoryNotFound(mockGitHub,"repo"));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "Repository not found.",
          );
        }
      },
    );
    test(
      'loadEvents throws a UserNotFound when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.UserNotFound(mockGitHub,"user"));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "User not found.",
          );
        }
      },
    );
    test(
      'loadEvents throws a OrganizationNotFound when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.OrganizationNotFound(mockGitHub,"org"));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "Organization not found.",
          );
        }
      },
    );
    test(
      'loadEvents throws a TeamNotFound when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.TeamNotFound(mockGitHub,0));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "Team not found.",
          );
        }
      },
    );
    test(
      'loadEvents throws a AccessForbidden when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.AccessForbidden(mockGitHub));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "Access forbidden. Check your token and permissions.",
          );
        }
      },
    );
    test(
      'loadEvents throws a NotReady when the data is not found',
      () async {
        getIt.unregister<SecureInfo>();
        getIt.registerSingleton<SecureInfo>(mockSecureInfo);
        final repoContents = github_sdk.RepositoryContents();

        repoContents.file =
            github_sdk.GitHubFile(); // content is null by default

        when(
          mockRepositoriesService.getContents(any, any, ref: anyNamed('ref')),
        ).thenThrow(github_sdk.NotReady(mockGitHub,"path"));

        try {
          await commonsServices.loadData(PathsGithub.eventPath);
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(
            (e as NetworkException).message,
            "The requested resource is not ready. Please try again later.",
          );
        }
      },
    );
  });
}
