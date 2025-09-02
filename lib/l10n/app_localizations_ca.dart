// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get loadingAgenda => 'Carregant agenda...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Error carregant agenda: $error';
  }

  @override
  String get retry => 'Tornar a intentar';

  @override
  String get noEventsScheduled => 'No hi ha esdeveniments programats';

  @override
  String get loadingSpeakers => 'Carregant ponents...';

  @override
  String get errorLoadingSpeakers => 'Error carregant ponents';

  @override
  String get noSpeakersRegistered => 'No hi ha ponents registrats';

  @override
  String get loadingSponsors => 'Carregant patrocinadors...';

  @override
  String get errorLoadingSponsors => 'Error carregant patrocinadors';

  @override
  String get noSponsorsRegistered => 'No hi ha patrocinadors registrats';

  @override
  String get loading => 'Carregant...';

  @override
  String get errorLoadingImage => 'Error en carregar la imatge';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'XERRADA';

  @override
  String get workshop => 'TALLER';

  @override
  String get sessionBreak => 'DESCANS';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Ponents';

  @override
  String get sponsors => 'Patrocinadors';

  @override
  String get eventInfo => 'Informació de l\'Esdeveniment';

  @override
  String get eventDates => 'Dates de l\'Esdeveniment';

  @override
  String get venue => 'Lloc';

  @override
  String get description => 'Descripció';

  @override
  String get close => 'Tancar';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Lloc Web';

  @override
  String get openUrl => 'Obrir URL';

  @override
  String get changeLanguage => 'Canviar Idioma';
}
