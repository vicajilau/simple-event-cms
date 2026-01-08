import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/repositories/token_repository.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/screens/config/config_screen.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_screen.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';

import '../../mocks.mocks.dart';

void main() {
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
  setUp(() async {
    await getIt.reset();
    // Dummies and default whens for common scenarios
    getIt.registerSingleton<SecureInfo>(SecureInfo());

    provideDummy<Result<void>>(const Result.ok(null));
    provideDummy<Result<List<Event>>>(const Result.ok([]));
    provideDummy<Result<Event>>(Result.ok(MockEvent()));
    provideDummy<Result<Event?>>(Result.ok(null));
    provideDummy<Result<Track>>(Result.ok(MockTrack()));
    provideDummy<Result<List<AgendaDay>>>(Result.ok([MockAgendaDay()]));
    provideDummy<Result<AgendaDay>>(Result.ok(MockAgendaDay()));
    provideDummy<Result<List<Speaker>>>(Result.ok([MockSpeaker()]));
    provideDummy<Result<List<Track>>>(Result.ok([MockTrack()]));
    provideDummy<Result<List<Sponsor>>>(Result.ok([]));

    getIt.registerSingleton<Config>(
      Config(
        configName: 'test_name',
        primaryColorOrganization:
            '#000000', // Un color hexadecimal válido tiene 6 dígitos
        secondaryColorOrganization: '#000000',
        githubUser: 'test_user',
        projectName: 'test_project',
        branch: 'test_branch',
      ),
    );
    final mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();
    final mockSecRepository = MockSecRepository();
    final mockTokenRepository = MockTokenRepository();
    final mockEventUseCase = MockEventUseCase();
    final mockAgendaUseCase = MockAgendaUseCase();
    final mockConfigUseCase = MockConfigUseCase();
    final mockSponsorUseCase = MockSponsorUseCase();
    final mockSpeakerUseCase = MockSpeakerUseCase();

    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);
    getIt.registerSingleton<SecRepository>(mockSecRepository);
    getIt.registerSingleton<TokenRepository>(mockTokenRepository);
    getIt.registerSingleton<EventUseCase>(mockEventUseCase);
    getIt.registerSingleton<AgendaUseCase>(mockAgendaUseCase);
    getIt.registerSingleton<ConfigUseCase>(mockConfigUseCase);
    getIt.registerSingleton<SponsorUseCase>(mockSponsorUseCase);
    getIt.registerSingleton<SpeakerUseCase>(mockSpeakerUseCase);

    when(
      mockCheckTokenSavedUseCase.checkToken(),
    ).thenAnswer((_) async => Future.value(true));
    when(
      mockEventUseCase.getEvents(),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
      mockEventUseCase.saveEvent(any),
    ).thenAnswer((_) async => Result.ok(null));
    when(
      mockEventUseCase.getEventById(
        any,
      ), // This was returning null, which is likely the cause of the error.
    ).thenAnswer(
      (_) async => Result.ok(
        Event(
          uid: 'event-1',
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
          ), // Providing categories for the dropdown
        ),
      ),
    );
    when(
      mockAgendaUseCase.saveSpeaker(any, any),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
      mockAgendaUseCase.getAgendaDayByEventIdFiltered(any),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
      mockAgendaUseCase.getTracksByEventId(any),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
      mockAgendaUseCase.getAgendaDayByEventId(any),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
      mockAgendaUseCase.loadEvent(any),
    ).thenAnswer((_) async => Result.ok(MockEvent()));
    when(
      mockAgendaUseCase.getSpeakersForEventId(any),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
      mockSpeakerUseCase.removeSpeaker(any, any),
    ).thenAnswer((_) async => const Result.ok([]));
    when(
      mockSponsorUseCase.getSponsorByIds(any),
    ).thenAnswer((_) async => const Result.ok([]));

    // Registra las implementaciones reales de TODOS tus ViewModels.
    getIt.registerSingleton<EventFormViewModel>(EventFormViewModelImpl());
    getIt.registerSingleton<EventCollectionViewModel>(
      EventCollectionViewModelImp(),
    );
    getIt.registerSingleton<EventDetailViewModel>(EventDetailViewModelImp());
    getIt.registerSingleton<AgendaViewModel>(AgendaViewModelImp());
    getIt.registerSingleton<AgendaFormViewModel>(AgendaFormViewModelImpl());
    getIt.registerSingleton<SponsorViewModel>(
      SponsorViewModelImpl(),
    ); // <-- REAL
    getIt.registerSingleton<SpeakerViewModel>(
      SpeakerViewModelImpl(),
    ); // <-- REAL
    getIt.registerSingleton<OnLiveViewModel>(OnLiveViewModelImpl());
    getIt.registerSingleton<ConfigViewModel>(ConfigViewModelImpl());

    // --- CORRECTO: El resto de tus registros ---
    getIt.registerSingleton<DataLoaderManager>(DataLoaderManager());
    getIt.registerSingleton<CheckOrg>(CheckOrg(initial: false));
  });

  tearDown(() async {
    // Esto ya está perfecto.
    await getIt.reset();
  });

  group('AppRouter', () {
    Future<void> navigateTo(
      WidgetTester tester,
      String location, {
      Object? extra,
    }) async {
      final router = AppRouter.createRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      );

      // Use router.go for navigation and then pump and settle
      router.go(location, extra: extra);
      await tester.pumpAndSettle();
    }

    testWidgets('initial route should be home', (tester) async {
      // Use the real router for testing the initial route.
      // final router = AppRouter.router; // This can be removed, using the one from setup
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: AppRouter.router,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(EventCollectionScreen), findsOneWidget);
    });

    group('EventDetail Route', () {
      testWidgets('navigates to event detail screen with all params', (
        tester,
      ) async {
        const eventId = 'test-id';
        const location = 'test-location';
        // Note: go_router expects sub-route paths to be relative.
        // The path '/event/detail/...' might not work as a sub-route of '/'.
        // Assuming it is treated as a top-level route.
        final path = '/event/detail/$eventId/$location/true';

        await navigateTo(tester, path);

        expect(find.byType(EventDetailScreen), findsOneWidget);
        final screen = tester.widget<EventDetailScreen>(
          find.byType(EventDetailScreen),
        );
        expect(screen.eventId, eventId);
        expect(screen.location, location);
        expect(screen.onlyOneEvent, isTrue);
      });

      testWidgets('handles boolean parsing correctly for onlyOneEvent', (
        tester,
      ) async {
        await navigateTo(tester, '/event/detail/id/loc/false');
        expect(
          tester
              .widget<EventDetailScreen>(find.byType(EventDetailScreen))
              .onlyOneEvent,
          isFalse,
        );

        await navigateTo(tester, '/event/detail/id/loc/invalid-bool');
        expect(
          tester
              .widget<EventDetailScreen>(find.byType(EventDetailScreen))
              .onlyOneEvent,
          isFalse,
        );
      });
    });

    group('EventForm Route', () {
      testWidgets('navigates to event form screen without extra', (
        tester,
      ) async {
        await navigateTo(tester, AppRouter.eventFormPath);
        expect(find.byType(EventFormScreen), findsOneWidget);
        expect(
          tester.widget<EventFormScreen>(find.byType(EventFormScreen)).eventId,
          isNull,
        );
      });

      testWidgets('navigates to event form screen with extra', (tester) async {
        const eventId = 'event-id-from-extra';
        await navigateTo(tester, AppRouter.eventFormPath, extra: eventId);
        expect(find.byType(EventFormScreen), findsOneWidget);
        expect(
          tester.widget<EventFormScreen>(find.byType(EventFormScreen)).eventId,
          eventId,
        );
      });
    });

    testWidgets('navigates to OnLive screen with data', (tester) async {
      final data = OnLiveData(youtubeUrl: 'www.youtube.com/watch?v=123');
      await navigateTo(tester, AppRouter.onLivePath, extra: data);
      expect(find.byType(OnLiveScreen), findsOneWidget);
      expect(tester.widget<OnLiveScreen>(find.byType(OnLiveScreen)).data, data);
    });

    testWidgets('navigates to Config screen', (tester) async {
      await navigateTo(tester, AppRouter.configFormPath);
      expect(find.byType(ConfigScreen), findsOneWidget);
    });

    group('AgendaForm Route', () {
      testWidgets('navigates to agenda form screen with data', (tester) async {
        final data = AgendaFormData(
          session: Session(
            uid: 'session_uid',
            title: 'title_session',
            time: '',
            speakerUID: '',
            eventUID: '',
            agendaDayUID: '',
            type: '',
          ),
          eventId: '',
        );
        await navigateTo(tester, AppRouter.agendaFormPath, extra: data);
        expect(find.byType(AgendaFormScreen), findsOneWidget);
        expect(
          tester.widget<AgendaFormScreen>(find.byType(AgendaFormScreen)).data,
          data,
        );
      });
    });

    group('SpeakerForm Route', () {
      const eventId = 'event-1';
      final speaker = Speaker(
        uid: '1',
        name: 'Test Speaker',
        bio: 'Bio',
        social: Social(),
        image: '',
        eventUIDS: [],
      );

      testWidgets('navigates to speaker form with speaker and eventId', (
        tester,
      ) async {
        await navigateTo(
          tester,
          AppRouter.speakerFormPath,
          extra: {'speaker': speaker, 'eventId': eventId},
        );
        final screen = tester.widget<SpeakerFormScreen>(
          find.byType(SpeakerFormScreen),
        );
        expect(screen.speaker, speaker);
        expect(screen.eventUID, eventId);
      });

      testWidgets('navigates to speaker form with null speaker', (
        tester,
      ) async {
        await navigateTo(
          tester,
          AppRouter.speakerFormPath,
          extra: {'eventId': eventId},
        );
        final screen = tester.widget<SpeakerFormScreen>(
          find.byType(SpeakerFormScreen),
        );
        expect(screen.speaker, isNull);
        expect(screen.eventUID, eventId);
      });
    });

    group('SponsorForm Route', () {
      const eventId = 'event-1';
      /*final sponsor = Sponsor(
        uid: '1',
        name: 'Test Sponsor',
        logo: 'logo',
        type: 'gold',
        website: '',
        eventUID: '',
      );*/

      //TODO review why that test enter into sponsorformscreen two times
      /*testWidgets('navigates to sponsor form with sponsor and eventId', (
        tester,
      ) async {
        await navigateTo(
          tester,
          AppRouter.sponsorFormPath,
          extra: {'sponsor': sponsor, 'eventId': eventId},
        );
        final screen = tester.widget<SponsorFormScreen>(
          find.byType(SponsorFormScreen),
        );
        expect(screen.sponsor, sponsor);
        expect(screen.eventUID, eventId);
      });*/

      testWidgets('navigates to sponsor form with null sponsor', (
        tester,
      ) async {
        await navigateTo(
          tester,
          AppRouter.sponsorFormPath,
          extra: {'eventId': eventId},
        );
        final screen = tester.widget<SponsorFormScreen>(
          find.byType(SponsorFormScreen),
        );
        expect(screen.sponsor, isNull);
        expect(screen.eventUID, eventId);
      });
    });
  });
}
