import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsors_screen.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../mocks.mocks.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockSponsorViewModel mockViewModel;

  setUp(() async {
    await getIt.reset();
    mockViewModel = MockSponsorViewModel();
    getIt.registerSingleton<SponsorViewModel>(mockViewModel);

    when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockViewModel.sponsors).thenReturn(ValueNotifier([]));
    when(mockViewModel.errorMessage).thenReturn('');
    when(mockViewModel.checkToken()).thenAnswer((_) async => false);
    when(mockViewModel.setup(any)).thenAnswer((_) async {});
  });

  group('SponsorsScreen', () {
    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      when(mockViewModel.viewState).thenReturn(ValueNotifier(ViewState.isLoading));

      await tester.pumpWidget(buildTestableWidget(SponsorsScreen(eventId: '1')));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no data screen when there are no sponsors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(SponsorsScreen(eventId: '1')));
      await tester.pumpAndSettle();

      expect(find.text('No sponsors registered'), findsOneWidget);
    });

    testWidgets('shows sponsor grid when sponsors are available', (WidgetTester tester) async {
      final sponsors = [
        Sponsor(uid: '1', name: 'Sponsor 1', type: 'gold', logo: '', website: '', eventUID: '1'),
      ];
      when(mockViewModel.sponsors).thenReturn(ValueNotifier(sponsors));

      await tester.pumpWidget(buildTestableWidget(SponsorsScreen(eventId: '1')));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Sponsor 1'), findsOneWidget);
    });
    testWidgets('edit sponsor', (WidgetTester tester) async {
      final sponsors = [
        Sponsor(uid: '1', name: 'Sponsor 1', type: 'gold', logo: '', website: '', eventUID: '1'),
      ];
      when(mockViewModel.sponsors).thenReturn(ValueNotifier(sponsors));
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget(SponsorsScreen(eventId: '1')));
      await tester.pumpAndSettle();


      var editButton = find.byKey(Key("icon_button_sponsor_edit"));
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Sponsor 1'), findsOneWidget);
    });
    testWidgets('delete sponsor', (WidgetTester tester) async {
      final sponsors = [
        Sponsor(uid: '1', name: 'Sponsor 1', type: 'gold', logo: '', website: '', eventUID: '1'),
        Sponsor(uid: '2', name: 'Sponsor 2', type: 'gold', logo: '', website: '', eventUID: '1'),
      ];
      when(mockViewModel.sponsors).thenReturn(ValueNotifier(sponsors));
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget(SponsorsScreen(eventId: '1')));
      await tester.pumpAndSettle();

      expect(find.text('Sponsor 2'), findsOneWidget);

      var removeButton = find.byKey(Key("icon_button_sponsor_delete")).last;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();
      var removeDialogButton = find.byKey(Key("button_delete"));
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(removeDialogButton);
      await tester.pumpAndSettle();

      verify(mockViewModel.removeSponsor('2')).called(1);

    });
    testWidgets('cancelling sponsor deletion does not remove sponsor', (WidgetTester tester) async {
      final sponsors = [
        Sponsor(uid: '1', name: 'Sponsor 1', type: 'gold', logo: '', website: '', eventUID: '1'),
      ];
      when(mockViewModel.sponsors).thenReturn(ValueNotifier(sponsors));
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget(SponsorsScreen(eventId: '1')));
      await tester.pumpAndSettle();

      var removeButton = find.byKey(const Key("icon_button_sponsor_delete")).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      var cancelButton = find.text('Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);

      expect(find.text('Sponsor 1'), findsOneWidget);
      verifyNever(mockViewModel.removeSponsor(any));
    });
    testWidgets('admin can see edit and delete buttons', (WidgetTester tester) async {
      final sponsors = [
        Sponsor(uid: '1', name: 'Sponsor 1', type: 'gold', logo: '', website: '', eventUID: '1'),
      ];
      when(mockViewModel.sponsors).thenReturn(ValueNotifier(sponsors));
      when(mockViewModel.checkToken()).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget(SponsorsScreen(eventId: '1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outlined), findsOneWidget);
    });
  });
}
