// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loadingAgenda => 'Chargement de l\'agenda...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Erreur lors du chargement de l\'agenda : $error';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get noEventsScheduled => 'Aucun événement programmé';

  @override
  String get loadingSpeakers => 'Chargement des intervenants...';

  @override
  String get errorLoadingSpeakers =>
      'Erreur lors du chargement des intervenants';

  @override
  String get noSpeakersRegistered => 'Aucun intervenant enregistré';

  @override
  String get loadingSponsors => 'Chargement des sponsors...';

  @override
  String get errorLoadingSponsors => 'Erreur lors du chargement des sponsors';

  @override
  String get noSponsorsRegistered => 'Aucun sponsor enregistré';

  @override
  String get loading => 'Chargement...';

  @override
  String get errorLoadingImage => 'Erreur lors du chargement de l\'image';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'CONFÉRENCE';

  @override
  String get workshop => 'ATELIER';

  @override
  String get sessionBreak => 'PAUSE';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Intervenants';

  @override
  String get sponsors => 'Sponsors';

  @override
  String get eventInfo => 'Informations sur l\'Événement';

  @override
  String get eventDates => 'Dates de l\'Événement';

  @override
  String get venue => 'Lieu';

  @override
  String get description => 'Description';

  @override
  String get close => 'Fermer';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Site Web';

  @override
  String get openUrl => 'Ouvrir l\'URL';

  @override
  String get changeLanguage => 'Changer la Langue';
}
