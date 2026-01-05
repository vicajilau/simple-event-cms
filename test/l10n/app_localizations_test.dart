import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/l10n/app_localizations_ca.dart';
import 'package:sec/l10n/app_localizations_en.dart';
import 'package:sec/l10n/app_localizations_es.dart';
import 'package:sec/l10n/app_localizations_eu.dart';
import 'package:sec/l10n/app_localizations_fr.dart';
import 'package:sec/l10n/app_localizations_gl.dart';
import 'package:sec/l10n/app_localizations_it.dart';
import 'package:sec/l10n/app_localizations_pt.dart';


class AppLocalizationsEnMock extends AppLocalizationsEn {
  AppLocalizationsEnMock() : super();
}

void main() {
  group('AppLocalizations', () {
    group('_AppLocalizationsDelegate', () {
      const delegate = AppLocalizations.delegate;

      test('isSupported devuelve true para códigos de idioma soportados', () {
        expect(delegate.isSupported(const Locale('en')), isTrue);
        expect(delegate.isSupported(const Locale('es')), isTrue);
        expect(delegate.isSupported(const Locale('ca')), isTrue);
        expect(delegate.isSupported(const Locale('eu')), isTrue);
        expect(delegate.isSupported(const Locale('fr')), isTrue);
        expect(delegate.isSupported(const Locale('gl')), isTrue);
        expect(delegate.isSupported(const Locale('it')), isTrue);
        expect(delegate.isSupported(const Locale('pt')), isTrue);
      });

      test('isSupported devuelve false para códigos de idioma no soportados', () {
        expect(delegate.isSupported(const Locale('de')), isFalse);
        expect(delegate.isSupported(const Locale('ru')), isFalse);
      });

      test('load carga la instancia correcta de AppLocalizations para cada idioma',
              () async {
            expect(await delegate.load(const Locale('en')), isA<AppLocalizationsEn>());
            expect(await delegate.load(const Locale('es')), isA<AppLocalizationsEs>());
            expect(await delegate.load(const Locale('ca')), isA<AppLocalizationsCa>());
            expect(await delegate.load(const Locale('eu')), isA<AppLocalizationsEu>());
            expect(await delegate.load(const Locale('fr')), isA<AppLocalizationsFr>());
            expect(await delegate.load(const Locale('gl')), isA<AppLocalizationsGl>());
            expect(await delegate.load(const Locale('it')), isA<AppLocalizationsIt>());
            expect(await delegate.load(const Locale('pt')), isA<AppLocalizationsPt>());
          });

      test('shouldReload siempre devuelve false', () {
        expect(delegate.shouldReload(delegate), isFalse);
      });
    });

    group('lookupAppLocalizations', () {
      test('devuelve la instancia correcta para cada idioma soportado', () {
        expect(lookupAppLocalizations(const Locale('en')), isA<AppLocalizationsEn>());
        expect(lookupAppLocalizations(const Locale('es')), isA<AppLocalizationsEs>());
        expect(lookupAppLocalizations(const Locale('ca')), isA<AppLocalizationsCa>());
        expect(lookupAppLocalizations(const Locale('eu')), isA<AppLocalizationsEu>());
        expect(lookupAppLocalizations(const Locale('fr')), isA<AppLocalizationsFr>());
        expect(lookupAppLocalizations(const Locale('gl')), isA<AppLocalizationsGl>());
        expect(lookupAppLocalizations(const Locale('it')), isA<AppLocalizationsIt>());
        expect(lookupAppLocalizations(const Locale('pt')), isA<AppLocalizationsPt>());
      });

      test('lanza un FlutterError para un idioma no soportado', () {
        expect(
              () => lookupAppLocalizations(const Locale('de')),
          throwsA(isA<FlutterError>()),
        );
      });
    });

    group('Static properties', () {
      test('localizationsDelegates contiene los delegates correctos', () {
        expect(AppLocalizations.localizationsDelegates, contains(AppLocalizations.delegate));
        expect(AppLocalizations.localizationsDelegates, contains(GlobalMaterialLocalizations.delegate));
        expect(AppLocalizations.localizationsDelegates, contains(GlobalCupertinoLocalizations.delegate));
        expect(AppLocalizations.localizationsDelegates, contains(GlobalWidgetsLocalizations.delegate));
      });

      test('supportedLocales contiene las locales correctas', () {
        const expectedLocales = <Locale>[
          Locale('ca'),
          Locale('en'),
          Locale('es'),
          Locale('eu'),
          Locale('fr'),
          Locale('gl'),
          Locale('it'),
          Locale('pt'),
        ];
        expect(AppLocalizations.supportedLocales, equals(expectedLocales));
      });
    });

    group('of method', () {
      testWidgets('of devuelve una instancia de AppLocalizations', (WidgetTester tester) async {
        final mock = AppLocalizationsEnMock();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: [
              _TestLocalizationsDelegate(mock),
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                final localizations = AppLocalizations.of(context);
                expect(localizations, isNotNull);
                expect(localizations, isA<AppLocalizationsEn>());
                return const Placeholder();
              },
            ),
          ),
        );
      });
    });
  });
}

class _TestLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations mock;

  _TestLocalizationsDelegate(this.mock);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) => Future.value(mock);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
