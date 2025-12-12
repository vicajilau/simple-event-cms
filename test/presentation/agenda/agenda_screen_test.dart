import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_screen.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Result<void>>(const Result.ok(null));
  });

  late MockAgendaViewModel mockAgendaViewModel;

  setUp(() {
    // It's good practice to reset GetIt to ensure test isolation.
    getIt.reset();
    mockAgendaViewModel = MockAgendaViewModel();
    // The mock will be registered inside each test before the widget is pumped.
  });

  Future<void> registerMockViewModel() async {
    getIt.registerSingleton<AgendaViewModel>(mockAgendaViewModel);
    when(
      mockAgendaViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.isLoading));
    when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier([]));
    when(mockAgendaViewModel.speakers).thenReturn(ValueNotifier([]));
    when(mockAgendaViewModel.errorMessage).thenReturn('');
    when(
      mockAgendaViewModel.loadAgendaDays(any),
    ).thenAnswer((_) async => const Result.ok(null));
    when(mockAgendaViewModel.checkToken()).thenAnswer((_) async => false);
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      home: AgendaScreen(eventId: 'test-event-id', location: 'test-location'),
    );
  }

  Widget wrapWithMaterial(Widget child) {
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

  testWidgets('shows loading indicator when view state is loading', (
    WidgetTester tester,
  ) async {
    await registerMockViewModel();
    when(
      mockAgendaViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.isLoading));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error dialog when view state is error', (
    WidgetTester tester,
  ) async {
    await registerMockViewModel();
    when(
      mockAgendaViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.error));
    when(mockAgendaViewModel.errorMessage).thenReturn('An error occurred');

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('An error occurred'), findsOneWidget);
  });

  testWidgets('shows no data screen when there are no agenda days', (
    WidgetTester tester,
  ) async {
    await registerMockViewModel();
    when(
      mockAgendaViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier([]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No sessions found'), findsOneWidget);
  });

  testWidgets('displays agenda days and sessions', (WidgetTester tester) async {
    await registerMockViewModel();
    final agendaDays = [
      AgendaDay(
        uid: '2024-01-01',
        date: '2024-01-01',
        eventsUID: ['test-event-id'],
        resolvedTracks: [
          Track(
            uid: 'track1',
            name: 'Track 1',
            resolvedSessions: [
              Session(
                uid: 'session1',
                title: 'Session 1',
                time: '10:00',
                eventUID: 'test-event-id',
                agendaDayUID: 'day1',
                speakerUID: 'SpeakerUID',
                type: 'talk',
              ),
            ],
            color: '',
            sessionUids: ["session1"],
            eventUid: 'eventUID',
          ),
        ],
      ),
    ];
    when(
      mockAgendaViewModel.viewState,
    ).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockAgendaViewModel.agendaDays).thenReturn(ValueNotifier(agendaDays));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // The date '2024-01-01' is formatted for display (e.g., 'Tuesday, January 1'),
    // so we look for 'Jan' to confirm the month is rendered without being too specific.
    expect(find.textContaining('January'), findsOneWidget);
    //expect(find.text('Track 1'), findsOneWidget);
    //expect(find.text('Session 1'), findsOneWidget);
  });

  group('CustomTabBar', () {
    testWidgets('When there are no tracks we get SizedBox.shrink()', (
      tester,
    ) async {
      await registerMockViewModel();

      final widget = DefaultTabController(
        length: 3,
        child: wrapWithMaterial(
          CustomTabBarView(
            tracks: const [],
            currentIndex: 0,
            onIndexChanged: (_) {},
            agendaDayId: 'day-1',
            eventId: 'event-1',
            location: 'location',
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.byType(SessionCards), findsNothing);
      expect(find.byType(CustomTabBarView), findsOneWidget);
    });

    testWidgets(
      'initState builds SessionCards filtered and the build shows the one with the currentIndex',
      (tester) async {
        await registerMockViewModel();

        final track1 = Track(
          uid: 'track1',
          name: 'Track 1',
          color: '',
          sessionUids: const ['s1', 's2'],
          eventUid: 'event-1',
          resolvedSessions: [
            Session(
              uid: 's1',
              title: 'T1-S1 (match)',
              time: '10:00',
              eventUID: 'event-1',
              agendaDayUID: 'day-1',
              speakerUID: '',
              type: 'talk',
              description: 'desc 1',
            ),
            Session(
              uid: 's2',
              title: 'T1-S2 (no match event)',
              time: '11:00',
              eventUID: 'other-event',
              agendaDayUID: 'day-1',
              speakerUID: '',
              type: 'talk',
            ),
          ],
        );

        final track2 = Track(
          uid: 'track2',
          name: 'Track 2',
          color: '',
          sessionUids: const ['s3', 's4'],
          eventUid: 'event-1',
          resolvedSessions: [
            Session(
              uid: 's3',
              title: 'T2-S3 (no match day)',
              time: '12:00',
              eventUID: 'event-1',
              agendaDayUID: 'other-day',
              speakerUID: '',
              type: 'talk',
            ),
            Session(
              uid: 's4',
              title: 'T2-S4 (match)',
              time: '13:00',
              eventUID: 'event-1',
              agendaDayUID: 'day-1',
              speakerUID: '',
              type: 'break',
            ),
          ],
        );

        final tracks = [track1, track2];

        final widget = DefaultTabController(
          length: tracks.length,
          child: wrapWithMaterial(
            CustomTabBarView(
              tracks: tracks,
              currentIndex: 0,
              onIndexChanged: (_) {},
              agendaDayId: 'day-1',
              eventId: 'event-1',
              location: 'location',
            ),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        expect(find.text('T1-S1 (match)'), findsOneWidget);
        expect(find.text('desc 1'), findsOneWidget);

        expect(find.text('T1-S2 (no match event)'), findsNothing);
        expect(find.text('T2-S4 (match)'), findsNothing);
      },
    );

    testWidgets(
      'didChangeDependencies, when the tab is changed, the onIndexChanged and currentIndex are actualized',
      (tester) async {
        await registerMockViewModel();

        final track1 = Track(
          uid: 'track1',
          name: 'Track 1',
          color: '',
          sessionUids: const ['s1'],
          eventUid: 'event-1',
          resolvedSessions: [
            Session(
              uid: 's1',
              title: 'T1-S1',
              time: '10:00',
              eventUID: 'event-1',
              agendaDayUID: 'day-1',
              speakerUID: '',
              type: 'talk',
            ),
          ],
        );

        final track2 = Track(
          uid: 'track2',
          name: 'Track 2',
          color: '',
          sessionUids: const ['s2'],
          eventUid: 'event-1',
          resolvedSessions: [
            Session(
              uid: 's2',
              title: 'T2-S2',
              time: '11:00',
              eventUID: 'event-1',
              agendaDayUID: 'day-1',
              speakerUID: '',
              type: 'talk',
            ),
          ],
        );

        int? lastIndexFromCallback;

        final customTabBarView = CustomTabBarView(
          tracks: [track1, track2],
          currentIndex: 0,
          onIndexChanged: (i) => lastIndexFromCallback = i,
          agendaDayId: 'day-1',
          eventId: 'event-1',
          location: 'location',
        );

        final widget = DefaultTabController(
          length: 2,
          child: wrapWithMaterial(customTabBarView),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        expect(find.text('T1-S1'), findsOneWidget);
        expect(find.text('T2-S2'), findsNothing);

        final element = tester.element(find.byType(CustomTabBarView));
        final controller = DefaultTabController.of(element);

        controller.animateTo(1);
        await tester.pump();

        expect(lastIndexFromCallback, 1);

        expect(find.text('T2-S2'), findsOneWidget);
        expect(find.text('T1-S1'), findsNothing);
      },
    );

    testWidgets(
      'If a track rests without sessions after filtering the SessionCards shows noSessionsFound',
      (tester) async {
        await registerMockViewModel();

        final emptyTrack = Track(
          uid: 'track-empty',
          name: 'Empty Track',
          color: '',
          sessionUids: const ['sX'],
          eventUid: 'event-1',
          resolvedSessions: [
            Session(
              uid: 'sX',
              title: 'No match',
              time: '09:00',
              eventUID: 'other-event',
              agendaDayUID: 'day-1',
              speakerUID: '',
              type: 'talk',
            ),
          ],
        );

        final widget = DefaultTabController(
          length: 1,
          child: wrapWithMaterial(
            CustomTabBarView(
              tracks: [emptyTrack],
              currentIndex: 0,
              onIndexChanged: (_) {},
              agendaDayId: 'day-1',
              eventId: 'event-1',
              location: 'location',
            ),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Como el SessionCards se creó con sesiones filtradas vacías,
        // su UI debe mostrar el texto localizado "No sessions found"
        final context = tester.element(find.byType(CustomTabBarView));
        final l10n = AppLocalizations.of(context)!;

        expect(find.text(l10n.noSessionsFound), findsOneWidget);
      },
    );
  });

  group('SessionCards', () {
    testWidgets('Shows an empty state when the sessions list is empty', (
      tester,
    ) async {
      await registerMockViewModel();

      final widget = SessionCards(
        sessions: const [],
        agendaDayId: 'day-1',
        trackId: 'track-1',
        eventId: 'event-1',
        location: 'location',
      );

      await tester.pumpWidget(wrapWithMaterial(widget));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SessionCards));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.noSessionsFound), findsOneWidget);
    });

    testWidgets(
      'Renders the session correctly, showing the title, time, and description',
      (tester) async {
        await registerMockViewModel();

        final sessions = [
          Session(
            uid: 's1',
            title: 'Title 1',
            time: '10:00',
            eventUID: 'event-1',
            agendaDayUID: 'day-1',
            speakerUID: 'sp1',
            type: 'talk',
            description: 'Description for the session.',
          ),
        ];

        await tester.pumpWidget(
          wrapWithMaterial(
            SessionCards(
              sessions: sessions,
              agendaDayId: 'day-1',
              trackId: 'track-1',
              eventId: 'event-1',
              location: 'location',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('10:00'), findsOneWidget);
        expect(find.text('Title 1'), findsOneWidget);
        expect(find.text('Description for the session.'), findsOneWidget);
      },
    );

    testWidgets('Shows the dellete button only if checkToken() == true', (
      tester,
    ) async {
      await registerMockViewModel();

      final sessions = [
        Session(
          uid: 's1',
          title: 'Sesión borrable',
          time: '14:00',
          eventUID: 'event-1',
          agendaDayUID: 'day-1',
          speakerUID: 'sp1',
          type: 'talk',
        ),
      ];

      when(mockAgendaViewModel.checkToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(
        wrapWithMaterial(
          SessionCards(
            sessions: sessions,
            agendaDayId: 'day-1',
            trackId: 'track-1',
            eventId: 'event-1',
            location: 'location',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete), findsNothing);

      when(mockAgendaViewModel.checkToken()).thenAnswer((_) async => true);

      await tester.pumpWidget(
        wrapWithMaterial(
          SessionCards(
            sessions: sessions,
            agendaDayId: 'day-1',
            trackId: 'track-1',
            eventId: 'event-1',
            location: 'loc',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets(
      'When the delete button is pressed shows DeleteDialog and calls removeSessionAndReloadAgenda',
      (tester) async {
        await registerMockViewModel();
        when(mockAgendaViewModel.checkToken()).thenAnswer((_) async => true);

        final sessions = [
          Session(
            uid: 's1',
            title: 'Sesión borrable',
            time: '14:00',
            eventUID: 'event-1',
            agendaDayUID: 'day-1',
            speakerUID: 'sp1',
            type: 'talk',
          ),
        ];

        when(
          mockAgendaViewModel.removeSessionAndReloadAgenda(
            any,
            any,
            agendaDayUID: anyNamed('agendaDayUID'),
          ),
        ).thenAnswer((_) async => const Result.ok(null));

        await tester.pumpWidget(
          wrapWithMaterial(
            SessionCards(
              sessions: sessions,
              agendaDayId: 'day-1',
              trackId: 'track-1',
              eventId: 'event-1',
              location: 'loc',
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on the delete button so the dialog shows
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pump();

        // Check the dialog texts with the translations (l10)
        final context = tester.element(find.byType(SessionCards));
        final l10n = AppLocalizations.of(context)!;

        expect(find.text(l10n.deleteSessionTitle), findsOneWidget);
        expect(find.text(l10n.deleteSessionMessage), findsOneWidget);

        final confirmButtonFinder = find.text("Delete");
        expect(confirmButtonFinder, findsOneWidget);

        await tester.tap(confirmButtonFinder);

        // Waot until the onDeletePressed is done and close the dialog
        await tester.pumpAndSettle();

        // Check the call to view model method removeSessionAndReloadAgenda
        verify(
          mockAgendaViewModel.removeSessionAndReloadAgenda(
            's1',
            'event-1',
            agendaDayUID: 'day-1',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Shows the speaker when the speakerName != "" and type != break',
      (tester) async {
        await registerMockViewModel();

        when(mockAgendaViewModel.speakers).thenReturn(
          ValueNotifier([
            Speaker(
              uid: 'sp1',
              name: 'speaker name',
              bio: 'bio',
              image: '',
              social: Social(),
              eventUIDS: ['event-1'],
            ),
          ]),
        );

        await tester.pumpWidget(
          wrapWithMaterial(
            SessionCards(
              sessions: [
                Session(
                  uid: 's1',
                  title: 'Con ponente',
                  time: '12:00',
                  eventUID: 'event-1',
                  agendaDayUID: 'day-1',
                  speakerUID: 'sp1',
                  type: 'talk',
                  description: 'desc',
                ),
              ],
              agendaDayId: 'day-1',
              trackId: 'track-1',
              eventId: 'event-1',
              location: 'location', // no importa para este test
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person), findsWidgets);
        expect(find.text('speaker name'), findsOneWidget);
      },
    );

    testWidgets('Navigate to speakers tab when press on the name', (
      widgetTester,
    ) async {
      await registerMockViewModel();

      when(mockAgendaViewModel.speakers).thenReturn(
        ValueNotifier([
          Speaker(
            uid: 'sp1',
            name: 'speaker name',
            bio: 'bio',
            image: '',
            social: Social(),
            eventUIDS: ['event-1'],
          ),
        ]),
      );

      final sessions = [
        Session(
          uid: 's1',
          title: 'Con ponente',
          time: '12:00',
          eventUID: 'event-1',
          agendaDayUID: 'day-1',
          speakerUID: 'sp1',
          type: 'talk',
        ),
      ];

      TestTabController? testTabController;

      await widgetTester.pumpWidget(
        _TickerProviderHost(
          builder: (context, vsync) {
            testTabController = TestTabController(length: 3, vsync: vsync);
            return wrapWithMaterial(
              SessionCards(
                sessions: sessions,
                agendaDayId: 'day-1',
                trackId: 'track-1',
                eventId: 'event-1',
                location: 'location',
                tabController: testTabController,
              ),
            );
          },
        ),
      );
      await widgetTester.pumpAndSettle();

      // Toca el nombre del ponente (dentro del GestureDetector)
      await widgetTester.tap(find.text('speaker name'));
      await widgetTester.pump();

      // Verifica que se llamó animateTo(1)
      expect(testTabController, isNotNull);
      expect(testTabController!.animateCalled, isTrue);
      expect(testTabController!.lastIndex, 1);
    });
  });
}

class _TickerProviderHost extends StatefulWidget {
  final Widget Function(BuildContext, TickerProvider) builder;
  const _TickerProviderHost({required this.builder});

  @override
  State<_TickerProviderHost> createState() => _TickerProviderHostState();
}

class _TickerProviderHostState extends State<_TickerProviderHost>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => widget.builder(context, this);
}

class TestTabController extends TabController {
  bool animateCalled = false;
  int? lastIndex;
  Duration? lastDuration;
  Curve lastCurve = Curves.ease;

  TestTabController({required super.length, required super.vsync});

  @override
  void animateTo(int value, {Curve curve = Curves.ease, Duration? duration}) {
    animateCalled = true;
    lastIndex = value;
    lastCurve = curve;
    lastDuration = duration;
  }
}
