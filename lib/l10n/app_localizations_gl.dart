// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get loadingAgenda => 'Cargando axenda...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Erro cargando axenda: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get noEventsScheduled => 'Non hai eventos programados';

  @override
  String get loadingSpeakers => 'Cargando poñentes...';

  @override
  String get errorLoadingSpeakers => 'Erro cargando poñentes';

  @override
  String get noSpeakersRegistered => 'Non hai poñentes rexistrados';

  @override
  String get loadingSponsors => 'Cargando patrocinadores...';

  @override
  String get errorLoadingSponsors => 'Erro cargando patrocinadores';

  @override
  String get noSponsorsRegistered => 'Non hai patrocinadores rexistrados';

  @override
  String get loading => 'Cargando...';

  @override
  String get errorLoadingImage => 'Erro ao cargar imaxe';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'CHARLA';

  @override
  String get workshop => 'TALLER';

  @override
  String get sessionBreak => 'DESCANSO';

  @override
  String get agenda => 'Axenda';

  @override
  String get speakers => 'Poñentes';

  @override
  String get sponsors => 'Patrocinadores';

  @override
  String get eventInfo => 'Información do Evento';

  @override
  String get eventDates => 'Datas do Evento';

  @override
  String get venue => 'Lugar';

  @override
  String get description => 'Descrición';

  @override
  String get close => 'Pechar';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Sitio Web';

  @override
  String get openUrl => 'Abrir URL';

  @override
  String get changeLanguage => 'Cambiar Idioma';
}
