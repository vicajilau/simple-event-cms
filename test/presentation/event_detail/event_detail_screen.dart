
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_screen.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_screen.dart';
import 'package:sec/presentation/ui/screens/speaker/speakers_screen.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsors_screen.dart';

import '../../mocks.mocks.dart';

// Mocking screens to avoid their internal dependencies
class MockAgendaScreen extends StatelessWidget {
  const MockAgendaScreen({super.key});
  @override
  Widget build(BuildContext context) => const Text('Mock Agenda Screen');
}

class MockSpeakersScreen extends StatelessWidget {
  const MockSpeakersScreen({super.key});
  @override
  Widget build(BuildContext context) => const Text('Mock Speakers Screen');
}

class MockSponsorsScreen extends StatelessWidget {
  const MockSponsorsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Text('Mock Sponsors Screen');
}
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

@GenerateMocks([EventDetailViewModel, AgendaScreen, SpeakersScreen, SponsorsScreen])
void main() {
  late MockEventDetailViewModel mockViewModel;

  setUp(() {
    getIt.reset();
    mockViewModel = MockEventDetailViewModel();
    getIt.registerSingleton<EventDetailViewModel>(mockViewModel);

    when(mockViewModel.setup(any)).thenAnswer((_) async {});
    when(mockViewModel.notShowReturnArrow).thenReturn(ValueNotifier(false));
    when(mockViewModel.eventTitle).thenReturn(ValueNotifier('Test Event'));
    when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.checkToken()).thenAnswer((_) async => false);
    when(mockViewModel.errorMessage).thenReturn('Error occurred');
    when(mockViewModel.dispose()).thenAnswer((_) {});
  });


  // Helper to inject mock screens into the state
  void setMockScreens(State<EventDetailScreen> state) {
    final stateObject = state as dynamic;
    stateObject.screens = [
      const MockAgendaScreen(),
      const MockSpeakersScreen(),
      const MockSponsorsScreen(),
    ];
  }


  testWidgets('EventDetailScreen should render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget((EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    ))));

    // Find the state and inject mocks before settling
    final state = tester.state<State<EventDetailScreen>>(find.byType(EventDetailScreen));
    setMockScreens(state);

    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Speakers'), findsOneWidget);
    expect(find.text('Sponsors'), findsOneWidget);
    expect(find.text('Test Event'), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.text('Mock Agenda Screen'), findsOneWidget);
  });

  testWidgets('Should show loading indicator when view state is isLoading', (WidgetTester tester) async {
    when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.isLoading));

    await tester.pumpWidget(buildTestableWidget((EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    ))));
    final state = tester.state<State<EventDetailScreen>>(find.byType(EventDetailScreen));
    setMockScreens(state);
    await tester.pump(); // First pump for FutureBuilder

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('Should show error dialog when view state is error', (WidgetTester tester) async {
    when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.error));

    await tester.pumpWidget(buildTestableWidget((EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    ))));
    final state = tester.state<State<EventDetailScreen>>(find.byType(EventDetailScreen));
    setMockScreens(state);
    await tester.pumpAndSettle();

    expect(find.byType(CustomErrorDialog), findsOneWidget);
    expect(find.text('Error occurred'), findsOneWidget);
  });

  testWidgets('Tapping on tabs should switch views', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget((EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    ))));
    final state = tester.state<State<EventDetailScreen>>(find.byType(EventDetailScreen));
    setMockScreens(state);
    await tester.pumpAndSettle();

    expect(find.text('Mock Agenda Screen'), findsOneWidget);

    await tester.tap(find.text('Speakers'));
    await tester.pumpAndSettle();
    expect(find.text('Mock Speakers Screen'), findsOneWidget);

    await tester.tap(find.text('Sponsors'));
    await tester.pumpAndSettle();
    expect(find.text('Mock Sponsors Screen'), findsOneWidget);
  });

  testWidgets('Add button should be visible and text should change with tab selection when token exists', (WidgetTester tester) async {
    when(mockViewModel.checkToken()).thenAnswer((_) async => true);

    await tester.pumpWidget(buildTestableWidget((EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    ))));
    final state = tester.state<State<EventDetailScreen>>(find.byType(EventDetailScreen));
    setMockScreens(state);
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
    when(mockViewModel.notShowReturnArrow).thenReturn(ValueNotifier(true));

    await tester.pumpWidget(buildTestableWidget((EventDetailScreen(
      eventId: '1',
      location: 'Test Location',
    ))));
    final state = tester.state<State<EventDetailScreen>>(find.byType(EventDetailScreen));
    setMockScreens(state);
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
  });
}
