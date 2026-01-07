import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_screen.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/view_model_common.dart';

// Importa los mocks generados
import '../../helpers/test_helpers.dart';
import '../../mocks.mocks.dart';

// Widget Wrapper to provide the necessary context (MaterialApp, Localizations)
Widget createTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  // Mocks y Fakes
  // Mocks and Fakes
  late MockEventDetailViewModel mockViewModel;
  late MockEventUseCase mockEventUseCase;
  late MockAgendaViewModel mockAgendaViewModel;
  late MockSpeakerViewModel mockSpeakersViewModel;
  late MockSponsorViewModel mockSponsorsViewModel;
  late MockGoRouter mockRouter;

  // Variables de prueba
  // Test variables
  const String testEventId = 'test-event-id';
  const String testLocation = 'Test Location';
  setUp(() {
    getIt.reset();

    // Instantiate and register ALL mocks in the dependency injector (getIt).
    // This way, when each screen tries to get its ViewModel, it will receive the corresponding mock.

    // Mock for the main ViewModel
    mockViewModel = MockEventDetailViewModel();
    mockRouter = MockGoRouter();

    getIt.registerSingleton<SecureInfo>(SecureInfo());
    getIt.registerSingleton<EventDetailViewModel>(mockViewModel);
    provideDummy<Result<List<Event>>>(Result.ok([]));

    mockEventUseCase = MockEventUseCase();

    // Mocks for the child screens' ViewModels
    mockAgendaViewModel = MockAgendaViewModel();
    getIt.registerSingleton<AgendaViewModel>(mockAgendaViewModel);

    mockSpeakersViewModel = MockSpeakerViewModel();
    getIt.registerSingleton<SpeakerViewModel>(mockSpeakersViewModel);

    mockSponsorsViewModel = MockSponsorViewModel();
    getIt.registerSingleton<SponsorViewModel>(mockSponsorsViewModel);

    // Configure the default behavior of ALL mocks.
    // This prevents them from failing when trying to access null properties.

    // Configuration for EventDetailViewModel
    when(mockViewModel.setup(any)).thenAnswer((_) async {});
    when(mockViewModel.notShowReturnArrow).thenReturn(ValueNotifier(false));
    when(mockViewModel.eventTitle).thenReturn(ValueNotifier('Test Event'));
    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.checkToken()).thenAnswer((_) async => false);
    when(mockViewModel.errorMessage).thenReturn('Error occurred');
    when(mockViewModel.dispose()).thenAnswer((_) {});

    // Configuration for AgendaViewModel (basic values to prevent failure)
    when(mockAgendaViewModel.setup(any)).thenAnswer((_) async {});
    when(
      mockAgendaViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockAgendaViewModel.dispose()).thenAnswer((_) {});
    when(
      mockAgendaViewModel.loadAgendaDays(any),
    ).thenAnswer((_) async => const Result.ok(null));
    when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier([]));

    // Configuration for SpeakersViewModel
    when(mockSpeakersViewModel.setup(any)).thenAnswer((_) async {});
    when(
      mockSpeakersViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockSpeakersViewModel.speakers).thenReturn(ValueNotifier([]));
    when(mockSpeakersViewModel.dispose()).thenAnswer((_) {});
    when(mockEventUseCase.getEvents()).thenAnswer((_) async {
      return Result.ok([
        Event(
          uid: testEventId,
          tracks: const [],
          eventName: 'Test Event',
          year: '',
          primaryColor: '',
          secondaryColor: '',
          eventDates: MockEventDates(),
        ),
      ]);
    });
    AppRouter.router = mockRouter;
  });

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    provideDummy<Result<void>>(const Result.ok(null));
  });

  group('EventDetailScreen Tests', () {
    testWidgets('Initializes correctly and shows the main UI', (
      WidgetTester tester,
    ) async {
      // mock configuration
      when(mockViewModel.setup(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createTestWidget(
          EventDetailScreen(eventId: testEventId, location: testLocation),
        ),
      );
      await tester.pumpAndSettle(); // Wait for FutureBuilders to complete

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Speakers'), findsOneWidget);
      expect(find.text('Sponsors'), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
      expect(find.text('Test Event'), findsOneWidget); // From MockViewModel
    });

    testWidgets('Changes tab when tapping on the TabBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          EventDetailScreen(eventId: testEventId, location: testLocation),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the "Speakers" tab
      await tester.tap(find.text('Speakers'));
      await tester.pumpAndSettle();

      // Verification: The TabBarView should have changed.
      // It's hard to verify the screen content without more complex mocks,
      // but we can check that the interaction doesn't throw errors.
      // The index change is implicitly tested in the "Add" button test.
      expect(find.text('Speakers'), findsOneWidget);
    });

    group('Add button (+)', () {
      testWidgets('Does not appear when checkToken is false', (
        WidgetTester tester,
      ) async {
        // checkToken returns false by default in the mock
        await tester.pumpWidget(
          createTestWidget(
            EventDetailScreen(eventId: testEventId, location: testLocation),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsNothing);
      });
    });

    testWidgets('Shows CircularProgressIndicator in isLoading state', (
      WidgetTester tester,
    ) async {
      // Configure loading state
      mockViewModel.viewState.value = ViewState.isLoading;

      await tester.pumpWidget(
        createTestWidget(
          EventDetailScreen(eventId: testEventId, location: testLocation),
        ),
      );

      // Don't use pumpAndSettle because we want to see the loading state
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows CustomErrorDialog in error state', (
      WidgetTester tester,
    ) async {
      // Configure error state
      mockViewModel.viewState.value = ViewState.error;

      await tester.pumpWidget(
        createTestWidget(
          EventDetailScreen(eventId: testEventId, location: testLocation),
        ),
      );

      // The dialog is shown in the next frame
      await tester.pump();

      expect(find.byType(CustomErrorDialog), findsOneWidget);

      // Simulate closing the dialog
      await tester.tap(find.text('Close'));
      await tester.pump();

      // Verify that the state has returned to `loadFinished`
      expect(mockViewModel.viewState.value, ViewState.loadFinished);
    });
  });

  group('Event Detail Screen tabs', () {
    testWidgets(
      'Tab 0 Navigate and call loadAgendaDays if the form return days',
      (tester) async {
        when(mockViewModel.checkToken()).thenAnswer((_) async => true);

        // When navigate to Agenda form, return List<AgendaDay>
        when(
          mockRouter.push<List<AgendaDay>>(
            AppRouter.agendaFormPath,
            extra: anyNamed('extra'),
          ),
        ).thenAnswer(
          (_) async => [
            AgendaDay(uid: 'day1', eventsUID: [], date: '', trackUids: null),
          ],
        );

        await tester.pumpWidget(
          createTestWidget(
            EventDetailScreen(eventId: testEventId, location: testLocation),
          ),
        );
        await tester.pumpAndSettle();

        // Change to "Agenda" tab
        await tester.tap(find.text('Agenda'));
        await tester.pumpAndSettle();

        clearInteractions(mockAgendaViewModel);

        // Press the + button
        final addButton = find.widgetWithIcon(ElevatedButton, Icons.add);
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Verify navigation to Agenda form
        verify(
          mockRouter.push<List<AgendaDay>>(
            AppRouter.agendaFormPath,
            extra: anyNamed('extra'),
          ),
        ).called(1);

        // Verify that the ViewModel is refreshed (loadAgendaDays) with the correct eventId
        verify(mockAgendaViewModel.loadAgendaDays(testEventId)).called(1);

        // Ensure that the other VMs were NOT called by the tap
        verifyNever(mockSpeakersViewModel.addSpeaker(any, any));
        verifyNever(mockSponsorsViewModel.addSponsor(any, any));
      },
    );

    testWidgets('Tab 1 navigate and call addSpeaker', (tester) async {
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);

      // The navigation returns a Speaker when navigating to speakerFormPath
      when(
        mockRouter.push<Speaker>(
          AppRouter.speakerFormPath,
          extra: anyNamed('extra'),
        ),
      ).thenAnswer(
        (_) async => Speaker(
          uid: 'speaker1',
          name: 'John Doe',
          eventUIDS: [],
          bio: '',
          image: '',
          social: MockSocial(),
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          EventDetailScreen(eventId: testEventId, location: testLocation),
        ),
      );
      await tester.pumpAndSettle();

      // Change to "Speakers" tab
      await tester.tap(find.text('Speakers'));
      await tester.pumpAndSettle();

      // Press the + button
      final addButton = find.widgetWithIcon(ElevatedButton, Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify navigation
      verify(
        mockRouter.push<Speaker>(
          AppRouter.speakerFormPath,
          extra: anyNamed('extra'),
        ),
      ).called(1);

      // Verify action in Speakers VM
      verify(mockSpeakersViewModel.addSpeaker(any, testEventId)).called(1);

      // Verify that the Sponsor VM was NOT called
      verifyNever(mockSponsorsViewModel.addSponsor(any, any));
    });

    testWidgets('Tab 2 navigate and call addSponsor', (tester) async {
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);

      when(mockAgendaViewModel.setup(any)).thenAnswer((_) async {});
      when(
        mockAgendaViewModel.viewState,
      ).thenReturn(ValueNotifier(ViewState.loadFinished));
      when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier([]));
      when(
        mockAgendaViewModel.loadAgendaDays(any),
      ).thenAnswer((_) async => const Result.ok(null));
      when(mockAgendaViewModel.dispose()).thenAnswer((_) {});

      when(mockSpeakersViewModel.setup(any)).thenAnswer((_) async {});
      when(
        mockSpeakersViewModel.viewState,
      ).thenReturn(ValueNotifier(ViewState.loadFinished));
      when(mockSpeakersViewModel.speakers).thenReturn(ValueNotifier([]));
      when(mockSpeakersViewModel.dispose()).thenAnswer((_) {});

      when(mockSponsorsViewModel.setup(any)).thenAnswer((_) async {});
      when(
        mockSponsorsViewModel.viewState,
      ).thenReturn(ValueNotifier(ViewState.loadFinished));
      when(mockSponsorsViewModel.sponsors).thenReturn(ValueNotifier([]));
      when(mockSponsorsViewModel.dispose()).thenAnswer((_) {});

      // Nvigation returns a Sponsor when navigating to sponsorFormPath
      when(
        mockRouter.push<Sponsor>(
          AppRouter.sponsorFormPath,
          extra: anyNamed('extra'),
        ),
      ).thenAnswer(
        (_) async => Sponsor(
          uid: '1',
          name: 'ACME',
          type: 'Gold',
          logo: '',
          website: '',
          eventUID: testEventId,
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          EventDetailScreen(eventId: testEventId, location: testLocation),
        ),
      );
      await tester.pumpAndSettle();

      // Change the tab to "Sponsors"
      await tester.tap(find.text('Sponsors'));
      await tester.pumpAndSettle();

      clearInteractions(mockAgendaViewModel);

      // Press the + button
      final addButton = find.widgetWithIcon(ElevatedButton, Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify navigation
      verify(
        mockRouter.push<Sponsor>(
          AppRouter.sponsorFormPath,
          extra: anyNamed('extra'),
        ),
      ).called(1);

      // Verify action in Sponsors VM
      verify(mockSponsorsViewModel.addSponsor(any, testEventId)).called(1);

      // Assert that the TAP did not trigger NEW calls in Agenda (beyond those from setup)
      verifyNever(mockAgendaViewModel.loadAgendaDays(any));
      // And that Speakers was not touched
      verifyNever(mockSpeakersViewModel.addSpeaker(any, any));
    });
  });
}
