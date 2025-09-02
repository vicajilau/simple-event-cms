// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loadingAgenda => 'Loading agenda...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Error loading agenda: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get noEventsScheduled => 'No events scheduled';

  @override
  String get loadingSpeakers => 'Loading speakers...';

  @override
  String get errorLoadingSpeakers => 'Error loading speakers';

  @override
  String get noSpeakersRegistered => 'No speakers registered';

  @override
  String get loadingSponsors => 'Loading sponsors...';

  @override
  String get errorLoadingSponsors => 'Error loading sponsors';

  @override
  String get noSponsorsRegistered => 'No sponsors registered';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoadingImage => 'Error loading image';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'TALK';

  @override
  String get workshop => 'WORKSHOP';

  @override
  String get sessionBreak => 'BREAK';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Speakers';

  @override
  String get sponsors => 'Sponsors';

  @override
  String get eventInfo => 'Event Information';

  @override
  String get eventDates => 'Event Dates';

  @override
  String get venue => 'Venue';

  @override
  String get description => 'Description';

  @override
  String get close => 'Close';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Website';

  @override
  String get openUrl => 'Open URL';

  @override
  String get changeLanguage => 'Change Language';
}
