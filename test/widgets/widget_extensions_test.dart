
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sec/presentation/ui/widgets/widget_extensions.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class widget_extensions_test extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  bool canLaunchSuccessfully = true;
  String? urlForCanLaunch;
  String? urlForLaunch;

  @override
  Future<bool> canLaunch(String url) async {
    urlForCanLaunch = url;
    return canLaunchSuccessfully;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urlForLaunch = url;
    return true;
  }
}

void main() {
  late widget_extensions_test mockUrlLauncher;

  setUp(() {
    mockUrlLauncher = widget_extensions_test();
    UrlLauncherPlatform.instance = mockUrlLauncher;
  });

  Widget buildTestableWidget(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData(),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('BuildContextExtensions', () {
    group('openUrl', () {
      testWidgets('launches URL with https prefix', (tester) async {
        const url = 'https://example.com';
        await tester.pumpWidget(
          buildTestableWidget(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.openUrl(url),
                child: const Text('Launch'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(mockUrlLauncher.urlForCanLaunch, url);
        expect(mockUrlLauncher.urlForLaunch, url);
      });

      testWidgets('launches URL with http prefix', (tester) async {
        const url = 'http://example.com';
        await tester.pumpWidget(
          buildTestableWidget(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.openUrl(url),
                child: const Text('Launch'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(mockUrlLauncher.urlForCanLaunch, url);
        expect(mockUrlLauncher.urlForLaunch, url);
      });

      testWidgets('adds https prefix to URL if missing', (tester) async {
        const url = 'example.com';
        const expectedUrl = 'https://$url';
        await tester.pumpWidget(
          buildTestableWidget(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.openUrl(url),
                child: const Text('Launch'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(mockUrlLauncher.urlForCanLaunch, expectedUrl);
        expect(mockUrlLauncher.urlForLaunch, expectedUrl);
      });
    });

    group('showSnackBar', () {
      testWidgets('shows a snackbar with the given message', (tester) async {
        const message = 'Test Snackbar';
        await tester.pumpWidget(
          buildTestableWidget(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.showSnackBar(message),
                child: const Text('Show'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Start animation.
        await tester.pump(const Duration(seconds: 1)); // Animation finished.

        expect(find.text(message), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('showErrorSnackBar', () {
      testWidgets('shows an error snackbar with the given message', (tester) async {
        const message = 'Test Error Snackbar';
        final theme = ThemeData();
        await tester.pumpWidget(
          buildTestableWidget(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.showErrorSnackBar(message),
                child: const Text('Show Error'),
              ),
            ),
            theme: theme,
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text(message), findsOneWidget);
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, theme.colorScheme.error);
      });
    });
  });
}
