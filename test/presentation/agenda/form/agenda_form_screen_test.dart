import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/core/models/event.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_screen.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_form_screen.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAgendaFormViewModel mockViewModel;

  final String eventId = 'event1';
  final agendaDay = AgendaDay(
    uid: 'day1',
    date: '2024-01-01',
    eventsUID: ['event1'],
  );
  final track = Track(
    uid: 'track1',
    name: 'Track 1',
    sessionUids: [],
    eventUid: 'event1',
    color: '',
    resolvedSessions: [],
  );
  final speaker = Speaker(
    uid: 'speaker1',
    name: 'Speaker 1',
    bio: '',
    image: '',
    social: Social(),
    eventUIDS: ['event1'],
  );
  final event = Event(
    uid: 'event1',
    tracks: [track],
    eventName: '',
    year: '',
    primaryColor: '',
    secondaryColor: '',
    eventDates: MockEventDates(),
  );
  final session = Session(
    uid: 'session1',
    title: 'Session 1',
    eventUID: eventId,
    agendaDayUID: 'day1',
    speakerUID: 'speaker1',
    type: 'talk',
    description: 'description',
    time: '',
  );

  setUpAll(() async {
    await getIt.reset(); // ADDED
    mockViewModel = MockAgendaFormViewModel();
    getIt.registerSingleton<AgendaFormViewModel>(mockViewModel);

    when(
      mockViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.isLoading));
    when(
      mockViewModel.getSpeakersForEventId(any),
    ).thenAnswer((_) async => [speaker]);
    when(
      mockViewModel.getTracksByEventId(any),
    ).thenAnswer((_) async => [track]);
    when(
      mockViewModel.getAgendaDayByEventId(any),
    ).thenAnswer((_) async => [agendaDay]);
    when(mockViewModel.getEventById(any)).thenAnswer((_) async => event);
    when(
      mockViewModel.saveSession(
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
      ),
    ).thenAnswer((_) async => [agendaDay]);
  });

  Widget createWidgetUnderTest({required AgendaFormData data}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      home: AgendaFormScreen(data: data),
    );
  }

  group('AgendaFormData copyWith', () {
    test('The copyWith method should update only the provided fields', () {
      final original = AgendaFormData(
        session: session,
        trackId: 'track1',
        agendaDayId: 'day1',
        eventId: 'event1',
      );

      final updated = original.copyWith(trackId: 'track2');

      expect(updated.trackId, equals('track2'));
      expect(updated.session, equals(original.session));
      expect(updated.agendaDayId, equals(original.agendaDayId));
      expect(updated.eventId, equals(original.eventId));
    });

    test(
      'The copyWith method should keep original values when no params are passed',
      () {
        final original = AgendaFormData(
          session: session,
          trackId: 'track1',
          agendaDayId: 'day1',
          eventId: 'event1',
        );

        final copy = original.copyWith();

        expect(copy.session, equals(original.session));
        expect(copy.trackId, equals(original.trackId));
        expect(copy.agendaDayId, equals(original.agendaDayId));
        expect(copy.eventId, equals(original.eventId));
      },
    );

    test('The copyWith method should create a new instance', () {
      final original = AgendaFormData(eventId: eventId, trackId: 'track1');
      final copy = original.copyWith(trackId: 'track2');

      expect(copy, isNot(same(original)));
    });

    testWidgets('shows loading indicator when view state is loading', (
      WidgetTester tester,
    ) async {
      when(
        mockViewModel.viewState,
      ).thenReturn(ValueNotifier(ViewState.isLoading));
      await tester.pumpWidget(
        createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should add a new speaker when add button is pressed', (
      WidgetTester tester,
    ) async {
      when(
        mockViewModel.viewState,
      ).thenReturn(ValueNotifier(ViewState.loadFinished));

      when(mockViewModel.addSpeaker(any, any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
      );
      await tester.pumpAndSettle();

      // Find the add speaker button and tap it.
      final addButton = find.byKey(Key("add_speaker_button"));
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify that we have navigated to the SpeakerFormScreen
      expect(find.byType(SpeakerFormScreen), findsOneWidget);
    });

    testWidgets(
      'Shows CustomErrorDialog and when you press on close it is close and the state ys cleaned',
      (tester) async {
        // Set the state to error and the error message
        when(
          mockViewModel.viewState,
        ).thenReturn(ValueNotifier<ViewState>(ViewState.error));
        when(mockViewModel.errorMessage).thenReturn('An error occurred');

        await tester.pumpWidget(
          createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        // Check if the dialog is showns and has the error text.
        expect(find.byType(CustomErrorDialog), findsOneWidget);
        expect(find.text('An error occurred'), findsOneWidget);

        // Close button localization
        final closeText = AppLocalizations.of(
          tester.element(find.byType(CustomErrorDialog)),
        )!.closeButton;

        // Press the close button
        expect(find.text(closeText), findsOneWidget);
        await tester.tap(find.text(closeText));
        await tester.pumpAndSettle();

        // Check if the dialog is closed
        expect(find.byType(CustomErrorDialog), findsNothing);

        // Check if the viewModel methods were called to clean the state
        verify(mockViewModel.setErrorKey(null)).called(1);
        expect(mockViewModel.viewState.value, equals(ViewState.loadFinished));
      },
    );

    testWidgets(
      'Does NOT show CustomErrorDialog when the state is diferente from ViewState.error',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(CustomErrorDialog), findsNothing);
      },
    );
  });

  group('TextInputField validator for the talks', () {
    testWidgets('Shows an error when the TextFormField is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
      );
      await tester.pump();

      // Find the TextFormField by key
      final textField = find.byKey(const Key('title_field'));
      expect(textField, findsOneWidget);

      // Enter empty text to trigger validation
      await tester.enterText(textField, '');
      await tester.pump();

      // Get the localized error message
      final talkTitleError = AppLocalizations.of(
        tester.element(textField),
      )!.talkTitleError;

      final fieldState = tester.state<FormFieldState<String>>(textField);
      final isFieldValid = fieldState.validate();
      expect(isFieldValid, isFalse);
      expect(fieldState.errorText, equals(talkTitleError));
    });

    testWidgets('Does not show error when the TextFormField has content', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
      );
      await tester.pump();

      // Find the TextFormField by key
      final textField = find.byKey(const Key('title_field'));
      expect(textField, findsOneWidget);

      // Enter empty text to trigger validation
      await tester.enterText(textField, 'Talk about Flutter');
      await tester.pump();

      final fieldState = tester.state<FormFieldState<String>>(textField);
      final isFieldValid = fieldState.validate();
      expect(isFieldValid, isTrue);
      expect(fieldState.errorText, isNull);
    });
  });

  testWidgets('Agenda day validator shows error when no day is selected', (
    tester,
  ) async {
    when(
      mockViewModel.getAgendaDayByEventId(any),
    ).thenAnswer((_) async => [agendaDay]);

    await tester.pumpWidget(
      createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
    );
    await tester.pump();

    // Finder of the dropdown
    final dropdownFinder = find.byKey(const Key('agenda_day_dropdown'));
    expect(dropdownFinder, findsOneWidget);

    // Form state
    final formState = tester.state<FormState>(find.byType(Form));

    // Validate the form without selecting a day
    final isValid = formState.validate();
    expect(isValid, isFalse);

    final selectDayError = AppLocalizations.of(
      tester.element(dropdownFinder),
    )!.selectDayError;

    // Verify the error message on the dropdown
    final fieldState = tester.state<FormFieldState<dynamic>>(dropdownFinder);
    expect(fieldState.errorText, equals(selectDayError));
  });

  testWidgets('Agenda day validator passes when a day is selected', (
    tester,
  ) async {
    when(
      mockViewModel.getAgendaDayByEventId(any),
    ).thenAnswer((_) async => [agendaDay]);

    await tester.pumpWidget(
      createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
    );
    await tester.pump();

    // Find the dropdown
    final dropdownFinder = find.byKey(const Key('agenda_day_dropdown'));
    expect(dropdownFinder, findsOneWidget);

    // Open the query dropdown
    await tester.tap(dropdownFinder);
    await tester.pump();

    // Select the agenda day on the dropdown
    await tester.tap(find.text(agendaDay.date).last);
    await tester.pump();

    //Check validation
    final fieldState = tester.state<FormFieldState<String>>(dropdownFinder);
    final isFieldValid = fieldState.validate();
    expect(isFieldValid, isTrue);
    expect(fieldState.errorText, isNull);
  });

  group('isTimeRangeValid', () {
    test('Returns false when both times are null', () {
      expect(isTimeRangeValid(null, null), isFalse);
    });

    test('Returns false when startTime is null', () {
      expect(
        isTimeRangeValid(null, const TimeOfDay(hour: 10, minute: 0)),
        isFalse,
      );
    });

    test('Returns false when endTime is null', () {
      expect(
        isTimeRangeValid(const TimeOfDay(hour: 9, minute: 0), null),
        isFalse,
      );
    });

    test('Returns true when startTime < endTime', () {
      final start = const TimeOfDay(hour: 9, minute: 0);
      final end = const TimeOfDay(hour: 10, minute: 0);
      expect(isTimeRangeValid(start, end), isTrue);
    });

    test('Returns false when startTime == endTime', () {
      final start = const TimeOfDay(hour: 9, minute: 0);
      final end = const TimeOfDay(hour: 9, minute: 0);
      expect(isTimeRangeValid(start, end), isFalse);
    });

    test('Returns false when startTime > endTime', () {
      final start = const TimeOfDay(hour: 11, minute: 0);
      final end = const TimeOfDay(hour: 10, minute: 0);
      expect(isTimeRangeValid(start, end), isFalse);
    });
  });

  group('Save button', () {
    testWidgets(
      'onPressed shows an error when the init time and the end time are missing and informing that you have to select both',
      (tester) async {
        // l10n para el assert del mensaje
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));

        await tester.pumpWidget(
          createWidgetUnderTest(data: AgendaFormData(eventId: eventId)),
        );
        await tester.pumpAndSettle();

        // Completa textos
        final titleField = find.byKey(const Key('title_field'));
        final descriptionField = find.byKey(const Key('description_field'));
        expect(titleField, findsOneWidget);
        expect(descriptionField, findsOneWidget);

        await tester.enterText(titleField, 'Titulo');
        await tester.enterText(descriptionField, 'Descripción');

        // -------- Día (<String>) --------
        final dayFinder = find.byKey(const Key('agenda_day_dropdown'));
        expect(dayFinder, findsOneWidget);

        final dayForm = tester.widget<DropdownButtonFormField<String>>(
          dayFinder,
        );
        final dayState = tester.state<FormFieldState<String>>(dayFinder);
        dayState.didChange('day1'); // satisface Form.validate()
        dayForm.onChanged?.call('day1'); // actualiza _selectedDay
        await tester.pump();

        // -------- Track (<String>) --------
        final trackFinder = find.byKey(const Key('room_dropdown'));
        expect(trackFinder, findsOneWidget);

        final trackForm = tester.widget<DropdownButtonFormField<String>>(
          trackFinder,
        );
        final trackState = tester.state<FormFieldState<String>>(trackFinder);
        trackState.didChange('track1'); // satisface Form.validate()
        trackForm.onChanged?.call('track1'); // actualiza _selectedTrackUid
        await tester.pump();

        // -------- Speaker (<Speaker>) --------
        final speakerFinder = find.byKey(const Key('speaker_dropdown'));
        expect(speakerFinder, findsOneWidget);

        final speakerForm = tester.widget<DropdownButtonFormField<Speaker>>(
          speakerFinder,
        );

        final speakerState = tester.state<FormFieldState<Speaker>>(
          speakerFinder,
        );
        speakerState.didChange(speaker);
        speakerForm.onChanged?.call(speaker);
        await tester.pump();

        final talkFinder = find.byKey(const Key('talk_type_dropdown'));
        expect(talkFinder, findsOneWidget);

        final talkForm = tester.widget<DropdownButtonFormField<String>>(
          talkFinder,
        );
        final talkState = tester.state<FormFieldState<String>>(talkFinder);

        // Uses the existing talk type from session
        talkState.didChange('talk');
        talkForm.onChanged?.call('talk');
        await tester.pump();

        // Invoke the Save button directly
        final saveFinder = find.byKey(const Key('save_session_button'));
        expect(saveFinder, findsOneWidget);
        final saveBtn = tester.widget<FilledButton>(saveFinder);
        saveBtn.onPressed?.call();

        await tester.pumpAndSettle();

        final errorFinder = find.byKey(const Key('time_error_text'));
        expect(errorFinder, findsOneWidget);

        final errorTextWidget = tester.widget<Text>(errorFinder);
        expect(errorTextWidget.data, equals(l10n.timeSelectionError));
      },
    );

    testWidgets(
      'onPressed shows an error when the end time is previous from the init time',
      (tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));

        await tester.pumpWidget(
          createWidgetUnderTest(data: AgendaFormData(eventId: 'event1')),
        );
        await tester.pumpAndSettle();

        final titleField = find.byKey(const Key('title_field'));
        final descriptionField = find.byKey(const Key('description_field'));
        expect(titleField, findsOneWidget);
        expect(descriptionField, findsOneWidget);

        await tester.enterText(titleField, 'Titulo');
        await tester.enterText(descriptionField, 'Descripción');

        final dayFinder = find.byKey(const Key('agenda_day_dropdown'));
        expect(dayFinder, findsOneWidget);
        final dayForm = tester.widget<DropdownButtonFormField<String>>(
          dayFinder,
        );
        final dayState = tester.state<FormFieldState<String>>(dayFinder);
        dayState.didChange('day1');
        dayForm.onChanged?.call('day1');
        await tester.pump();

        final trackFinder = find.byKey(const Key('room_dropdown'));
        expect(trackFinder, findsOneWidget);
        final trackForm = tester.widget<DropdownButtonFormField<String>>(
          trackFinder,
        );
        final trackState = tester.state<FormFieldState<String>>(trackFinder);
        trackState.didChange('track1');
        trackForm.onChanged?.call('track1');
        await tester.pump();

        final speakerFinder = find.byKey(const Key('speaker_dropdown'));
        expect(speakerFinder, findsOneWidget);
        final speakerForm = tester.widget<DropdownButtonFormField<Speaker>>(
          speakerFinder,
        );
        final speakerState = tester.state<FormFieldState<Speaker>>(
          speakerFinder,
        );
        speakerState.didChange(speaker);
        speakerForm.onChanged?.call(speaker);
        await tester.pump();

        final talkFinder = find.byKey(const Key('talk_type_dropdown'));
        expect(talkFinder, findsOneWidget);
        final talkForm = tester.widget<DropdownButtonFormField<String>>(
          talkFinder,
        );
        final talkState = tester.state<FormFieldState<String>>(talkFinder);
        talkState.didChange('talk');
        talkForm.onChanged?.call('talk');
        await tester.pump();

        // Helper for pressing accept button in the time picker
        Future<void> tapOkButton() async {
          final okEs = find.text('Aceptar');
          final okEn = find.text('OK');
          if (okEs.evaluate().isNotEmpty) {
            await tester.tap(okEs);
          } else if (okEn.evaluate().isNotEmpty) {
            await tester.tap(okEn);
          } else {
            throw TestFailure(
              'No se encontró botón OK/Aceptar en el time picker',
            );
          }
          await tester.pumpAndSettle();
        }

         // Open the start time picker and set it to 10:00
        final startPicker = find.byKey(const Key('start_time_picker'));
        await tester.ensureVisible(startPicker);
        await tester.tap(startPicker);
        await tester.pumpAndSettle();

        // Check that there are two TextFields 
        final startTextFields = find.byType(TextField);
        expect(startTextFields, findsNWidgets(2));

        await tester.enterText(startTextFields.at(0), '10'); // Hours
        await tester.enterText(startTextFields.at(1), '00'); // Minutes
        await tester.pump();

        await tapOkButton(); // Close the start time picker

        // Open the end time picker and set it to 09:30
        final endPicker = find.byKey(const Key('end_time_picker'));
        await tester.ensureVisible(endPicker);
        await tester.tap(endPicker);
        await tester.pumpAndSettle();

        final endTextFields = find.byType(TextField);
        expect(endTextFields, findsNWidgets(2));
        await tester.enterText(endTextFields.at(0), '09'); // Hours
        await tester.enterText(endTextFields.at(1), '30'); // Minutes
        await tester.pump();

        await tapOkButton(); // Close the end time picker

        expect(find.byKey(const Key('time_error_text')), findsOneWidget);
        expect(find.text(l10n.timeValidationError), findsOneWidget);
      },
    );
  });
}

bool isTimeRangeValid(TimeOfDay? startTime, TimeOfDay? endTime) {
  if (startTime == null || endTime == null) return false;

  final startMinutes = startTime.hour * 60 + startTime.minute;
  final endMinutes = endTime.hour * 60 + endTime.minute;

  return startMinutes < endMinutes;
}
