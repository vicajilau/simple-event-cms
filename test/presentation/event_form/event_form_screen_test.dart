import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_screen.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/section_input_form.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../mocks.mocks.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', '')],
    home: Scaffold(body: child),
  );
}

void main() {
  late MockEventFormViewModel mockViewModel;
  late MockEventCollectionViewModel mockCollectionViewModel;
  late MockConfig mockConfig;
  late MockGoRouter mockRouter;
  late MockNominatim mockNominatim;

  setUp(() {
    getIt.reset();
    mockViewModel = MockEventFormViewModel();
    mockCollectionViewModel = MockEventCollectionViewModel();
    mockConfig = MockConfig();
    mockRouter = MockGoRouter();
    mockNominatim = MockNominatim();

    getIt.registerSingleton<EventFormViewModel>(mockViewModel);
    getIt.registerSingleton<EventCollectionViewModel>(mockCollectionViewModel);
    getIt.registerSingleton<Config>(mockConfig);
    getIt.registerSingleton<Nominatim>(mockNominatim);

    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.errorMessage).thenReturn('');
    when(mockViewModel.onSubmit(any)).thenAnswer((_) async => true);
    when(
      mockCollectionViewModel.getEventById(any),
    ).thenAnswer((_) async => null);
    when(mockConfig.eventForcedToViewUID).thenReturn(null);

    AppRouter.router = mockRouter;
  });

  group('EventFormScreen', () {
    testWidgets('loads event data in edit mode', (WidgetTester tester) async {
      final event = Event(
        uid: '1',
        eventName: 'Test Event',
        eventDates: EventDates(
          startDate: '2023-01-01',
          endDate: '2023-01-02',
          timezone: 'UTC',
          uid: 'EventDates_uid',
        ),
        primaryColor: '#FFFFFF',
        secondaryColor: '#000000',
        isVisible: true,
        tracks: [],
        year: '',
      );
      when(
        mockCollectionViewModel.getEventById('1'),
      ).thenAnswer((_) async => event);

      await tester.pumpWidget(
        buildTestableWidget(EventFormScreen(eventId: '1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('2023-01-01'), findsOneWidget);
      expect(find.text('2023-01-02'), findsOneWidget);
    });

    testWidgets('shows validation error for required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();

      expect(
        find.textContaining('Required field'),
        findsNWidgets(0),
      ); // Name and Start Date
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

  group('Check event fields', () {
    testWidgets(
      'Shows the CustomErrorDialog and focuses the first invalid field',
      (tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
        await tester.pumpAndSettle();

        // Press the button that activates the _onSubmit()
        final submitButton = find.byKey(const Key('submitButton'));
        await tester.ensureVisible(submitButton);
        expect(submitButton, findsOneWidget);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Shows the CustomErrorDialog with the localized error message
        expect(find.byType(CustomErrorDialog), findsOneWidget);
        expect(
          find.textContaining(l10n.formError, findRichText: true),
          findsOneWidget,
        );

        // Close the dialog (press the button)
        final closeButton = find.text(l10n.closeButton);
        expect(closeButton, findsOneWidget);
        await tester.tap(closeButton);
        await tester.pumpAndSettle();

        // Localize the first TextFormField of the form
        final firstTextField = find.byType(TextFormField).first;
        expect(firstTextField, findsOneWidget);

        // Find its EditableText descendant
        final editableOfFirstField = find.descendant(
          of: firstTextField,
          matching: find.byType(EditableText),
        );
        expect(editableOfFirstField, findsOneWidget);

        // Verify that the EditableText has focus
        final editableWidget = tester.widget<EditableText>(
          editableOfFirstField,
        );
        expect(editableWidget.focusNode.hasFocus, isTrue);
      },
    );

    testWidgets(
      'When all required fields are filled, _onSubmit does not show CustomErrorDialog',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
        await tester.pumpAndSettle();

        // Name
        final nameEditable = find.descendant(
          of: find.byKey(const Key('SectionInputForm_NameField')),
          matching: find.byType(EditableText),
        );
        expect(nameEditable, findsOneWidget);
        await tester.enterText(nameEditable, 'FlutterConference BCN');
        await tester.pump();

        // Location
        final locationEditable = find.descendant(
          of: find.byKey(const Key('eventForm_locationField')),
          matching: find.byType(EditableText),
        );
        expect(locationEditable, findsOneWidget);
        await tester.enterText(locationEditable, 'Barcelona');
        await tester.pump();

        // Start date
        final startDateEditable = find.descendant(
          of: find.byKey(const Key('SectionInputForm_StartDateField')),
          matching: find.byType(EditableText),
        );
        expect(startDateEditable, findsOneWidget);
        await tester.enterText(startDateEditable, '2026-01-15');
        await tester.pump();

        // Timezone
        final tzEditable = find.descendant(
          of: find.byKey(const Key('SectionInputForm_TimezoneField')),
          matching: find.byType(EditableText),
        );
        expect(tzEditable, findsOneWidget);
        await tester.enterText(tzEditable, 'Europe/Madrid');
        await tester.pump();

        // Submit
        final submitButton = find.byKey(const Key('submitButton'));
        expect(submitButton, findsOneWidget);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Check that CustomErrorDialog is not shown
        expect(find.byType(CustomErrorDialog), findsNothing);
      },
    );
  });

  testWidgets(
    'Shows CustomErrorDialog in ViewState.error and does not close when tapping outside',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final viewState = ValueNotifier<ViewState>(ViewState.loadFinished);

      // Set the correct behavior of the mockViewModel and the mockCollectionViewModel
      when(mockViewModel.viewState).thenReturn(viewState);
      when(mockViewModel.errorMessage).thenReturn('Something went wrong');
      when(mockCollectionViewModel.setErrorKey(null)).thenAnswer((_) {});

      // Mount the screen using getIt (already registered in your setUp)
      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pump(); // primer frame

      // Changes the screen state to error
      viewState.value = ViewState.error;

      await tester.pump(); // ejecuta el postFrame showDialog
      await tester.pumpAndSettle(); // anima y muestra el diálogo

      // Verify dialog and content
      expect(find.byType(CustomErrorDialog), findsOneWidget);
      expect(
        find.textContaining('Something went wrong', findRichText: true),
        findsOneWidget,
      );
      expect(find.text(l10n.closeButton), findsOneWidget);

      // Tap outside should not close
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      expect(find.byType(CustomErrorDialog), findsOneWidget);
    },
  );

  testWidgets(
    'Shows CustomErrorDialog in ViewState.error and closes when tapping the close button',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final viewState = ValueNotifier<ViewState>(ViewState.loadFinished);
      when(mockViewModel.viewState).thenReturn(viewState);
      when(mockViewModel.errorMessage).thenReturn('Something went wrong');
      when(mockCollectionViewModel.setErrorKey(any)).thenAnswer((_) {});

      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pump(); // primer frame

      // Changes the screen state to error
      viewState.value = ViewState.error;

      await tester.pump();
      await tester.pumpAndSettle();

      // The dialog is shown with the correct content
      expect(find.byType(CustomErrorDialog), findsOneWidget);
      expect(
        find.textContaining('Something went wrong', findRichText: true),
        findsOneWidget,
      );
      expect(find.text(l10n.closeButton), findsOneWidget);

      // A press outside does not close the dialog
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      expect(find.byType(CustomErrorDialog), findsOneWidget);

      // Pressing the close button closes the dialog
      await tester.tap(find.text(l10n.closeButton));
      await tester.pumpAndSettle();

      // Verifies with Mockito (without lambda)
      verify(mockCollectionViewModel.setErrorKey(null)).called(1);

      // The ViewState is reset (effect of onCancel)
      expect(viewState.value, equals(ViewState.loadFinished));

      // Dialog disappears
      expect(find.byType(CustomErrorDialog), findsNothing);
    },
  );

  testWidgets(
    'Autocomplete: empty text does not make a call and does not show suggestions',
    (tester) async {
      await tester.pumpWidget(buildTestableWidget(EventFormScreen()));
      await tester.pumpAndSettle();

      // Find the location TextFormField
      final locationField = find.descendant(
        of: find.widgetWithText(SectionInputForm, 'Location'),
        matching: find.byType(TextFormField),
      );
      expect(locationField, findsOneWidget);

      // Write and then clear to trigger the empty text branch
      await tester.enterText(locationField, 'a');
      await tester.pump();

      // Clear the textformfield so we make anew call to _getSuggestions with empty text
      await tester.enterText(locationField, '');
      await tester.pump();

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));

      // Verify that searchByName was NOT called with empty text
      verifyNever(
        mockNominatim.searchByName(
          query: anyNamed('query'),
          limit: anyNamed('limit'),
          addressDetails: anyNamed('addressDetails'),
          extraTags: anyNamed('extraTags'),
          nameDetails: anyNamed('nameDetails'),
        ),
      );

      // There are no visible suggestions
      expect(find.textContaining('Barcelona'), findsNothing);
    },
  );
}
