import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_screen.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_screen.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speakers_screen.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsors_screen.dart';

import '../../mocks.mocks.dart';

// Helper to build the widget tree needed for the test
Widget buildTestableWidget(Widget child) {
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
    home: child,
  );
}

void main() {
  // CHANGE 2: Declare mocks for ALL the ViewModels we are going to use.
  late MockEventDetailViewModel mockDetailViewModel;
  late MockAgendaViewModel mockAgendaViewModel;
  late MockSpeakerViewModel mockSpeakersViewModel;
  late MockSponsorViewModel mockSponsorsViewModel;

  setUp(() {
    getIt.reset();

    // CHANGE 3: Instantiate and register ALL mocks in the dependency injector (getIt).
    // This way, when each screen tries to get its ViewModel, it will receive the corresponding mock.

    // Mock for the main ViewModel
    mockDetailViewModel = MockEventDetailViewModel();
    getIt.registerSingleton<EventDetailViewModel>(mockDetailViewModel);

    // Mocks for the child screens' ViewModels
    mockAgendaViewModel = MockAgendaViewModel();
    getIt.registerSingleton<AgendaViewModel>(mockAgendaViewModel);

    mockSpeakersViewModel = MockSpeakerViewModel();
    getIt.registerSingleton<SpeakerViewModel>(mockSpeakersViewModel);

    mockSponsorsViewModel = MockSponsorViewModel();
    getIt.registerSingleton<SponsorViewModel>(mockSponsorsViewModel);

    // CHANGE 4: Configure the default behavior of ALL mocks.
    // This prevents them from failing when trying to access null properties.

    // Configuration for EventDetailViewModel
    when(mockDetailViewModel.setup(any)).thenAnswer((_) async {});
    when(mockDetailViewModel.notShowReturnArrow).thenReturn(ValueNotifier(false));
    when(mockDetailViewModel.eventTitle).thenReturn(ValueNotifier('Test Event'));
    when(mockDetailViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockDetailViewModel.checkToken()).thenAnswer((_) async => false);
    when(mockDetailViewModel.errorMessage).thenReturn('Error occurred');
    when(mockDetailViewModel.dispose()).thenAnswer((_) {});

    // Configuration for AgendaViewModel (basic values to prevent failure)
    when(mockAgendaViewModel.setup(any)).thenAnswer((_) async {});
    when(mockAgendaViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockAgendaViewModel.dispose()).thenAnswer((_) {});


    // Configuration for SpeakersViewModel
    when(mockSpeakersViewModel.setup(any)).thenAnswer((_) async {});
    when(mockSpeakersViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockSpeakersViewModel.speakers).thenReturn(ValueNotifier([]));
    when(mockSpeakersViewModel.dispose()).thenAnswer((_) {});



  });

  // CHANGE 5: Completely remove the 'setMockScreens' helper and the 'Mock...Screen' classes.
  // They are no longer necessary because we are going to render the real widgets.

  testWidgets('EventDetailScreen should render correctly', (WidgetTester tester) async {
    // NOW: We simply build the widget and let pumpAndSettle do its job.
    // The real widget and its real children will be built using the mocked ViewModels.
    await tester.pumpWidget(buildTestableWidget(EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    )));
    await tester.pumpAndSettle();

    // The assertions can now look for the real widget types.
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Speakers'), findsOneWidget);
    expect(find.text('Sponsors'), findsOneWidget);
    expect(find.text('Test Event'), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    // We verify that the real Agenda screen is in the widget tree.
    expect(find.byType(AgendaScreen), findsOneWidget);
  });

  testWidgets('Should show loading indicator when view state is isLoading', (WidgetTester tester) async {
    when(mockDetailViewModel.viewState).thenReturn(ValueNotifier(ViewState.isLoading));

    await tester.pumpWidget(buildTestableWidget(EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    )));
    // We don't need `pumpAndSettle` here, just a `pump` for the FutureBuilder to update.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should show error dialog when view state is error', (WidgetTester tester) async {
    when(mockDetailViewModel.viewState).thenReturn(ValueNotifier(ViewState.error));

    await tester.pumpWidget(buildTestableWidget(EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    )));
    await tester.pumpAndSettle();

    expect(find.byType(CustomErrorDialog), findsOneWidget);
    expect(find.text('Error occurred'), findsOneWidget);
  });

  testWidgets('Tapping on tabs should switch views', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    )));
    await tester.pumpAndSettle();

    // The first visible tab is AgendaScreen
    expect(find.byType(AgendaScreen), findsOneWidget);
    expect(find.byType(SpeakersScreen), findsNothing);

    // Tap the "Speakers" tab
    await tester.tap(find.text('Speakers'));
    await tester.pumpAndSettle();
    // Now SpeakersScreen should be visible and AgendaScreen should not.
    expect(find.byType(AgendaScreen), findsNothing);
    expect(find.byType(SpeakersScreen), findsOneWidget);

    // Tap the "Sponsors" tab
    await tester.tap(find.text('Sponsors'));
    await tester.pumpAndSettle();
    // Now SponsorsScreen should be visible.
    expect(find.byType(SpeakersScreen), findsNothing);
    expect(find.byType(SponsorsScreen), findsOneWidget);
  });

  testWidgets('Add button should be visible and text should change with tab selection when token exists', (WidgetTester tester) async {
    when(mockDetailViewModel.checkToken()).thenAnswer((_) async => true);

    await tester.pumpWidget(buildTestableWidget(EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    )));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Add Session'), findsOneWidget);

    await tester.tap(find.text('Speakers'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Add Speaker'), findsOneWidget);

    await tester.tap(find.text('Sponsors'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Add Sponsor'), findsOneWidget);
  });

  testWidgets('Back button is not shown when notShowReturnArrow is true', (WidgetTester tester) async {
    when(mockDetailViewModel.notShowReturnArrow).thenReturn(ValueNotifier(true));

    await tester.pumpWidget(buildTestableWidget(EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    )));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
  });
}
