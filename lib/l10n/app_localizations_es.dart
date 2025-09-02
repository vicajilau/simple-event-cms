// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loadingAgenda => 'Cargando agenda...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Error cargando agenda: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get noEventsScheduled => 'No hay eventos programados';

  @override
  String get loadingSpeakers => 'Cargando ponentes...';

  @override
  String get errorLoadingSpeakers => 'Error cargando ponentes';

  @override
  String get noSpeakersRegistered => 'No hay ponentes registrados';

  @override
  String get loadingSponsors => 'Cargando patrocinadores...';

  @override
  String get errorLoadingSponsors => 'Error cargando patrocinadores';

  @override
  String get noSponsorsRegistered => 'No hay patrocinadores registrados';

  @override
  String get loading => 'Cargando...';

  @override
  String get errorLoadingImage => 'Error al cargar imagen';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'CHARLA';

  @override
  String get workshop => 'TALLER';

  @override
  String get sessionBreak => 'DESCANSO';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Ponentes';

  @override
  String get sponsors => 'Patrocinadores';

  @override
  String get eventInfo => 'Información del Evento';

  @override
  String get eventDates => 'Fechas del Evento';

  @override
  String get venue => 'Lugar';

  @override
  String get description => 'Descripción';

  @override
  String get close => 'Cerrar';

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
