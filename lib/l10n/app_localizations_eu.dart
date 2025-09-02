// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get loadingAgenda => 'Agenda kargatzen...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Errorea agenda kargatzean: $error';
  }

  @override
  String get retry => 'Berriro saiatu';

  @override
  String get noEventsScheduled => 'Ez dago gertaera programaturik';

  @override
  String get loadingSpeakers => 'Hizlariak kargatzen...';

  @override
  String get errorLoadingSpeakers => 'Errorea hizlariak kargatzean';

  @override
  String get noSpeakersRegistered => 'Ez dago hiztun erregistraturik';

  @override
  String get loadingSponsors => 'Babesleak kargatzen...';

  @override
  String get errorLoadingSponsors => 'Errorea babesleak kargatzean';

  @override
  String get noSponsorsRegistered => 'Ez dago babesle erregistraturik';

  @override
  String get loading => 'Kargatzen...';

  @override
  String get errorLoadingImage => 'Errorea irudia kargatzean';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'HITZALDIA';

  @override
  String get workshop => 'TAILERRA';

  @override
  String get sessionBreak => 'ATSEDENA';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Hizlariak';

  @override
  String get sponsors => 'Babesleak';

  @override
  String get eventInfo => 'Gertaeraren Informazioa';

  @override
  String get eventDates => 'Gertaeraren Datak';

  @override
  String get venue => 'Lekua';

  @override
  String get description => 'Deskribapena';

  @override
  String get close => 'Itxi';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Webgunea';

  @override
  String get openUrl => 'URL ireki';

  @override
  String get changeLanguage => 'Hizkuntza aldatu';
}
