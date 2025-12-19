import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/presentation/ui/widgets/form_screen_wrapper.dart';

void main() {
  const pageTitle = 'Test Page';
  const widgetFormChild = Text('Test Child', key: Key('child'));

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('FormScreenWrapper', () {
    testWidgets('renders correctly on mobile and shows child',
        (WidgetTester tester) async {
      // GIVEN
      await tester.pumpWidget(buildTestableWidget(
        const FormScreenWrapper(
          pageTitle: pageTitle,
          widgetFormChild: widgetFormChild,
        ),
      ));

      // THEN
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(pageTitle), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('back button pops navigator on mobile',
        (WidgetTester tester) async {
      // GIVEN
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('Home Page')),
        ),
      );

      // WHEN
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const FormScreenWrapper(
            pageTitle: pageTitle,
            widgetFormChild: widgetFormChild,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // THEN
      expect(find.byType(FormScreenWrapper), findsOneWidget);

      // WHEN
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // THEN
      expect(find.byType(FormScreenWrapper), findsNothing);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('renders correctly on web', (WidgetTester tester) async {
      // GIVEN
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await tester.pumpWidget(buildTestableWidget(
        const FormScreenWrapper(
          pageTitle: pageTitle,
          widgetFormChild: widgetFormChild,
        ),
      ));

      // THEN
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byKey(const Key('child')), findsOneWidget);
      expect(find.byType(Center), findsAtLeast(1));

      // Tear down
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
