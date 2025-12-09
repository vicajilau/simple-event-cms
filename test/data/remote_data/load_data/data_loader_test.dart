import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/github_json_model.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';

import '../../../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataLoaderManager dataLoaderManager;
  late MockCommonsServices mockCommonsServices;

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() async {
    mockCommonsServices = MockCommonsServices();
    getIt.registerSingleton<CommonsServices>(mockCommonsServices);
    var config = getIt.registerSingleton<Config>(MockConfig());
    when(config.githubUser).thenReturn('test_user');
    when(config.projectName).thenReturn('test_project');
    when(config.branch).thenReturn('test_branch');
    final testEvent = Event(
      uid: '1',
      isVisible: true,
      tracks: [],
      eventName: '',
      year: '',
      primaryColor: '',
      secondaryColor: '',
      eventDates: MockEventDates(),
    );
    final testSpeaker = Speaker(
      uid: '1',
      name: '',
      bio: '',
      image: '',
      social: MockSocial(),
      eventUIDS: [],
    );
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

    when(
      mockCommonsServices.loadData(any),
    ).thenAnswer((_) async => githubJson.toJson());

    dataLoaderManager = DataLoaderManager();
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

    test('loadEvents returns events from commonsServices', () async {
      // Arrange

      // Act
      final events = await dataLoaderManager.loadEvents();
      final testEvent = Event(
        uid: '1',
        isVisible: true,
        tracks: [],
        eventName: '',
        year: '',
        primaryColor: '',
        secondaryColor: '',
        eventDates: MockEventDates(),
      );
      // Assert
      expect(events, [testEvent]);
      verify(mockCommonsServices.loadData(any)).called(1);
    });

    test(
      'loadAllEventData uses cache when called multiple times within 5 minutes',
      () async {
        // Arrange


        // Act
        await dataLoaderManager.loadAllEventData();
        await dataLoaderManager.loadAllEventData(); // Call a second time

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

      // Act
      final speakers = await dataLoaderManager.loadSpeakers();
      final testSpeaker = Speaker(
        uid: '1',
        name: '',
        bio: '',
        image: '',
        social: MockSocial(),
        eventUIDS: [],
      );
      // Assert
      expect(speakers, [testSpeaker]);
    });

    test('loadSponsors returns sponsors from loaded data', () async {

      // Act
      final sponsors = await dataLoaderManager.loadSponsors();
      final testSponsor = Sponsor(
        uid: '1',
        name: '',
        type: '',
        logo: '',
        website: '',
        eventUID: '',
      );
      // Assert
      expect(sponsors, [testSponsor]);
    });

    test('loadAllDays resolves tracks and sessions', () async {
      // Arrange

      // Act
      final agendaDays = await dataLoaderManager.loadAllDays();
      final testSession = Session(
        uid: '1',
        title: '',
        time: '',
        speakerUID: '',
        eventUID: '',
        agendaDayUID: '',
        type: '',
      );
      // Assert
      expect(agendaDays.isNotEmpty, isTrue);
      expect(agendaDays.first.resolvedTracks?.isNotEmpty, isTrue);
      expect(
        agendaDays.first.resolvedTracks?.first.resolvedSessions.isNotEmpty,
        isTrue,
      );
      expect(
        agendaDays.first.resolvedTracks?.first.resolvedSessions.first,
        testSession,
      );
    });
  });
}
