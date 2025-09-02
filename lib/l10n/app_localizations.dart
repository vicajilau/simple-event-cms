import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('eu'),
    Locale('fr'),
    Locale('gl'),
    Locale('it'),
    Locale('pt'),
  ];

  /// Loading message for agenda screen
  ///
  /// In en, this message translates to:
  /// **'Loading agenda...'**
  String get loadingAgenda;

  /// Error message when agenda fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading agenda: {error}'**
  String errorLoadingAgenda(String error);

  /// Button text to retry an operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message when no events are available
  ///
  /// In en, this message translates to:
  /// **'No events scheduled'**
  String get noEventsScheduled;

  /// Loading message for speakers screen
  ///
  /// In en, this message translates to:
  /// **'Loading speakers...'**
  String get loadingSpeakers;

  /// Error message when speakers fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading speakers'**
  String get errorLoadingSpeakers;

  /// Message when no speakers are available
  ///
  /// In en, this message translates to:
  /// **'No speakers registered'**
  String get noSpeakersRegistered;

  /// Loading message for sponsors screen
  ///
  /// In en, this message translates to:
  /// **'Loading sponsors...'**
  String get loadingSponsors;

  /// Error message when sponsors fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading sponsors'**
  String get errorLoadingSponsors;

  /// Message when no sponsors are available
  ///
  /// In en, this message translates to:
  /// **'No sponsors registered'**
  String get noSponsorsRegistered;

  /// Generic loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message when image fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get errorLoadingImage;

  /// Label for keynote sessions
  ///
  /// In en, this message translates to:
  /// **'KEYNOTE'**
  String get keynote;

  /// Label for talk sessions
  ///
  /// In en, this message translates to:
  /// **'TALK'**
  String get talk;

  /// Label for workshop sessions
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP'**
  String get workshop;

  /// Label for break sessions
  ///
  /// In en, this message translates to:
  /// **'BREAK'**
  String get sessionBreak;

  /// Navigation tab label for agenda
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// Navigation tab label for speakers
  ///
  /// In en, this message translates to:
  /// **'Speakers'**
  String get speakers;

  /// Navigation tab label for sponsors
  ///
  /// In en, this message translates to:
  /// **'Sponsors'**
  String get sponsors;

  /// Title for event information dialog
  ///
  /// In en, this message translates to:
  /// **'Event Information'**
  String get eventInfo;

  /// Label for event dates section
  ///
  /// In en, this message translates to:
  /// **'Event Dates'**
  String get eventDates;

  /// Label for venue section
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// Label for description section
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Button text to close a dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Tooltip for Twitter/X social icon
  ///
  /// In en, this message translates to:
  /// **'Twitter/X'**
  String get twitter;

  /// Tooltip for LinkedIn social icon
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// Tooltip for GitHub social icon
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// Tooltip for website social icon
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Tooltip for opening external links
  ///
  /// In en, this message translates to:
  /// **'Open URL'**
  String get openUrl;

  /// Tooltip for language selector
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ca',
    'en',
    'es',
    'eu',
    'fr',
    'gl',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
    case 'fr':
      return AppLocalizationsFr();
    case 'gl':
      return AppLocalizationsGl();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
