import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/screens/login/admin_login_screen.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  late MockConfig mockConfig;

  setUp(() {
    getIt.reset();
    mockConfig = MockConfig();

    getIt.registerSingleton<Config>(mockConfig);

    when(mockConfig.projectName).thenReturn('test-project');
  });

  group('AdminLoginScreen', () {
    testWidgets('renders initial UI correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AdminLoginScreen(() {
      })));

      expect(find.text('Enter your GitHub token'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.eye), findsOneWidget);
    });

    testWidgets('shows error when token is empty', (WidgetTester tester) async {
      bool loginSuccess = false;
      await tester.pumpWidget(buildTestableWidget(AdminLoginScreen(() {
        loginSuccess = true;
      })));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Token cannot be empty.'), findsOneWidget);
      expect(loginSuccess, isFalse);
    });

    testWidgets('obscure text functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AdminLoginScreen(() {})));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      await tester.tap(find.byIcon(FontAwesomeIcons.eye));
      await tester.pump();

      final textFieldAfterTap =
          tester.widget<TextField>(find.byType(TextField));
      expect(textFieldAfterTap.obscureText, isFalse);
      expect(find.byIcon(FontAwesomeIcons.eyeSlash), findsOneWidget);
    });

    testWidgets('shows error snackbar on authentication failure',
        (WidgetTester tester) async {
      // This test relies on the fact that an invalid token will cause an exception in the GitHub client
      await tester.pumpWidget(buildTestableWidget(AdminLoginScreen(() {})));

      await tester.enterText(find.byType(TextFormField), 'invalid-token');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // Start the async operation
      await tester.pump(); // Let the snackbar show

      expect(find.text('Authentication or network error.'), findsOneWidget);
    });

    // A full success test is difficult without refactoring AdminLoginScreen
    // to inject the GitHub client, allowing it to be mocked.
  });
}
