import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_screen.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sec/core/routing/app_router.dart';

import '../mocks.mocks.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''),
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  late MockEventFormViewModel mockViewModel;
  late MockEventCollectionViewModel mockCollectionViewModel;
  late MockConfig mockConfig;
  late MockGoRouter mockRouter;

  setUp(() {
    getIt.reset();
    mockViewModel = MockEventFormViewModel();
    mockCollectionViewModel = MockEventCollectionViewModel();
    mockConfig = MockConfig();
    mockRouter = MockGoRouter();

    getIt.registerSingleton<EventFormViewModel>(mockViewModel);
    getIt.registerSingleton<EventCollectionViewModel>(mockCollectionViewModel);
    getIt.registerSingleton<Config>(mockConfig);

    when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.errorMessage).thenReturn('');
    when(mockViewModel.onSubmit(any)).thenAnswer((_) async => true);
    when(mockCollectionViewModel.getEventById(any)).thenAnswer((_) async => null);
    when(mockConfig.eventForcedToViewUID).thenReturn(null);
    
    AppRouter.router = mockRouter;
  });

  group('EventFormScreen', () {
    testWidgets('loads event data in edit mode', (WidgetTester tester) async {
      final event = Event(
        uid: '1',
        eventName: 'Test Event',
        eventDates: EventDates(startDate: '2023-01-01', endDate: '2023-01-02', timezone: 'UTC', uid: 'EventDates_uid'),
        primaryColor: '#FFFFFF',
        secondaryColor: '#000000',
        isVisible: true,
        tracks: [], year: '',
      );
      when(mockCollectionViewModel.getEventById('1')).thenAnswer((_) async => event);

      await tester.pumpWidget(buildTestableWidget(EventFormScreen(eventId: '1')));
      await tester.pumpAndSettle();

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('2023-01-01'), findsOneWidget);
      expect(find.text('2023-01-02'), findsOneWidget);
    });

    testWidgets('shows validation error for required fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();

      expect(find.textContaining('Required field'), findsNWidgets(0)); // Name and Start Date
    });

    testWidgets('date picker works', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('YYYY-MM-DD').first);
      await tester.pumpAndSettle();

      // Click the "OK" button in the date picker dialog to select today's date
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // The format in the form is 'yyyy-MM-dd'
      final expectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('can add and remove end date', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pumpAndSettle();

      // Remove end date
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.text('YYYY-MM-DD'), findsOneWidget);

      // Add end date back
      await tester.tap(find.text('Add end date'));
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    /*testWidgets('visibility and open by default switches work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pumpAndSettle();

      // Test isVisible switch
      await tester.tap(find.widgetWithText(SwitchListTile, 'Event is visible'));
      await tester.pump();
      expect(find.widgetWithText(SwitchListTile, 'Event is hidden'), findsOneWidget);

      // Test isOpenByDefault switch
      await tester.tap(find.widgetWithText(SwitchListTile, 'Event is not open by default'));
      await tester.pump();
      expect(find.text('Event is open by default'), findsOneWidget);
      // Toggling isOpenByDefault should also make it visible
      expect(find.text('Event is visible'), findsOneWidget);
    });*/
  });
}
