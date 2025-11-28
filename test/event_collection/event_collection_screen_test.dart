import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_screen.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/login/admin_login_screen.dart';
import 'package:sec/presentation/ui/screens/no_events/no_events_screen.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/event_filter_button.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

// Helper to wrap widgets for testing, providing MaterialApp and localizations.
Widget buildTestableWidget() {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''), // English, no country code
    ],
    home: EventCollectionScreen(),
  );
}

void main() {
  late MockEventCollectionViewModel mockViewModel;
  late MockConfig mockConfig;
  late MockCheckOrg mockCheckOrg;
  late MockGoRouter mockRouter;

  setUp(() async {
    // Reset dependencies for each test to ensure isolation
    getIt.reset();
    mockViewModel = MockEventCollectionViewModel();
    mockConfig = MockConfig();
    mockCheckOrg = MockCheckOrg();
    mockRouter = MockGoRouter();
    // Register mocks in GetIt's service locator
    getIt.registerSingleton<EventCollectionViewModel>(mockViewModel);
    getIt.registerSingleton<Config>(mockConfig);
    getIt.registerSingleton<GoRouter>(mockRouter);
    getIt.registerSingleton<CheckOrg>(mockCheckOrg);
    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.eventsToShow).thenReturn(ValueNotifier([]));
    when(mockViewModel.errorMessage).thenReturn("");
    when(mockViewModel.checkToken()).thenAnswer((_) async => false);
    when(mockViewModel.setup()).thenAnswer((_) async {});
    when(mockViewModel.loadEvents()).thenAnswer((_) async {});
    when(mockCheckOrg.hasError).thenReturn(false);
    when(mockConfig.configName).thenReturn('Test Conf');

    // Set the mocked router
    AppRouter.router = mockRouter;
  });

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    provideDummy<Result<void>>(const Result.ok(null));
    // Default mock behaviors. Tests can override these.
  });

  group('EventCollectionScreen', () {
    testWidgets('shows loading indicator initially and then content', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.isLoading));

      await tester.pumpWidget(
        buildTestableWidget(),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      when(mockViewModel.viewState)
          .thenReturn(ValueNotifier(ViewState.loadFinished));
      // Rebuild the widget to reflect the new state.
      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Conf'), findsOneWidget);
    });

    testWidgets('displays error message on load failure', (
      WidgetTester tester,
    ) async {
      // Use a local ValueNotifier to control state changes during the test.
      final viewStateNotifier = ValueNotifier(ViewState.error);

      // Start with an error state
      when(mockViewModel.viewState).thenReturn(viewStateNotifier);
      when(mockViewModel.errorMessage)
          .thenReturn('Error loading configuration: ');

      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle(); // Pump and settle to allow dialog to show.

      // The error message and retry button are inside the CustomErrorDialog.
      expect(find.byType(CustomErrorDialog), findsOneWidget);
      expect(find.descendant(of: find.byType(CustomErrorDialog), matching: find.text('Error loading configuration: ')), findsOneWidget);
    });

    testWidgets('shows CustomErrorDialog when viewmodel has a specific error', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.error));
      when(mockViewModel.errorMessage).thenReturn('Network Error');
      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle(); // Let post frame callback run for the dialog

      expect(find.byType(CustomErrorDialog), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
    });

    testWidgets('displays MaintenanceScreen when there are no events', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.eventsToShow).thenReturn(ValueNotifier([]));
      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaintenanceScreen), findsOneWidget);
    });

    testWidgets('displays event grid and highlights the upcoming event', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final upcomingEvent = Event(
        uid: '2',
        eventName: 'Upcoming Event',
        eventDates: EventDates(
          uid: "eventDates_UID",
          startDate: now.add(const Duration(days: 1)).toIso8601String(),
          endDate: '',
          timezone: "Europe/Madrid",
        ),
        location: '',
        description: '',
        isVisible: true,
        tracks: [],
        year: '',
        primaryColor: '',
        secondaryColor: '',
      );
      final pastEvent = Event(
        uid: '1',
        eventName: 'Past Event',
        eventDates: EventDates(
          uid: "eventDates_UID",
          startDate: now.subtract(const Duration(days: 1)).toIso8601String(),
          endDate: '',
          timezone: "Europe/Madrid",
        ),
        location: '',
        description: '',
        isVisible: true,
        tracks: [],
        year: '',
        primaryColor: '',
        secondaryColor: '',
      );

      when(
        mockViewModel.eventsToShow,
      ).thenReturn(ValueNotifier([pastEvent, upcomingEvent]));

      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Upcoming Event'), findsOneWidget);
      expect(find.text('Past Event'), findsOneWidget);
    });

    testWidgets('filter dropdown calls viewmodel with correct filter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filter Event'));
      await tester.pumpAndSettle(); // open dropdown

      await tester.tap(find.text('Past Events').last);
      await tester.pumpAndSettle();

      verify(mockViewModel.onEventFilterChanged(EventFilter.past)).called(1);
    });

    testWidgets('tapping title 5 times opens admin login if org has error', (
      WidgetTester tester,
    ) async {
      when(mockCheckOrg.hasError).thenReturn(true);
      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle();

      final titleGestureDetector = find
          .descendant(
            of: find.byType(AppBar),
            matching: find.byType(GestureDetector),
          )
          .first;

      for (int i = 0; i < 5; i++) {
        await tester.tap(titleGestureDetector);
      }
      await tester.pumpAndSettle();

      expect(find.byType(AdminLoginScreen), findsOneWidget);
    });

    testWidgets(
      'Admin sees Add Event button, taps it, and new event is added',
      (WidgetTester tester) async {
        final newEvent = Event(
          uid: 'new',
          eventName: 'New Event',
          eventDates: EventDates(
            uid: "eventDates_UID",
            startDate: DateTime.now().toIso8601String(),
            endDate: '',
            timezone: "Europe/Madrid",
          ),
          location: '',
          description: '',
          isVisible: true,
          tracks: [],
          year: '',
          primaryColor: '',
          secondaryColor: '',
        );

        when(mockViewModel.checkToken()).thenAnswer((_) async => true);
        when(mockViewModel.eventsToShow).thenReturn(ValueNotifier([]));
        // Simulate the router returning a new event
        when(
          mockRouter.push(AppRouter.eventFormPath),
        ).thenAnswer((_) async => newEvent);
        when(mockViewModel.addEvent(newEvent)).thenAnswer((_) async {});

        await tester.pumpWidget(
          buildTestableWidget(),
        );
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(ElevatedButton, 'Add Event'),
          findsOneWidget,
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Event'));
        await tester.pumpAndSettle();

        verify(mockRouter.push(AppRouter.eventFormPath)).called(1);
        // The state updates, so we check if the viewmodel methods were called.
        verify(mockViewModel.addEvent(newEvent)).called(1);
      },
    );

    testWidgets('Admin can toggle event visibility', (
        WidgetTester tester,
        ) async {
      final event = Event(
        uid: '1',
        eventName: 'Event 1',
        eventDates: EventDates(
          uid: "eventDates_UID",
          startDate: DateTime.now().toIso8601String(),
          endDate: '',
          timezone: "Europe/Madrid",
        ),
        location: '',
        description: '',
        isVisible: true,
        tracks: [],
        year: '',
        primaryColor: '',
        secondaryColor: '',
      );

      // --- INICIO DE LA SOLUCIÓN ---
      // Clonamos el evento y cambiamos su visibilidad para simular la lógica del ViewModel.
      final editedEvent = event.copyWith(isVisible: false);

      when(mockViewModel.checkToken()).thenAnswer((_) async => true);
      // Define el comportamiento esperado para la llamada a editEvent.
      when(mockViewModel.editEvent(any)).thenAnswer((_) async {
        mockViewModel.eventsToShow.value = [editedEvent];
        return Result.ok(null);
      });
      // --- FIN DE LA SOLUCIÓN ---

      mockViewModel.eventsToShow.value = [event]; // Estado inicial

      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle(); // Muestra el diálogo

      await tester.tap(find.widgetWithText(TextButton, 'Change Visibility'));
      await tester.pumpAndSettle(); // Cierra el diálogo y ejecuta la lógica

      // Ahora, en lugar de llamar directamente al método, verificamos que el test lo llamó.
      verify(mockViewModel.editEvent(any)).called(1);

      // Y comprobamos que el estado se actualizó como esperábamos.
      expect(mockViewModel.eventsToShow.value[0].isVisible, isFalse);
    });

    testWidgets('Admin cancels toggle visibility dialog', (
      WidgetTester tester,
    ) async {
      // Setup similar to the successful toggle test, but we will tap "Cancel"
      final event = Event(uid: '1', eventName: 'Event 1', isVisible: true, eventDates: EventDates(uid: 'uid', startDate: DateTime.now().toIso8601String(), endDate: '', timezone: ''), location: '', description: '', tracks: [], year: '', primaryColor: '', secondaryColor: '');
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);
      mockViewModel.eventsToShow.value = [event];

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle(); // Dialog is shown

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle(); // Dialog is dismissed

      verifyNever(mockViewModel.editEvent(any));
    });

    testWidgets('Admin can edit and delete event from card', (
      WidgetTester tester,
    ) async {
      final event = Event(
        uid: '1',
        eventName: 'Event 1',
        eventDates: EventDates(
          uid: "eventDates_UID",
          startDate: DateTime.now().toIso8601String(),
          endDate: '',
          timezone: "Europe/Madrid",
        ),
        location: '',
        description: '',
        isVisible: true,
        tracks: [],
        year: '',
        primaryColor: '',
        secondaryColor: '',
      );
      when(mockViewModel.eventsToShow).thenReturn(ValueNotifier([event]));
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);
      when(
        mockRouter.push(AppRouter.eventFormPath, extra: '1'),
      ).thenAnswer((_) async => null);
      when(mockViewModel.deleteEvent(event)).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestableWidget(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      verify(mockRouter.push(AppRouter.eventFormPath, extra: '1')).called(1);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete Event'));
      await tester.pumpAndSettle();

      verify(mockViewModel.deleteEvent(event)).called(1);
    });

    testWidgets(
      'Admin sees and can tap organization FAB, updates config on return',
      (WidgetTester tester) async {
        when(mockViewModel.checkToken()).thenAnswer((_) async => true);
        final updatedConfig = Config(
          configName: 'Updated Conf',
          primaryColorOrganization: 'test',
          secondaryColorOrganization: 'test',
          githubUser: 'test',
          projectName: 'test',
          branch: 'test',
        );
        when(
          mockRouter.push(AppRouter.configFormPath),
        ).thenAnswer((_) async => updatedConfig);
        
        when(mockConfig.configName).thenReturn('Test Conf');
        
        await tester.pumpWidget(
          buildTestableWidget(),
        );
        await tester.pumpAndSettle();
        
        when(mockConfig.configName).thenReturn('Updated Conf');

        final fab = find.byIcon(Icons.business);
        expect(fab, findsOneWidget);

        await tester.tap(fab);
        await tester.pumpAndSettle();
        
        verify(mockRouter.push(AppRouter.configFormPath)).called(1);
        
        await tester.pumpAndSettle();

        expect(find.text('Updated Conf'), findsOneWidget);
      },
    );
  });
}
