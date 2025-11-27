
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/config/config_screen.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/form_screen_wrapper.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    provideDummy<Result<void>>(const Result.ok(null));
  });

  late MockConfigViewModel mockConfigViewModel;
  late MockCheckOrg mockCheckOrg;

  setUp(() async {
    // It's good practice to reset GetIt to ensure test isolation.
    getIt.reset(dispose: false);
    mockConfigViewModel = MockConfigViewModel();
    mockCheckOrg = MockCheckOrg();
    final configString = await rootBundle.loadString('events/config/config.json');
    final configJson = jsonDecode(configString) as Map<String, dynamic>;
    getIt.registerSingleton<Config>(Config.fromJson(configJson));
    getIt.registerSingleton<CheckOrg>(mockCheckOrg);
    getIt.registerSingleton<ConfigViewModel>(mockConfigViewModel);
    // The mock will be registered inside each test before the widget is pumped.
  });

  Future<void> registerMockViewModel() async {
    when(mockConfigViewModel.viewState).thenReturn(ValueNotifier(ViewState.loadFinished));
    when(mockConfigViewModel.checkToken()).thenAnswer((_) async => false);
    when(mockConfigViewModel.errorMessage).thenReturn('');
    when(mockCheckOrg.hasError).thenReturn(false);
    when(mockConfigViewModel.updateConfig(any)).thenAnswer((_) async => true);
    when(mockConfigViewModel.checkToken()).thenAnswer((_) async => false);
  }

  Widget createWidgetUnderTest() {
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
      home: const ConfigScreen(),
    );
  }

  testWidgets('ConfigScreen shows fields and save button', (WidgetTester tester) async {
    await registerMockViewModel();
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(FormScreenWrapper), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('validation fails when fields are empty', (WidgetTester tester) async {
    await registerMockViewModel();
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.enterText(find.byType(TextFormField).at(2), '');
    await tester.enterText(find.byType(TextFormField).at(3), '');
    await tester.enterText(find.byType(TextFormField).at(4), '');
    await tester.enterText(find.byType(TextFormField).at(5), '');

    // Ensure the button is visible on the screen before tapping.
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.pumpAndSettle(); // Wait for the scroll to finish.
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    // Find the Form widget and get its state to check validation.
    final Form form = tester.widget(find.byType(Form));
    final GlobalKey<FormState> formKey = form.key as GlobalKey<FormState>;
    expect(formKey.currentState!.validate(), false);
  });

  testWidgets('form can be filled and submitted', (WidgetTester tester) async {
    await registerMockViewModel();
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField).at(0), 'test');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await tester.enterText(find.byType(TextFormField).at(2), 'test');
    await tester.enterText(find.byType(TextFormField).at(3), 'test');
    await tester.enterText(find.byType(TextFormField).at(4), 'test');
    await tester.enterText(find.byType(TextFormField).at(5), 'test');

    // Ensure the button is visible on the screen before tapping.
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.pumpAndSettle(); // Wait for the scroll to finish.
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    verify(mockConfigViewModel.updateConfig(any)).called(1);
  });

  testWidgets('shows error dialog when viewState is error', (WidgetTester tester) async {
    await registerMockViewModel();
    when(mockConfigViewModel.viewState).thenReturn(ValueNotifier(ViewState.error));
    when(mockConfigViewModel.errorMessage).thenReturn('wrongBranch');

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CustomErrorDialog), findsOneWidget);
  });
}
