import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/paths_github.dart';
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
    // Register CommonsServices before instantiating DataLoaderManager
    getIt.registerSingleton<CommonsServices>(mockCommonsServices);
    dataLoaderManager = DataLoaderManager();
    var config = getIt.registerSingleton<Config>(MockConfig());
    when(config.githubUser).thenReturn('test_user');
    when(config.projectName).thenReturn('test_project');
    when(config.branch).thenReturn('test_branch');

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
      ), // 4. Usa la instancia del mock ya configurada
    );
    final testSpeaker = Speaker(
      uid: '1',
      name: '',
      bio: '',
      image: '',
      social: mockSocial, // Usa la instancia del mock ya configurada
      eventUIDS: [],
    );
    // ... (El resto de la creación de testSponsor, testSession, etc. se queda igual)
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

    // Esta línea ahora funcionará porque todos los `toJson()` anidados están stubeados.
    when(
      mockCommonsServices.loadData(any),
    ).thenAnswer((_) async => githubJson.toJson());

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
      // Arrange: Define los datos específicos para este test.
      // Esto hace que el test sea autocontenido y no dependa del setUpAll.
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
        sessionUids: ['session-101'], // Referencia a la sesión
        name: 'Mobile Track',
        color: '#FFFFFF',
        eventUid: 'event-1',
      );

      final testAgendaDay = AgendaDay(
        uid: 'day-1',
        trackUids: ['track-A'], // Referencia al track
        date: '2024-10-26',
        eventsUID: ['event-1'],
      );

      final testData = GithubJsonModel(
        agendadays: [testAgendaDay],
        tracks: [testTrack],
        sessions: [testSession],
      );

      // Mockea la llamada para que devuelva los datos de este test.
      when(mockCommonsServices.loadData(any))
          .thenAnswer((_) async => testData.toJson());

      // Act
      final agendaDays = await dataLoaderManager.loadAllDays();

      // Assert
      expect(agendaDays, hasLength(1));
      expect(agendaDays.first.resolvedTracks, isNotNull);
      expect(agendaDays.first.resolvedTracks, hasLength(1));
      expect(agendaDays.first.resolvedTracks!.first.uid, testTrack.uid);
      expect(agendaDays.first.resolvedTracks!.first.resolvedSessions, hasLength(1));
      expect(agendaDays.first.resolvedTracks!.first.resolvedSessions.first.uid, testSession.uid);
    });
  });
}
