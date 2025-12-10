import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/widgets/social_icon_svg.dart';

void main() {
  // Helper para encontrar SvgPicture por su assetName
  Finder findSvg(String assetName) {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is SvgPicture &&
          widget.bytesLoader is SvgAssetLoader &&
          (widget.bytesLoader as SvgAssetLoader).assetName == assetName,
    );
  }

  group('SocialIconSvg', () {
    testWidgets('renders correctly and shows tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialIconSvg(
              svgPath: 'assets/X_icon.svg',
              url: 'https://twitter.com',
              color: Colors.black,
              tooltip: 'Test Tooltip',
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      expect(find.byTooltip('Test Tooltip'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(findSvg('assets/X_icon.svg'), findsOneWidget);
    });

    testWidgets('applies tint when tint is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialIconSvg(
              svgPath: 'assets/X_icon.svg',
              url: 'https://twitter.com',
              color: Colors.blue,
              tooltip: 'Twitter',
              tint: true,
            ),
          ),
        ),
      );

      final SvgPicture svg = tester.widget(findSvg('assets/X_icon.svg'));
      expect(svg.colorFilter, isNotNull);
      expect(svg.colorFilter, isA<ColorFilter>());
    });

    testWidgets('does not apply tint when tint is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialIconSvg(
              svgPath: 'assets/LinkedIn_icon.svg',
              url: 'https://linkedin.com',
              color: Colors.blue,
              tooltip: 'LinkedIn',
              tint: false, // Default is false, but we are explicit
            ),
          ),
        ),
      );

      final SvgPicture svg = tester.widget(findSvg('assets/LinkedIn_icon.svg'));
      expect(svg.colorFilter, isNull);
    });
  });

  group('SocialIconsRow', () {
    testWidgets('renders all icons when all social links are provided', (
      WidgetTester tester,
    ) async {
      final social = Social(
        twitter: 'https://twitter.com',
        linkedin: 'https://linkedin.com',
        github: 'https://github.com',
        website: 'https://example.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SocialIconsRow(social: social)),
        ),
      );

      expect(find.byType(SocialIconSvg), findsNWidgets(4));
      expect(findSvg('assets/X_icon.svg'), findsOneWidget);
      expect(findSvg('assets/LinkedIn_icon.svg'), findsOneWidget);
      expect(findSvg('assets/GitHub_icon.svg'), findsOneWidget);
      expect(findSvg('assets/Website_icon.svg'), findsOneWidget);
    });

    testWidgets('renders only one icon when only one social link is provided', (
      WidgetTester tester,
    ) async {
      final social = Social(twitter: 'https://twitter.com');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SocialIconsRow(social: social)),
        ),
      );

      expect(find.byType(SocialIconSvg), findsOneWidget);
      expect(findSvg('assets/X_icon.svg'), findsOneWidget);
    });

    testWidgets('renders nothing when no social links are provided', (
      WidgetTester tester,
    ) async {
      final social = Social();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SocialIconsRow(social: social)),
        ),
      );

      expect(find.byType(SocialIconSvg), findsNothing);
      expect(
        find.byType(SizedBox),
        findsOneWidget,
      ); // Should render SizedBox.shrink
    });

    testWidgets('applies correct spacing and iconSize', (
      WidgetTester tester,
    ) async {
      final social = Social(
        twitter: 'https://t.co',
        linkedin: 'https://ln.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialIconsRow(social: social, spacing: 10, iconSize: 24),
          ),
        ),
      );

      final Wrap wrap = tester.widget(find.byType(Wrap));
      expect(wrap.spacing, 10);
      expect(wrap.runSpacing, 10);

      final List<SocialIconSvg> icons = tester
          .widgetList<SocialIconSvg>(find.byType(SocialIconSvg))
          .toList();
      expect(icons.length, 2);
      expect(icons[0].iconSize, 24);
      expect(icons[1].iconSize, 24);
    });
  });
}
